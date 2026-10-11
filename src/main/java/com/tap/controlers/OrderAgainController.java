package com.tap.controlers;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.tap.DAO1.MenuDAO;
import com.tap.DAO1.OrderDAO;
import com.tap.DAO1.RestaurentDAO;
import com.tap.DAOimpl.MenuDAOImpl;
import com.tap.DAOimpl.OrderDAOImpl;
import com.tap.DAOimpl.RestaurentDAOImpl;
import com.tap.module.CartItem;
import com.tap.module.Menu;
import com.tap.module.Order;
import com.tap.module.OrderItem;
import com.tap.module.Restaurent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orderAgain")
public class OrderAgainController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO =
            new OrderDAOImpl();

    private final MenuDAO menuDAO =
            new MenuDAOImpl();

    private final RestaurentDAO restaurentDAO =
            new RestaurentDAOImpl();

    // =========================================================
    // ORDER AGAIN
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
        // GET USER ID
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
        // LOAD ORIGINAL ORDER
        // =====================================================

        Order order;

        try {

            order =
                    orderDAO.getOrder(orderId);

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?reorder=error"
            );

            return;
        }

        // =====================================================
        // ORDER NOT FOUND
        // =====================================================

        if (order == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?reorder=notfound"
            );

            return;
        }

        // =====================================================
        // SECURITY CHECK
        // =====================================================

        /*
         * A customer can reorder only their own order.
         */
        if (order.getUserId() != userId) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?reorder=notallowed"
            );

            return;
        }

        // =====================================================
        // LOAD ORIGINAL ORDER ITEMS
        // =====================================================

        List<OrderItem> orderItems;

        try {

            orderItems =
                    orderDAO.getOrderItems(orderId);

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?reorder=error"
            );

            return;
        }

        if (orderItems == null ||
                orderItems.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?reorder=empty"
            );

            return;
        }

        // =====================================================
        // GET CURRENT CART
        // =====================================================

        Map<Integer, CartItem> cart =
                getCartFromSession(session);

        // =====================================================
        // ADD ORDER ITEMS TO CART
        // =====================================================

        int addedItemCount = 0;
        int skippedItemCount = 0;

        for (OrderItem orderItem : orderItems) {

            if (orderItem == null) {
                continue;
            }

            // =================================================
            // MENU ID
            // =================================================

            int menuId =
                    orderItem.getMenuId();

            if (menuId <= 0) {

                skippedItemCount++;

                continue;
            }

            // =================================================
            // QUANTITY
            // =================================================

            int quantity =
                    orderItem.getQuantity();

            if (quantity <= 0) {
                quantity = 1;
            }

            // =================================================
            // LOAD CURRENT MENU ITEM
            // =================================================

            Menu menu;

            try {

                menu =
                        menuDAO.getMenu(menuId);

            } catch (Exception e) {

                e.printStackTrace();

                skippedItemCount++;

                continue;
            }

            // =================================================
            // MENU NOT FOUND
            // =================================================

            if (menu == null) {

                skippedItemCount++;

                continue;
            }

            // =================================================
            // MENU NOT AVAILABLE
            // =================================================

            if (!menu.isAvailable()) {

                skippedItemCount++;

                continue;
            }

            // =================================================
            // LOAD CURRENT RESTAURANT
            // =================================================

            Restaurent restaurent;

            try {

                restaurent =
                        restaurentDAO.getRestaurent(
                                menu.getRestaurentId()
                        );

            } catch (Exception e) {

                e.printStackTrace();

                skippedItemCount++;

                continue;
            }

            // =================================================
            // RESTAURANT NOT FOUND
            // =================================================

            if (restaurent == null) {

                skippedItemCount++;

                continue;
            }

            // =================================================
            // RESTAURANT INACTIVE
            // =================================================

            if (!restaurent.isActive()) {

                skippedItemCount++;

                continue;
            }

            // =================================================
            // CALCULATE CURRENT DISCOUNTED PRICE
            // =================================================

            double originalPrice =
                    menu.getPrice();

            double discountedPrice =
                    restaurent.getDiscountedPrice(
                            originalPrice
                    );

            // =================================================
            // CHECK EXISTING CART ITEM
            // =================================================

            CartItem existingCartItem =
                    cart.get(menuId);

            if (existingCartItem != null) {

                int existingQuantity =
                        existingCartItem.getQuantity();

                if (existingQuantity < 0) {
                    existingQuantity = 0;
                }

                /*
                 * Refresh the price to the current restaurant
                 * discount. This prevents an old cart price from
                 * being carried into a reorder.
                 */
                existingCartItem.setPrice(
                        discountedPrice
                );

                existingCartItem.setItemName(
                        menu.getItemName()
                );

                existingCartItem.setQuantity(
                        existingQuantity + quantity
                );

            } else {

                // =================================================
                // CREATE NEW CART ITEM
                // =================================================

                CartItem newCartItem =
                        new CartItem(
                                menu.getMenuId(),
                                menu.getItemName(),
                                discountedPrice,
                                quantity
                        );

                cart.put(
                        menuId,
                        newCartItem
                );
            }

            addedItemCount++;
        }

        // =====================================================
        // NOTHING AVAILABLE
        // =====================================================

        if (addedItemCount == 0) {

            session.setAttribute(
                    "reorderMessage",
                    "None of the items from this order are currently available."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/orderHistory?reorder=unavailable"
            );

            return;
        }

        // =====================================================
        // SAVE CART
        // =====================================================

        session.setAttribute(
                "cart",
                cart
        );

        // =====================================================
        // SAVE REORDER INFORMATION
        // =====================================================

        session.setAttribute(
                "reorderOrderId",
                orderId
        );

        session.setAttribute(
                "reorderAddedItemCount",
                addedItemCount
        );

        session.setAttribute(
                "reorderSkippedItemCount",
                skippedItemCount
        );

        // =====================================================
        // SUCCESS
        // =====================================================

        response.sendRedirect(
                request.getContextPath()
                        + "/cart?reorder=success"
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

    // =========================================================
    // GET CART FROM SESSION
    // =========================================================

    private Map<Integer, CartItem> getCartFromSession(
            HttpSession session) {

        Object cartObject =
                session.getAttribute("cart");

        // =====================================================
        // EXISTING MAP CART
        // =====================================================

        if (cartObject instanceof Map<?, ?>) {

            Map<?, ?> rawMap =
                    (Map<?, ?>) cartObject;

            Map<Integer, CartItem> validCart =
                    new LinkedHashMap<>();

            for (Map.Entry<?, ?> entry :
                    rawMap.entrySet()) {

                Object key =
                        entry.getKey();

                Object value =
                        entry.getValue();

                if (key instanceof Number &&
                        value instanceof CartItem) {

                    int menuId =
                            ((Number) key).intValue();

                    CartItem cartItem =
                            (CartItem) value;

                    if (menuId > 0 &&
                            cartItem != null) {

                        validCart.put(
                                menuId,
                                cartItem
                        );
                    }
                }
            }

            return validCart;
        }

        // =====================================================
        // NO CART
        // =====================================================

        return new LinkedHashMap<>();
    }
}