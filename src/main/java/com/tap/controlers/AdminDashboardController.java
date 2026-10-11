
package com.tap.controlers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.tap.DAO1.OrderDAO;
import com.tap.DAOimpl.OrderDAOImpl;
import com.tap.module.Order;
import com.tap.util.DBconnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/adminDashboard")
public class AdminDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String cp = request.getContextPath();
        HttpSession session = request.getSession(false);

        // Check whether the user is logged in.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(cp + "/Login.jsp");
            return;
        }

        // Allow administrators only.
        Object roleObject = session.getAttribute("role");

        if (roleObject == null
                || !"ADMIN".equalsIgnoreCase(
                        roleObject.toString().trim())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access required."
            );
            return;
        }

        int totalOrders = 0;
        int totalUsers = 0;
        int totalRestaurants = 0;
        int activeRestaurants = 0;
        int pendingOrders = 0;
        int deliveredOrders = 0;
        int cancelledOrders = 0;
        double totalRevenue = 0.0;

        List<Order> recentOrders = new ArrayList<>();
        String dashboardError = null;

        try {
            // Get user and restaurant statistics.
            try (Connection connection = DBconnection.getConnection()) {

                if (connection == null) {
                    throw new SQLException(
                            "Database connection failed."
                    );
                }

                totalUsers = getCount(
                        connection,
                        "SELECT COUNT(*) FROM users"
                );

                totalRestaurants = getCount(
                        connection,
                        "SELECT COUNT(*) FROM restaurent"
                );

                activeRestaurants = getCount(
                        connection,
                        "SELECT COUNT(*) FROM restaurent WHERE isActive = TRUE"
                );
            }

            // Calculate order statistics.
            List<Order> allOrders = orderDAO.getAllOrders();

            if (allOrders != null) {
                for (Order order : allOrders) {

                    if (order == null) {
                        continue;
                    }

                    totalOrders++;

                    String status = order.getStatus();

                    if (status == null || status.trim().isEmpty()) {
                        status = "PLACED";
                    }

                    status = status.trim()
                            .toUpperCase(Locale.ROOT)
                            .replace('_', ' ');

                    switch (status) {
                        case "PLACED":
                        case "CONFIRMED":
                        case "PREPARING":
                        case "READY":
                        case "OUT FOR DELIVERY":
                            pendingOrders++;
                            break;

                        case "DELIVERED":
                            deliveredOrders++;
                            break;

                        case "CANCELLED":
                            cancelledOrders++;
                            break;

                        default:
                            break;
                    }

                    // Exclude cancelled orders from revenue.
                    if (!"CANCELLED".equals(status)) {
                        totalRevenue += order.getTotalAmount();
                    }
                }
            }

            // Load the five most recent orders.
            recentOrders = getRecentOrders(5);

        } catch (Exception e) {

            getServletContext().log(
                    "Failed to load Foodwala admin dashboard.",
                    e
            );

            dashboardError =
                    "Dashboard data could not be loaded. "
                    + "Check the server log and database connection.";
        }

        // Send statistics to AdminDashboard.jsp.
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalRestaurants", totalRestaurants);
        request.setAttribute("activeRestaurants", activeRestaurants);
        request.setAttribute("pendingOrders", pendingOrders);
        request.setAttribute("deliveredOrders", deliveredOrders);
        request.setAttribute("cancelledOrders", cancelledOrders);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("recentOrders", recentOrders);

        if (dashboardError != null) {
            request.setAttribute("dashboardError", dashboardError);
        }

        request.getRequestDispatcher("/AdminDashboard.jsp")
                .forward(request, response);
    }

    // Get a count from the database.
    private int getCount(Connection connection, String sql)
            throws SQLException {

        try (PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        }

        return 0;
    }

    // Get the most recent orders.
    private List<Order> getRecentOrders(int limit) throws SQLException {

        List<Order> recent = new ArrayList<>();

        String sql =
                "SELECT orderId, userId, totalAmount, status, orderDate "
                + "FROM orders "
                + "ORDER BY orderDate DESC, orderId DESC "
                + "LIMIT ?";

        try (Connection connection = DBconnection.getConnection()) {

            if (connection == null) {
                throw new SQLException(
                        "Database connection failed."
                );
            }

            try (PreparedStatement statement =
                         connection.prepareStatement(sql)) {

                statement.setInt(1, limit);

                try (ResultSet rs = statement.executeQuery()) {

                    while (rs.next()) {

                        Order order = new Order();

                        order.setOrderId(rs.getInt("orderId"));
                        order.setUserId(rs.getInt("userId"));
                        order.setTotalAmount(
                                rs.getDouble("totalAmount")
                        );
                        order.setStatus(rs.getString("status"));
                        order.setOrderDate(
                                rs.getTimestamp("orderDate")
                        );

                        recent.add(order);
                    }
                }
            }
        }

        return recent;
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
