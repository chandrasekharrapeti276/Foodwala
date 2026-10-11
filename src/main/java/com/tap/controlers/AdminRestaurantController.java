
package com.tap.controlers;

import java.io.IOException;
import java.util.List;

import com.tap.DAO1.RestaurentDAO;
import com.tap.DAOimpl.RestaurentDAOImpl;
import com.tap.module.Restaurent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/restaurants")
public class AdminRestaurantController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RestaurentDAO dao;

    @Override
    public void init() throws ServletException {
        dao = new RestaurentDAOImpl();
    }

    private boolean isAdmin(HttpSession session) {
        return session != null
                && session.getAttribute("userId") != null
                && "ADMIN".equalsIgnoreCase(
                        String.valueOf(session.getAttribute("role")));
    }

    private void redirectToLogin(HttpServletRequest request,
                                 HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (!isAdmin(session)) {
            redirectToLogin(request, response);
            return;
        }

        String contextPath = request.getContextPath();

        try {
            String action = request.getParameter("action");

            if ("edit".equalsIgnoreCase(action)) {
                String idValue = request.getParameter("id");
                int id = parseId(idValue);

                Restaurent restaurant = dao.getRestaurent(id);

                if (restaurant == null) {
                    session.setAttribute(
                            "adminMessage", "Restaurant not found.");
                    response.sendRedirect(contextPath + "/admin/restaurants");
                    return;
                }

                request.setAttribute("editRestaurant", restaurant);
            }

            List<Restaurent> restaurants = dao.getAllRestaurents();
            request.setAttribute("restaurants", restaurants);

            Object message = session.getAttribute("adminMessage");
            if (message != null) {
                request.setAttribute("adminMessage", message);
                session.removeAttribute("adminMessage");
            }

            request.getRequestDispatcher("/AdminRestaurant.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            session.setAttribute("adminMessage", "Invalid restaurant ID.");
            response.sendRedirect(contextPath + "/admin/restaurants");

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to load restaurant management page.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (!isAdmin(session)) {
            redirectToLogin(request, response);
            return;
        }

        String contextPath = request.getContextPath();
        String action = request.getParameter("action");

        try {
            if ("delete".equalsIgnoreCase(action)) {
                int id = parseId(request.getParameter("id"));

                dao.deleteRestaurent(id);
                session.setAttribute(
                        "adminMessage", "Restaurant deleted successfully.");

            } else if ("toggle".equalsIgnoreCase(action)) {
                int id = parseId(request.getParameter("id"));

                Restaurent restaurant = dao.getRestaurent(id);

                if (restaurant == null) {
                    session.setAttribute(
                            "adminMessage", "Restaurant not found.");
                } else {
                    restaurant.setActive(!restaurant.isActive());
                    dao.updateRestaurent(restaurant);

                    session.setAttribute(
                            "adminMessage",
                            restaurant.isActive()
                                    ? "Restaurant activated successfully."
                                    : "Restaurant deactivated successfully.");
                }

            } else if ("add".equalsIgnoreCase(action)
                    || "update".equalsIgnoreCase(action)) {

                saveRestaurant(request, session, action);

            } else {
                session.setAttribute(
                        "adminMessage", "Invalid action.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute(
                    "adminMessage", "Invalid restaurant ID or numeric value.");

        } catch (IllegalArgumentException e) {
            session.setAttribute("adminMessage", e.getMessage());

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to process restaurant action.", e);
        }

        response.sendRedirect(contextPath + "/admin/restaurants");
    }

    private void saveRestaurant(HttpServletRequest request,
                                HttpSession session,
                                String action) throws Exception {

        String name = required(request, "name");
        String cuisineType = required(request, "cuisineType");
        String deliveryTime = required(request, "deliveryTime");
        String address = required(request, "address");
        String ratingValue = required(request, "rating");
        String discountValue = required(request, "discountPercent");
        String imagePath = request.getParameter("imagePath");

        if (imagePath == null) {
            imagePath = "";
        } else {
            imagePath = imagePath.trim();
        }

        float rating = Float.parseFloat(ratingValue);
        float discountPercent = Float.parseFloat(discountValue);

        if (rating < 0 || rating > 5) {
            throw new IllegalArgumentException(
                    "Rating must be between 0 and 5.");
        }

        if (discountPercent < 0 || discountPercent > 100) {
            throw new IllegalArgumentException(
                    "Discount must be between 0 and 100.");
        }

        if ("add".equalsIgnoreCase(action)) {
            Restaurent restaurant = new Restaurent();

            restaurant.setName(name);
            restaurant.setCuisineType(cuisineType);
            restaurant.setDeliveryTime(deliveryTime);
            restaurant.setAddress(address);
            restaurant.setRating(rating);
            restaurant.setDiscountPercent(discountPercent);
            restaurant.setImagePath(imagePath);
            restaurant.setActive(true);
            restaurant.setAdminUserId(
                    Integer.parseInt(
                            String.valueOf(session.getAttribute("userId"))));

            dao.addRestaurent(restaurant);

            session.setAttribute(
                    "adminMessage", "Restaurant added successfully.");

        } else {
            int id = parseId(request.getParameter("id"));
            Restaurent restaurant = dao.getRestaurent(id);

            if (restaurant == null) {
                session.setAttribute(
                        "adminMessage", "Restaurant not found.");
                return;
            }

            restaurant.setName(name);
            restaurant.setCuisineType(cuisineType);
            restaurant.setDeliveryTime(deliveryTime);
            restaurant.setAddress(address);
            restaurant.setRating(rating);
            restaurant.setDiscountPercent(discountPercent);
            restaurant.setImagePath(imagePath);

            dao.updateRestaurent(restaurant);

            session.setAttribute(
                    "adminMessage", "Restaurant updated successfully.");
        }
    }

    private int parseId(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new NumberFormatException("Missing restaurant ID.");
        }

        int id = Integer.parseInt(value.trim());

        if (id <= 0) {
            throw new NumberFormatException("Invalid restaurant ID.");
        }

        return id;
    }

    private String required(HttpServletRequest request, String parameter) {
        String value = request.getParameter(parameter);

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Please fill in all required fields.");
        }

        return value.trim();
    }
}
