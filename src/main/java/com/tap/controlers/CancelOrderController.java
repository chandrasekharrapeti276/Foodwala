package com.tap.controlers;

import java.io.IOException;

import com.tap.DAO1.OrderDAO;
import com.tap.DAOimpl.OrderDAOImpl;
import com.tap.module.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cancelOrder")
public class CancelOrderController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO =
            new OrderDAOImpl();

    // =========================================================
    // CANCEL ORDER
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =====================================================
        // LOGIN CHECK
        // =====================================================

        HttpSession session =
                request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/Login.jsp"
            );

            return;
        }

        // =====================================================
        // GET LOGGED-IN USER ID
        // =====================================================

        int userId;

        try {

            Object userIdObject =
                    session.getAttribute("userId");

            if (userIdObject instanceof Number) {

                userId =
                        ((Number) userIdObject)
                                .intValue();

            } else {

                userId =
                        Integer.parseInt(
                                String.valueOf(
                                        userIdObject
                                ).trim()
                        );
            }

            if (userId <= 0) {
                throw new NumberFormatException();
            }

        } catch (Exception e) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/Login.jsp"
            );

            return;
        }

        // =====================================================
        // GET ORDER ID
        // =====================================================

        String orderIdParameter =
                request.getParameter("orderId");

        if (orderIdParameter == null ||
                orderIdParameter.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory"
            );

            return;
        }

        int orderId;

        try {

            orderId =
                    Integer.parseInt(
                            orderIdParameter.trim()
                    );

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory"
            );

            return;
        }

        // =====================================================
        // LOAD ORDER
        // =====================================================

        Order order;

        try {

            order =
                    orderDAO.getOrder(orderId);

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?cancelled=error"
            );

            return;
        }

        // =====================================================
        // ORDER NOT FOUND
        // =====================================================

        if (order == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?cancelled=notfound"
            );

            return;
        }

        // =====================================================
        // SECURITY CHECK
        // =====================================================

        /*
         * A customer can cancel only their own order.
         */
        if (order.getUserId() != userId) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?cancelled=notallowed"
            );

            return;
        }

        // =====================================================
        // CHECK ORDER STATUS
        // =====================================================

        String currentStatus =
                order.getStatus();

        if (currentStatus == null ||
                currentStatus.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?cancelled=notallowed"
            );

            return;
        }

        String normalizedStatus =
                currentStatus
                        .trim()
                        .toUpperCase();

        /*
         * Cancellation is allowed only before
         * the order goes out for delivery.
         */
        boolean canCancel =
                "PLACED".equals(normalizedStatus)
                || "CONFIRMED".equals(normalizedStatus)
                || "PREPARING".equals(normalizedStatus)
                || "READY".equals(normalizedStatus);

        if (!canCancel) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?cancelled=notallowed"
            );

            return;
        }

        // =====================================================
        // CANCEL ORDER
        // =====================================================

        try {

            /*
             * The current OrderDAO supports:
             *
             * updateOrderStatus(int orderId, String status)
             *
             * Therefore cancellation is represented by
             * changing the order status to CANCELLED.
             */
            orderDAO.updateOrderStatus(
                    orderId,
                    "CANCELLED"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?cancelled=error"
            );

            return;
        }

        // =====================================================
        // SUCCESS
        // =====================================================

        response.sendRedirect(
                request.getContextPath()
                        + "/orderHistory?cancelled=success"
        );
    }

    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Support cancellation through POST as well.
         */
        doGet(
                request,
                response
        );
    }
}