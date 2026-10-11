package com.tap.controlers;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.tap.module.CartItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/updateCart")
public class UpdateCartController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================================================
    // UPDATE CART
    // =========================================================

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession();

        // =====================================================
        // GET CART
        // =====================================================

        Object cartObject =
                session.getAttribute("cart");

        if (!(cartObject instanceof Map<?, ?>)) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        Map<Integer, CartItem> cart =
                (Map<Integer, CartItem>) cartObject;

        // =====================================================
        // GET MENU ID
        // =====================================================

        String menuIdParameter =
                request.getParameter("menuId");

        if (menuIdParameter == null ||
                menuIdParameter.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        int menuId;

        try {

            menuId =
                    Integer.parseInt(
                            menuIdParameter.trim()
                    );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        if (menuId <= 0) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        // =====================================================
        // CHECK CART ITEM
        // =====================================================

        CartItem cartItem =
                cart.get(menuId);

        if (cartItem == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        // =====================================================
        // GET QUANTITY
        // =====================================================

        String quantityParameter =
                request.getParameter("quantity");

        if (quantityParameter == null ||
                quantityParameter.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        int quantity;

        try {

            quantity =
                    Integer.parseInt(
                            quantityParameter.trim()
                    );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        // =====================================================
        // QUANTITY RULE
        //
        // 0 or negative quantity removes the item.
        // Positive quantity updates the item.
        // =====================================================

        if (quantity <= 0) {

            cart.remove(menuId);

        } else {

            /*
             * Keep the existing CartItem object so that
             * item name and price remain unchanged.
             */
            cartItem.setQuantity(quantity);
        }

        // =====================================================
        // SAVE CART BACK TO SESSION
        // =====================================================

        session.setAttribute(
                "cart",
                cart
        );

        // =====================================================
        // REDIRECT TO CART
        // =====================================================

        response.sendRedirect(
                request.getContextPath()
                        + "/cart"
        );
    }

    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Cart updates should normally happen through POST.
         *
         * If someone directly opens /updateCart,
         * safely return to the cart page.
         */

        response.sendRedirect(
                request.getContextPath()
                        + "/cart"
        );
    }
}