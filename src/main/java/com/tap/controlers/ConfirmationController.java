package com.tap.controlers;

import java.io.IOException;
import java.util.List;

import com.tap.DAO1.MenuDAO;
import com.tap.DAO1.OrderDAO;
import com.tap.DAOimpl.MenuDAOImpl;
import com.tap.DAOimpl.OrderDAOImpl;
import com.tap.module.Menu;
import com.tap.module.Order;
import com.tap.module.OrderItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/confirmation")
public class ConfirmationController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO =
            new OrderDAOImpl();

    private final MenuDAO menuDAO =
            new MenuDAOImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession();

        /*
         * User must be logged in to view
         * the order confirmation.
         */
        Object userIdObject =
                session.getAttribute("userId");

        if (userIdObject == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return;
        }

        int userId;

        try {

            userId =
                    ((Number) userIdObject)
                            .intValue();

        } catch (Exception e) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/restaurent"
            );

            return;
        }

        /*
         * Get order ID from URL first.
         */
        String orderIdParameter =
                request.getParameter("orderId");

        int orderId = 0;

        if (orderIdParameter != null &&
                !orderIdParameter.trim().isEmpty()) {

            try {

                orderId =
                        Integer.parseInt(
                                orderIdParameter.trim()
                        );

            } catch (NumberFormatException e) {

                orderId = 0;
            }
        }

        /*
         * If URL doesn't contain order ID,
         * use the last order stored in session.
         */
        if (orderId <= 0) {

            Object lastOrderIdObject =
                    session.getAttribute(
                            "lastOrderId"
                    );

            if (lastOrderIdObject instanceof Number) {

                orderId =
                        ((Number) lastOrderIdObject)
                                .intValue();

            } else if (lastOrderIdObject != null) {

                try {

                    orderId =
                            Integer.parseInt(
                                    String.valueOf(
                                            lastOrderIdObject
                                    ).trim()
                            );

                } catch (NumberFormatException e) {

                    orderId = 0;
                }
            }
        }

        if (orderId <= 0) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/restaurent"
            );

            return;
        }


        try {

            /*
             * Load the order.
             */
            Order order =
                    orderDAO.getOrder(orderId);

            if (order == null) {

                response.sendRedirect(
                        request.getContextPath()
                                + "/orderHistory"
                );

                return;
            }


            /*
             * Security:
             * Make sure the order belongs
             * to the logged-in user.
             */
            if (order.getUserId() != userId) {

                response.sendRedirect(
                        request.getContextPath()
                                + "/orderHistory"
                );

                return;
            }


            /*
             * Load order items.
             */
            List<OrderItem> orderItems =
                    orderDAO.getOrderItems(
                            orderId
                    );


            /*
             * Load menu details for every
             * ordered item.
             */
            java.util.Map<Integer, Menu> menuItems =
                    new java.util.HashMap<>();

            if (orderItems != null) {

                for (OrderItem item :
                        orderItems) {

                    if (item == null) {
                        continue;
                    }

                    int menuId =
                            item.getMenuId();

                    if (menuId <= 0) {
                        continue;
                    }

                    Menu menu =
                            menuDAO.getMenu(
                                    menuId
                            );

                    if (menu != null) {

                        menuItems.put(
                                menuId,
                                menu
                        );
                    }
                }
            }


            /*
             * Calculate total number of items.
             */
            int totalItems = 0;

            if (orderItems != null) {

                for (OrderItem item :
                        orderItems) {

                    if (item != null &&
                            item.getQuantity() > 0) {

                        totalItems +=
                                item.getQuantity();
                    }
                }
            }


            /*
             * Store everything for JSP.
             */
            request.setAttribute(
                    "order",
                    order
            );

            request.setAttribute(
                    "orderItems",
                    orderItems
            );

            request.setAttribute(
                    "menuItems",
                    menuItems
            );

            request.setAttribute(
                    "totalItems",
                    totalItems
            );

            request.setAttribute(
                    "orderId",
                    orderId
            );


            /*
             * Keep last order available for
             * refreshing confirmation page.
             */
            session.setAttribute(
                    "lastOrderId",
                    orderId
            );


            request.getRequestDispatcher(
                    "/Confirmation.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (Exception e) {

            e.printStackTrace();

            throw new ServletException(
                    "Unable to load order confirmation.",
                    e
            );
        }
    }


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