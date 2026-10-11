package com.tap.controlers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

@WebServlet("/orderDetails")
public class OrderDetailsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO =
            new OrderDAOImpl();

    private final MenuDAO menuDAO =
            new MenuDAOImpl();

    // =========================================================
    // ORDER DETAILS
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

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
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
                    orderDAO.getOrder(
                            orderId
                    );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?error=order"
            );

            return;
        }

        // =====================================================
        // ORDER NOT FOUND
        // =====================================================

        if (order == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory"
            );

            return;
        }

        // =====================================================
        // SECURITY CHECK
        // =====================================================

        /*
         * A customer can view only their own order.
         */
        if (order.getUserId() != userId) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory"
            );

            return;
        }

        // =====================================================
        // LOAD ORDER ITEMS
        // =====================================================

        List<OrderItem> orderItems;

        try {

            orderItems =
                    orderDAO.getOrderItems(
                            orderId
                    );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?error=items"
            );

            return;
        }

        if (orderItems == null) {

            orderItems =
                    new ArrayList<>();
        }

        // =====================================================
        // LOAD MENU INFORMATION
        // =====================================================

        /*
         * Key   = menuId
         * Value = Menu
         */
        Map<Integer, Menu> menuItems =
                new HashMap<>();

        for (OrderItem orderItem :
                orderItems) {

            if (orderItem == null) {
                continue;
            }

            int menuId =
                    orderItem.getMenuId();

            if (menuId <= 0) {
                continue;
            }

            /*
             * Do not load the same menu item
             * more than once.
             */
            if (menuItems.containsKey(menuId)) {
                continue;
            }

            try {

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

            } catch (Exception e) {

                /*
                 * One unavailable menu should not prevent
                 * the remaining order items from displaying.
                 */
                e.printStackTrace();
            }
        }

        // =====================================================
        // CALCULATE TOTAL ITEM QUANTITY
        // =====================================================

        int totalItems = 0;

        for (OrderItem orderItem :
                orderItems) {

            if (orderItem == null) {
                continue;
            }

            int quantity =
                    orderItem.getQuantity();

            if (quantity > 0) {

                totalItems += quantity;
            }
        }

        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

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

        // =====================================================
        // OPEN ORDER DETAILS PAGE
        // =====================================================

        request.getRequestDispatcher(
                "/OrderDetails.jsp"
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

        /*
         * Order details is a display operation.
         * POST requests use the same logic.
         */
        doGet(
                request,
                response
        );
    }
}