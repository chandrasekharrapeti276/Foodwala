
package com.tap.controlers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;

import com.tap.DAO1.OrderDAO;
import com.tap.DAOimpl.OrderDAOImpl;
import com.tap.module.CartItem;
import com.tap.module.Order;
import com.tap.module.OrderItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/placeOrder")
public class PlaceOrderController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        Object userIdObject = session.getAttribute("userId");
        Object cartObject = session.getAttribute("cart");

        if (!(cartObject instanceof Map<?, ?>)) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        Map<Integer, CartItem> cart =
                (Map<Integer, CartItem>) cartObject;

        if (cart.isEmpty()) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        String deliveryName = value(request, "deliveryName");
        String deliveryPhone = value(request, "deliveryPhone");
        String deliveryAddress = value(request, "deliveryAddress");
        String city = value(request, "city");
        String pincode = value(request, "pincode");
        String landmark = value(request, "landmark");
        String paymentMode = value(request, "paymentMode").toUpperCase();

        // Accept both values used by different versions of Checkout.jsp.
        if ("CASH_ON_DELIVERY".equals(paymentMode)) {
            paymentMode = "COD";
        }

        String validationError = null;

        if (deliveryName.isEmpty()
                || deliveryPhone.isEmpty()
                || deliveryAddress.isEmpty()
                || city.isEmpty()
                || pincode.isEmpty()) {

            validationError =
                    "Please fill in all required delivery details.";

        } else if (!deliveryPhone.matches("[0-9]{10}")) {

            validationError =
                    "Enter a valid 10-digit mobile number.";

        } else if (!pincode.matches("[0-9]{6}")) {

            validationError =
                    "Enter a valid 6-digit PIN code.";

        } else if (!isAllowedPaymentMode(paymentMode)) {

            validationError =
                    "Please select a valid payment method.";
        }

        if (validationError != null) {
            showCheckoutError(
                    request, response, cart, validationError);
            return;
        }

        try {
            int userId = ((Number) userIdObject).intValue();

            if (userId <= 0) {
                response.sendRedirect(contextPath + "/login");
                return;
            }

            StringBuilder completeAddress = new StringBuilder();
            completeAddress.append(deliveryAddress)
                    .append(", ")
                    .append(city)
                    .append(" - ")
                    .append(pincode);

            if (!landmark.isEmpty()) {
                completeAddress.append(", Landmark: ")
                        .append(landmark);
            }

            ArrayList<OrderItem> orderItems = new ArrayList<>();
            double itemsTotal = 0.0;

            for (CartItem cartItem : cart.values()) {

                if (cartItem == null) {
                    continue;
                }

                int menuId = cartItem.getMenuId();
                int quantity = cartItem.getQuantity();
                double itemTotal = cartItem.getTotal();

                if (menuId <= 0 || quantity <= 0) {
                    throw new ServletException(
                            "Invalid item found in the cart.");
                }

                if (Double.isNaN(itemTotal)
                        || Double.isInfinite(itemTotal)
                        || itemTotal <= 0) {
                    throw new ServletException(
                            "Invalid cart item price.");
                }

                itemsTotal += itemTotal;

                OrderItem orderItem = new OrderItem();
                orderItem.setMenuId(menuId);
                orderItem.setQuantity(quantity);
                orderItem.setItemTotal(itemTotal);

                orderItems.add(orderItem);
            }

            if (orderItems.isEmpty() || itemsTotal <= 0) {
                showCheckoutError(
                        request,
                        response,
                        cart,
                        "Your cart has no valid items. Please review your cart.");
                return;
            }

            /*
             * Keep the total consistent with Checkout.jsp:
             * Delivery is free for item totals of ₹499 or more.
             * Platform fee: ₹5
             * Packaging fee: ₹10
             * Estimated GST: 5% of item total
             */
            double deliveryFee = itemsTotal >= 499.00 ? 0.00 : 40.00;
            double platformFee = 5.00;
            double packagingFee = 10.00;
            double gst = itemsTotal * 0.05;

            double grandTotal = itemsTotal
                    + deliveryFee
                    + platformFee
                    + packagingFee
                    + gst;

            Order order = new Order();
            order.setUserId(userId);
            order.setDeliveryName(deliveryName);
            order.setDeliveryPhone(deliveryPhone);
            order.setDeliveryAddress(completeAddress.toString());
            order.setTotalAmount(grandTotal);
            order.setStatus("PLACED");

            /*
             * Your Order class must contain:
             * private String paymentMode;
             * public void setPaymentMode(String paymentMode)
             */
            order.setPaymentMode(paymentMode);

            int orderId = orderDAO.createOrder(order, orderItems);

            if (orderId <= 0) {
                throw new ServletException(
                        "The order could not be saved.");
            }

            session.removeAttribute("cart");
            session.setAttribute("lastOrderId", orderId);
            session.setAttribute("lastOrderTotal", grandTotal);
            session.setAttribute("lastPaymentMode", paymentMode);

            response.sendRedirect(
                    contextPath + "/confirmation?orderId=" + orderId);

        } catch (Exception e) {
            getServletContext().log(
                    "Foodwala order placement failed.", e);

            showCheckoutError(
                    request,
                    response,
                    cart,
                    "We couldn't place your order. Please try again.");
        }
    }

    private boolean isAllowedPaymentMode(String paymentMode) {
        return "COD".equals(paymentMode)
                || "UPI".equals(paymentMode)
                || "PAYTM".equals(paymentMode)
                || "NET_BANKING".equals(paymentMode)
                || "CARD".equals(paymentMode);
    }

    private String value(
            HttpServletRequest request, String parameter) {

        String result = request.getParameter(parameter);
        return result == null ? "" : result.trim();
    }

    private void showCheckoutError(
            HttpServletRequest request,
            HttpServletResponse response,
            Map<Integer, CartItem> cart,
            String message)
            throws ServletException, IOException {

        request.setAttribute("checkoutError", message);
        request.setAttribute("cart", cart);

        request.getRequestDispatcher("/Checkout.jsp")
                .forward(request, response);
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/checkout");
    }
}
