
package com.tap.controlers;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.tap.DAO1.MenuDAO;
import com.tap.DAO1.RestaurentDAO;
import com.tap.DAOimpl.MenuDAOImpl;
import com.tap.DAOimpl.RestaurentDAOImpl;
import com.tap.module.CartItem;
import com.tap.module.Menu;
import com.tap.module.Restaurent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/addToCart")
public class AddToCartControl extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final MenuDAO menuDAO = new MenuDAOImpl();
    private final RestaurentDAO restaurentDAO = new RestaurentDAOImpl();

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        try {
            String menuIdValue = request.getParameter("menuId");

            if (menuIdValue == null || menuIdValue.trim().isEmpty()) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Menu ID is required."
                );
                return;
            }

            int menuId = Integer.parseInt(menuIdValue.trim());

            if (menuId <= 0) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid menu ID."
                );
                return;
            }

            Menu menu = menuDAO.getMenu(menuId);

            if (menu == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Menu item not found."
                );
                return;
            }

            if (!menu.isAvailable()) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "This menu item is currently unavailable."
                );
                return;
            }

            Restaurent restaurent =
                restaurentDAO.getRestaurent(menu.getRestaurentId());

            if (restaurent == null || !restaurent.isActive()) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Restaurant not found or inactive."
                );
                return;
            }

            /*
             * Calculate the same restaurant discount shown on menu.jsp.
             */
            double itemPrice =
                restaurent.getDiscountedPrice(menu.getPrice());

            HttpSession session = request.getSession();

            Map<Integer, CartItem> cart =
                (Map<Integer, CartItem>) session.getAttribute("cart");

            if (cart == null) {
                cart = new LinkedHashMap<>();
                session.setAttribute("cart", cart);
            }

            CartItem existingItem = cart.get(menuId);

            if (existingItem == null) {
                CartItem newItem = new CartItem(
                    menu.getMenuId(),
                    menu.getItemName(),
                    itemPrice,
                    1
                );

                cart.put(menuId, newItem);
            } else {
                /*
                 * Keep the stored item price consistent with the
                 * current restaurant discount before increasing quantity.
                 */
                existingItem.setQuantity(existingItem.getQuantity() + 1);
            }

            session.setAttribute("cart", cart);

            String restaurantIdValue =
                request.getParameter("restaurentId");

            int redirectRestaurantId = menu.getRestaurentId();

            if (restaurantIdValue != null
                    && !restaurantIdValue.trim().isEmpty()) {
                try {
                    int requestedRestaurantId =
                        Integer.parseInt(restaurantIdValue.trim());

                    /*
                     * Never redirect to an unrelated restaurant ID.
                     * The menu item's restaurant is authoritative.
                     */
                    if (requestedRestaurantId == menu.getRestaurentId()) {
                        redirectRestaurantId = requestedRestaurantId;
                    }
                } catch (NumberFormatException ignored) {
                    // Use the restaurant ID stored with the menu item.
                }
            }

            response.sendRedirect(
                contextPath + "/menu?restaurentId="
                    + redirectRestaurantId + "&added=1"
            );

        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid menu ID."
            );
        } catch (Exception e) {
            throw new ServletException(
                "Unable to add the item to the cart.", e
            );
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
            request.getContextPath() + "/restaurent"
        );
    }
}