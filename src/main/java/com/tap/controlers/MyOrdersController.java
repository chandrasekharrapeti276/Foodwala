
package com.tap.controlers;

import java.io.IOException;
import java.util.List;

import com.tap.DAO1.OrderDAO;
import com.tap.DAOimpl.OrderDAOImpl;
import com.tap.module.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/myOrders")
public class MyOrdersController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control",
                "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);

        // Customer must be logged in.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/Login.jsp");
            return;
        }

        int userId;

        try {
            Object userIdObject = session.getAttribute("userId");

            if (userIdObject instanceof Number) {
                userId = ((Number) userIdObject).intValue();
            } else {
                userId = Integer.parseInt(userIdObject.toString());
            }

            // Load only the orders belonging to this customer.
            List<Order> orders = orderDAO.getOrdersByUserId(userId);

            request.setAttribute("orders", orders);

            // Forward to the existing order-history page.
            request.getRequestDispatcher("/MyOrders.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Invalid user session. Please log in again.");
        } catch (Exception e) {
            throw new ServletException(
                    "Unable to load your order history.", e);
        }
    }
}
