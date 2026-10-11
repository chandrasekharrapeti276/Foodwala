package com.tap.controlers;

import java.io.IOException;
import java.util.Collections;
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

@WebServlet("/orderHistory")
public class OrderHistoryController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO =
            new OrderDAOImpl();

    // =========================================================
    // ORDER HISTORY
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =====================================================
        // GET EXISTING SESSION
        // =====================================================

        HttpSession session =
                request.getSession(false);

        // =====================================================
        // LOGIN CHECK
        // =====================================================

        if (session == null ||
                session.getAttribute("userId") == null) {

            /*
             * Remember the page the user wanted to open.
             * After login, LoginController can return here.
             */
            if (session != null) {

                session.setAttribute(
                        "redirectAfterLogin",
                        request.getContextPath()
                                + "/orderHistory"
                );
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
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

            /*
             * Invalid session user ID.
             * Clear the invalid session and require login again.
             */
            session.invalidate();

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return;
        }

        // =====================================================
        // LOAD USER'S ORDERS
        // =====================================================

        List<Order> orders;

        try {

            orders =
                    orderDAO.getOrdersByUserId(
                            userId
                    );

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load your order history."
            );

            request.setAttribute(
                    "orders",
                    Collections.emptyList()
            );

            request.getRequestDispatcher(
                    "/OrderHistory.jsp"
            ).forward(
                    request,
                    response
            );

            return;
        }

        // =====================================================
        // SAFETY CHECK
        // =====================================================

        if (orders == null) {

            orders =
                    Collections.emptyList();
        }

        // =====================================================
        // SEND ORDERS TO JSP
        // =====================================================

        request.setAttribute(
                "orders",
                orders
        );

        // =====================================================
        // OPTIONAL SUCCESS / STATUS MESSAGES
        // =====================================================

        String cancelled =
                request.getParameter("cancelled");

        if ("success".equalsIgnoreCase(cancelled)) {

            request.setAttribute(
                    "success",
                    "Order cancelled successfully."
            );

        } else if ("notallowed".equalsIgnoreCase(cancelled)) {

            request.setAttribute(
                    "error",
                    "This order cannot be cancelled."
            );

        } else if ("error".equalsIgnoreCase(cancelled)) {

            request.setAttribute(
                    "error",
                    "Unable to cancel the order."
            );
        }

        // =====================================================
        // REORDER STATUS MESSAGES
        // =====================================================

        String reorder =
                request.getParameter("reorder");

        if ("success".equalsIgnoreCase(reorder)) {

            request.setAttribute(
                    "success",
                    "Items from your previous order were added to your cart."
            );

        } else if ("unavailable".equalsIgnoreCase(reorder)) {

            Object reorderMessage =
                    session.getAttribute(
                            "reorderMessage"
                    );

            if (reorderMessage != null) {

                request.setAttribute(
                        "error",
                        reorderMessage.toString()
                );

                session.removeAttribute(
                        "reorderMessage"
                );

            } else {

                request.setAttribute(
                        "error",
                        "The items from this order are currently unavailable."
                );
            }

        } else if ("notfound".equalsIgnoreCase(reorder)) {

            request.setAttribute(
                    "error",
                    "The selected order could not be found."
            );

        } else if ("notallowed".equalsIgnoreCase(reorder)) {

            request.setAttribute(
                    "error",
                    "You are not allowed to reorder this order."
            );

        } else if ("empty".equalsIgnoreCase(reorder)) {

            request.setAttribute(
                    "error",
                    "This order does not contain any items."
            );

        } else if ("error".equalsIgnoreCase(reorder)) {

            request.setAttribute(
                    "error",
                    "Unable to reorder this order."
            );
        }

        // =====================================================
        // FORWARD TO ORDER HISTORY PAGE
        // =====================================================

        request.getRequestDispatcher(
                "/OrderHistory.jsp"
        ).forward(
                request,
                response
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

        doGet(
                request,
                response
        );
    }
}