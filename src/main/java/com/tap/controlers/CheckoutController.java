package com.tap.controlers;

import java.io.IOException;
import java.util.Map;

import com.tap.module.CartItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        /*
         * Get cart from session.
         *
         * Guests are allowed to have a cart.
         */
        Map<Integer, CartItem> cart =
                (Map<Integer, CartItem>)
                        session.getAttribute("cart");

        /*
         * Checkout is possible only when
         * the cart contains at least one item.
         */
        if (cart == null || cart.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        /*
         * Calculate cart total.
         */
        double total = 0.0;

        for (CartItem item : cart.values()) {

            if (item != null) {

                total += item.getTotal();
            }
        }

        /*
         * Safety check.
         *
         * If the cart somehow contains only null items,
         * do not continue to checkout.
         */
        if (total <= 0.0) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        /*
         * Check whether the user is logged in.
         *
         * Login is required ONLY when the user
         * proceeds from Cart to Checkout.
         */
        Object userId =
                session.getAttribute("userId");

        if (userId == null) {

            /*
             * Remember that checkout was requested.
             *
             * LoginController will read this value
             * after successful login and redirect the
             * user back to Checkout.
             */
            session.setAttribute(
                    "redirectAfterLogin",
                    request.getContextPath()
                            + "/checkout"
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return;
        }

        /*
         * User is already logged in.
         *
         * Send cart and total to Checkout.jsp.
         */
        request.setAttribute(
                "cart",
                cart
        );

        request.setAttribute(
                "total",
                total
        );

        /*
         * Open checkout page.
         */
        request.getRequestDispatcher(
                "/Checkout.jsp"
        ).forward(
                request,
                response
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Checkout does not need a separate POST operation.
         * Use the same checkout flow.
         */
        doGet(
                request,
                response
        );
    }
}