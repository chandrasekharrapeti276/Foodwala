package com.tap.controlers;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Map;

import com.tap.DAOimpl.CouponDAOImpl;
import com.tap.module.CartItem;
import com.tap.module.Coupon;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/coupon")
public class CouponController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final CouponDAOImpl couponDAO =
            new CouponDAOImpl();

    /*
     * Session attribute names.
     */
    private static final String APPLIED_COUPON =
            "appliedCoupon";

    private static final String CHECKOUT_COUPON =
            "coupon";

    private static final String COUPON_DISCOUNT =
            "couponDiscount";

    private static final String COUPON_STATUS =
            "couponStatus";

    private static final String ITEMS_TOTAL =
            "itemsTotal";


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession();

        String action =
                request.getParameter("action");


        // =====================================================
        // REMOVE COUPON
        // =====================================================

        if ("remove".equalsIgnoreCase(action)) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Coupon removed successfully."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // GET COUPON CODE
        // =====================================================

        String couponCode =
                request.getParameter("couponCode");

        if (couponCode == null ||
                couponCode.trim().isEmpty()) {

            session.setAttribute(
                    COUPON_STATUS,
                    "Please enter a coupon code."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }

        couponCode =
                couponCode.trim().toUpperCase();


        // =====================================================
        // GET CART
        //
        // Current Foodwala cart structure:
        //
        // Map<Integer, CartItem>
        // =====================================================

        Object cartObject =
                session.getAttribute("cart");

        if (!(cartObject instanceof Map<?, ?>)) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Your cart is empty."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        Map<?, ?> rawCart =
                (Map<?, ?>) cartObject;

        if (rawCart.isEmpty()) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Your cart is empty."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }


        // =====================================================
        // CALCULATE CART TOTAL
        // =====================================================

        double itemsTotal = 0.00;

        for (Object value :
                rawCart.values()) {

            if (!(value instanceof CartItem)) {
                continue;
            }

            CartItem item =
                    (CartItem) value;

            if (item.getQuantity() <= 0) {
                continue;
            }

            if (item.getPrice() < 0) {
                continue;
            }

            itemsTotal += item.getTotal();
        }

        itemsTotal =
                roundToTwoDecimals(
                        itemsTotal
                );

        if (itemsTotal <= 0.00) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Your cart is empty."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        session.setAttribute(
                ITEMS_TOTAL,
                itemsTotal
        );


        // =====================================================
        // FIND COUPON
        // =====================================================

        Coupon coupon;

        try {

            coupon =
                    couponDAO.getCouponByCode(
                            couponCode
                    );

        } catch (Exception e) {

            e.printStackTrace();

            session.setAttribute(
                    COUPON_STATUS,
                    "Unable to verify the coupon. Please try again."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // INVALID COUPON
        // =====================================================

        if (coupon == null) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Invalid coupon code."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // CHECK ACTIVE
        // =====================================================

        if (!coupon.isActive()) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "This coupon is currently inactive."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // CHECK EXPIRY
        // =====================================================

        if (coupon.getExpiryDate() != null) {

            LocalDate today =
                    LocalDate.now();

            LocalDate expiryDate =
                    coupon.getExpiryDate()
                            .toLocalDate();

            if (expiryDate.isBefore(today)) {

                removeCoupon(session);

                session.setAttribute(
                        COUPON_STATUS,
                        "This coupon has expired."
                );

                redirectToCheckout(
                        request,
                        response
                );

                return;
            }
        }


        // =====================================================
        // CHECK MINIMUM ORDER AMOUNT
        // =====================================================

        double minimumOrder =
                coupon.getMinimumOrderAmount();

        if (itemsTotal < minimumOrder) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Minimum order amount for "
                            + coupon.getCouponCode()
                            + " is ₹"
                            + String.format(
                                    "%.2f",
                                    minimumOrder
                            )
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // CALCULATE DISCOUNT
        // =====================================================

        double discount = 0.00;

        String discountType =
                coupon.getDiscountType();

        if (discountType == null) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Invalid coupon configuration."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // -----------------------------------------------------
        // FLAT DISCOUNT
        // -----------------------------------------------------

        if ("FLAT".equalsIgnoreCase(
                discountType.trim())) {

            discount =
                    coupon.getDiscountValue();
        }


        // -----------------------------------------------------
        // PERCENTAGE DISCOUNT
        // -----------------------------------------------------

        else if ("PERCENTAGE".equalsIgnoreCase(
                discountType.trim())) {

            discount =
                    itemsTotal
                            * coupon.getDiscountValue()
                            / 100.00;
        }


        // -----------------------------------------------------
        // INVALID DISCOUNT TYPE
        // -----------------------------------------------------

        else {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Invalid coupon configuration."
            );

            redirectToCheckout(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // MAXIMUM DISCOUNT
        // =====================================================

        Double maximumDiscount =
                coupon.getMaximumDiscount();

        if (maximumDiscount != null &&
                maximumDiscount >= 0 &&
                discount > maximumDiscount) {

            discount =
                    maximumDiscount;
        }


        // =====================================================
        // SAFETY CHECKS
        // =====================================================

        if (discount < 0) {
            discount = 0.00;
        }

        if (discount > itemsTotal) {
            discount = itemsTotal;
        }

        discount =
                roundToTwoDecimals(
                        discount
                );


        // =====================================================
        // SAVE COUPON IN SESSION
        // =====================================================

        /*
         * Save both attributes because the existing
         * Checkout.jsp may use "coupon", while other
         * code may use "appliedCoupon".
         */

        session.setAttribute(
                APPLIED_COUPON,
                coupon
        );

        session.setAttribute(
                CHECKOUT_COUPON,
                coupon
        );

        session.setAttribute(
                COUPON_DISCOUNT,
                discount
        );

        session.setAttribute(
                ITEMS_TOTAL,
                itemsTotal
        );

        session.setAttribute(
                COUPON_STATUS,
                "Coupon "
                        + coupon.getCouponCode()
                        + " applied successfully."
        );


        // =====================================================
        // REDIRECT TO CHECKOUT
        // =====================================================

        redirectToCheckout(
                request,
                response
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

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession();

        String action =
                request.getParameter("action");


        // =====================================================
        // REMOVE COUPON
        // =====================================================

        if ("remove".equalsIgnoreCase(action)) {

            removeCoupon(session);

            session.setAttribute(
                    COUPON_STATUS,
                    "Coupon removed successfully."
            );
        }


        // =====================================================
        // ALWAYS RETURN TO CHECKOUT
        // =====================================================

        redirectToCheckout(
                request,
                response
        );
    }


    // =========================================================
    // REMOVE COUPON
    // =========================================================

    private void removeCoupon(
            HttpSession session) {

        session.removeAttribute(
                APPLIED_COUPON
        );

        session.removeAttribute(
                CHECKOUT_COUPON
        );

        session.removeAttribute(
                COUPON_DISCOUNT
        );

        session.removeAttribute(
                ITEMS_TOTAL
        );
    }


    // =========================================================
    // ROUND TO TWO DECIMAL PLACES
    // =========================================================

    private double roundToTwoDecimals(
            double amount) {

        return Math.round(
                amount * 100.0
        ) / 100.0;
    }


    // =========================================================
    // REDIRECT TO CHECKOUT
    // =========================================================

    private void redirectToCheckout(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/checkout"
        );
    }
}