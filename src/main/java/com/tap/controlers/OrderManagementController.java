
package com.tap.controlers;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import com.tap.DAO1.OrderDAO;
import com.tap.DAOimpl.OrderDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orderManagement")
public class OrderManagementController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    private static final List<String> VALID_STATUSES =
            Arrays.asList(
                "PLACED",
                "CONFIRMED",
                "PREPARING",
                "READY",
                "OUT FOR DELIVERY",
                "DELIVERED",
                "CANCELLED"
            );

    private boolean checkAdmin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/Login.jsp"
            );
            return false;
        }

        Object roleObject = session.getAttribute("role");

        String role = roleObject == null
                ? ""
                : roleObject.toString().trim();

        if (!"ADMIN".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can manage orders."
            );
            return false;
        }

        return true;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) {
            return;
        }

        try {
            request.setAttribute(
                    "orders",
                    orderDAO.getAllOrders()
            );

            request.setAttribute(
                    "validStatuses",
                    VALID_STATUSES
            );

            if ("1".equals(request.getParameter("updated"))) {
                request.setAttribute(
                        "statusMessage",
                        "Order status updated successfully."
                );
            }

            request.getRequestDispatcher(
                    "/OrderManagement.jsp"
            ).forward(request, response);

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to load orders. Check the DAO and database connection.",
                    e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String orderIdValue = request.getParameter("orderId");
        String statusValue = request.getParameter("status");

        int orderId;

        try {
            if (orderIdValue == null
                    || orderIdValue.trim().isEmpty()) {
                throw new NumberFormatException();
            }

            orderId = Integer.parseInt(orderIdValue.trim());

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid or missing order ID."
            );
            return;
        }

        if (orderId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Order ID must be greater than zero."
            );
            return;
        }

        if (statusValue == null
                || statusValue.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Order status is required."
            );
            return;
        }

        String status = statusValue.trim()
                .toUpperCase(Locale.ROOT)
                .replace('_', ' ');

        if (!VALID_STATUSES.contains(status)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order status."
            );
            return;
        }

        try {
            if (orderDAO.getOrder(orderId) == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Order #" + orderId + " was not found."
                );
                return;
            }

            orderDAO.updateOrderStatus(orderId, status);

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderManagement?updated=1"
            );

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to update order #" + orderId + ".",
                    e
            );
        }
    }
}
