
package com.tap.controlers;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import com.tap.DAO1.MenuDAO;
import com.tap.DAO1.RestaurentDAO;
import com.tap.DAOimpl.MenuDAOImpl;
import com.tap.DAOimpl.RestaurentDAOImpl;
import com.tap.module.Menu;
import com.tap.module.Restaurent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin/menu", "/adminMenu"})
public class AdminMenuController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final MenuDAO menuDAO = new MenuDAOImpl();
    private final RestaurentDAO restaurentDAO = new RestaurentDAOImpl();

    private boolean checkAdmin(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return false;
        }

        Object role = session.getAttribute("role");

        if (role == null ||
                !"ADMIN".equalsIgnoreCase(role.toString().trim())) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Administrator access is required."
            );
            return false;
        }

        return true;
    }

    private int getSelectedRestaurantId(HttpServletRequest request) {
        String value = request.getParameter("restaurentId");

        if (value == null || value.trim().isEmpty()) {
            value = request.getParameter("restaurantId");
        }

        if (value == null || value.trim().isEmpty()) {
            return 0;
        }

        int id = Integer.parseInt(value.trim());

        if (id < 0) {
            throw new IllegalArgumentException(
                "Restaurant ID cannot be negative."
            );
        }

        return id;
    }

    private int getRequiredId(
            HttpServletRequest request,
            String... parameterNames) {

        for (String parameter : parameterNames) {
            String value = request.getParameter(parameter);

            if (value != null && !value.trim().isEmpty()) {
                int id = Integer.parseInt(value.trim());

                if (id <= 0) {
                    throw new IllegalArgumentException(
                        "Invalid ID: " + parameter
                    );
                }

                return id;
            }
        }

        throw new IllegalArgumentException(
            "Missing required ID: " + String.join("/", parameterNames)
        );
    }

    private String required(
            HttpServletRequest request,
            String parameter) {

        String value = request.getParameter(parameter);

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Please fill in " + parameter + "."
            );
        }

        return value.trim();
    }

    private void setSelectedRestaurantAttributes(
            HttpServletRequest request,
            int restaurantId) {

        request.setAttribute("selectedRestaurentId", restaurantId);
        request.setAttribute("selectedRestaurantId", restaurantId);
    }

    private void redirectToMenu(
            HttpServletRequest request,
            HttpServletResponse response,
            int restaurantId) throws IOException {

        String url = request.getContextPath()
                + "/admin/menu?restaurentId=" + restaurantId;

        response.sendRedirect(response.encodeRedirectURL(url));
    }

    private Restaurent findRestaurant(int restaurantId) throws Exception {
        if (restaurantId <= 0) {
            return null;
        }

        return restaurentDAO.getRestaurent(restaurantId);
    }

    private Menu findMenuForRestaurant(
            int menuId,
            int restaurantId) throws Exception {

        Menu menu = menuDAO.getMenu(menuId);

        if (menu == null) {
            return null;
        }

        if (menu.getRestaurentId() != restaurantId) {
            throw new IllegalArgumentException(
                "The menu item does not belong to the selected restaurant."
            );
        }

        return menu;
    }

    private void setFlashMessage(
            HttpServletRequest request,
            String message) {

        request.getSession().setAttribute("adminMessage", message);
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader(
            "Cache-Control",
            "no-cache, no-store, must-revalidate"
        );
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        if (!checkAdmin(request, response)) {
            return;
        }

        try {
            String action = request.getParameter("action");
            int restaurantId = getSelectedRestaurantId(request);
            Menu editMenu = null;

            /*
             * Deletion and availability changes are handled only by POST.
             * GET is reserved for displaying pages and editing forms.
             */
            if ("delete".equalsIgnoreCase(action) ||
                    "toggle".equalsIgnoreCase(action)) {

                response.sendError(
                    HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                    "Submit this action using POST."
                );
                return;
            }

            if ("edit".equalsIgnoreCase(action)) {
                int menuId = getRequiredId(request, "id", "menuId");

                if (restaurantId <= 0) {
                    Menu existing = menuDAO.getMenu(menuId);

                    if (existing == null) {
                        response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Menu item not found."
                        );
                        return;
                    }

                    restaurantId = existing.getRestaurentId();
                }

                editMenu = findMenuForRestaurant(menuId, restaurantId);

                if (editMenu == null) {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Menu item not found."
                    );
                    return;
                }
            }

            List<Restaurent> restaurants =
                    restaurentDAO.getAllRestaurents();

            if (restaurants == null) {
                restaurants = Collections.emptyList();
            }

            if (restaurantId <= 0 && !restaurants.isEmpty()) {
                restaurantId = restaurants.get(0).getRestaurentId();
            }

            Restaurent selectedRestaurant = findRestaurant(restaurantId);

            if (restaurantId > 0 && selectedRestaurant == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Selected restaurant not found."
                );
                return;
            }

            List<Menu> menus = Collections.emptyList();

            if (restaurantId > 0) {
                List<Menu> result =
                        menuDAO.getMenusByRestaurentId(restaurantId);

                if (result != null) {
                    menus = result;
                }
            }

            request.setAttribute("restaurants", restaurants);
            request.setAttribute("menus", menus);
            request.setAttribute("editMenu", editMenu);
            request.setAttribute("selectedRestaurant", selectedRestaurant);

            setSelectedRestaurantAttributes(request, restaurantId);

            HttpSession session = request.getSession(false);

            if (session != null) {
                Object message = session.getAttribute("adminMessage");

                if (message != null) {
                    request.setAttribute(
                        "adminMenuMessage", message.toString()
                    );
                    request.setAttribute(
                        "adminMessage", message.toString()
                    );
                    session.removeAttribute("adminMessage");
                }
            }

            request.getRequestDispatcher("/AdminMenu.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "The restaurant ID or menu item ID is invalid."
            );

        } catch (IllegalArgumentException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                e.getMessage()
            );

        } catch (Exception e) {
            throw new ServletException(
                "Unable to load menu management. Check MenuDAOImpl and the database.",
                e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!checkAdmin(request, response)) {
            return;
        }

        try {
            String action = required(request, "action");
            int restaurantId = getSelectedRestaurantId(request);

            if (restaurantId <= 0) {
                throw new IllegalArgumentException(
                    "Please select a restaurant."
                );
            }

            Restaurent restaurant = findRestaurant(restaurantId);

            if (restaurant == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Selected restaurant not found."
                );
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                int menuId = getRequiredId(request, "menuId", "id");

                Menu menu = findMenuForRestaurant(menuId, restaurantId);

                if (menu == null) {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Menu item not found."
                    );
                    return;
                }

                menuDAO.deleteMenu(menuId);

                setFlashMessage(
                    request, "Menu item deleted successfully."
                );

                redirectToMenu(request, response, restaurantId);
                return;
            }

            if ("toggle".equalsIgnoreCase(action)) {
                int menuId = getRequiredId(request, "menuId", "id");

                Menu menu = findMenuForRestaurant(menuId, restaurantId);

                if (menu == null) {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Menu item not found."
                    );
                    return;
                }

                menu.setAvailable(!menu.isAvailable());
                menuDAO.updateMenu(menu);

                setFlashMessage(
                    request,
                    menu.isAvailable()
                        ? "Menu item is now available."
                        : "Menu item is now unavailable."
                );

                redirectToMenu(request, response, restaurantId);
                return;
            }

            if (!"add".equalsIgnoreCase(action) &&
                    !"update".equalsIgnoreCase(action)) {

                throw new IllegalArgumentException(
                    "Invalid menu action."
                );
            }

            String itemName = required(request, "itemName");
            String description = request.getParameter("description");
            String priceText = required(request, "price");
            String imagePath = request.getParameter("imagePath");

            if (itemName.length() > 150) {
                throw new IllegalArgumentException(
                    "Food item name cannot exceed 150 characters."
                );
            }

            if (description != null && description.length() > 1000) {
                throw new IllegalArgumentException(
                    "Description cannot exceed 1000 characters."
                );
            }

            double price = Double.parseDouble(priceText);

            if (!Double.isFinite(price) || price < 0) {
                throw new IllegalArgumentException(
                    "Price must be a valid non-negative number."
                );
            }

            if (imagePath != null) {
                imagePath = imagePath.trim();

                if (imagePath.isEmpty()) {
                    imagePath = null;
                } else if (imagePath.length() > 2048) {
                    throw new IllegalArgumentException(
                        "Image URL is too long."
                    );
                }
            }

            if ("add".equalsIgnoreCase(action)) {
                Menu menu = new Menu();

                menu.setRestaurentId(restaurantId);
                menu.setItemName(itemName);
                menu.setDescription(description);
                menu.setPrice(price);
                menu.setImagePath(imagePath);

                /*
                 * HTML checkboxes submit a value only when checked.
                 * If unchecked, the parameter is absent.
                 * New items default to available unless the form submits
                 * an explicit checkbox value.
                 */
                String availableValue = request.getParameter("isAvailable");

                boolean available = availableValue == null
                        || "true".equalsIgnoreCase(availableValue)
                        || "on".equalsIgnoreCase(availableValue)
                        || "yes".equalsIgnoreCase(availableValue)
                        || "1".equals(availableValue);

                menu.setAvailable(available);
                menuDAO.addMenu(menu);

            } else {
                int menuId = getRequiredId(request, "menuId", "id");

                Menu menu = findMenuForRestaurant(menuId, restaurantId);

                if (menu == null) {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Menu item not found."
                    );
                    return;
                }

                menu.setItemName(itemName);
                menu.setDescription(description);
                menu.setPrice(price);
                menu.setImagePath(imagePath);

                /*
                 * If the update form includes the availability checkbox,
                 * update its value. Otherwise preserve the existing value.
                 */
                String availableValue = request.getParameter("isAvailable");

                if (availableValue != null) {
                    boolean available =
                            "true".equalsIgnoreCase(availableValue)
                            || "on".equalsIgnoreCase(availableValue)
                            || "yes".equalsIgnoreCase(availableValue)
                            || "1".equals(availableValue);

                    menu.setAvailable(available);
                }

                menuDAO.updateMenu(menu);
            }

            setFlashMessage(
                request, "Menu item saved successfully."
            );

            redirectToMenu(request, response, restaurantId);

        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Enter a valid restaurant ID, menu ID, and price."
            );

        } catch (IllegalArgumentException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                e.getMessage()
            );

        } catch (Exception e) {
            throw new ServletException(
                "Unable to save the menu item. Check MenuDAOImpl and the database.",
                e
            );
        }
    }
}
