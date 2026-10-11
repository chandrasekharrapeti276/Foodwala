
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.module.CartItem" %>
<%@ page import="com.tap.module.User" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String money(double amount) {
        return String.format(java.util.Locale.US, "%.2f", amount);
    }
%>

<%
    String cp = request.getContextPath();

    if (session.getAttribute("userId") == null) {
        session.setAttribute("redirectAfterLogin", cp + "/checkout");
        response.sendRedirect(cp + "/login");
        return;
    }

    Object cartObject = request.getAttribute("cart");
    if (cartObject == null) {
        cartObject = session.getAttribute("cart");
    }

    Map<Integer, CartItem> cart = null;

    if (cartObject instanceof Map<?, ?>) {
        cart = (Map<Integer, CartItem>) cartObject;
    }

    if (cart == null || cart.isEmpty()) {
        response.sendRedirect(cp + "/restaurent");
        return;
    }

    User currentUser = (User) session.getAttribute("user");

    String defaultName = "";
    String defaultPhone = "";
    String defaultAddress = "";

    if (currentUser != null) {
        if (currentUser.getUsername() != null) {
            defaultName = currentUser.getUsername();
        }
        if (currentUser.getPhone() != null) {
            defaultPhone = currentUser.getPhone();
        }
        if (currentUser.getAddress() != null) {
            defaultAddress = currentUser.getAddress();
        }
    }

    String errorMessage = (String) request.getAttribute("checkoutError");
    String successMessage = (String) request.getAttribute("checkoutMessage");

    String nameValue = request.getParameter("deliveryName");
    if (nameValue == null) nameValue = defaultName;

    String phoneValue = request.getParameter("deliveryPhone");
    if (phoneValue == null) phoneValue = defaultPhone;

    String addressValue = request.getParameter("deliveryAddress");
    if (addressValue == null) addressValue = defaultAddress;

    String cityValue = request.getParameter("city");
    if (cityValue == null || cityValue.trim().isEmpty()) {
        cityValue = "Bengaluru";
    }

    String pincodeValue = request.getParameter("pincode");
    if (pincodeValue == null) pincodeValue = "";

    String landmarkValue = request.getParameter("landmark");
    if (landmarkValue == null) landmarkValue = "";

    String selectedPayment = request.getParameter("paymentMode");
    if (selectedPayment == null || selectedPayment.trim().isEmpty()) {
        selectedPayment = "COD";
    }

    double itemsTotal = 0.0;
    int itemCount = 0;

    for (CartItem item : cart.values()) {
        if (item != null) {
            itemsTotal += item.getTotal();
            itemCount += item.getQuantity();
        }
    }

    double deliveryFee = itemsTotal >= 499.00 ? 0.00 : 40.00;
    double platformFee = 5.00;
    double packagingFee = 10.00;
    double gst = itemsTotal * 0.05;
    double discount = 0.00;

    double grandTotal = itemsTotal + deliveryFee
            + platformFee + packagingFee + gst - discount;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Foodwala | Checkout</title>

<style>
:root {
    --bg: #09090b;
    --panel: #151518;
    --orange: #ff6b35;
    --orange-hover: #ff814f;
    --text: #f8f8fa;
    --muted: #a1a1aa;
    --border: #333339;
    --green: #35c77a;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    background: var(--bg);
    color: var(--text);
    font-family: Arial, Helvetica, sans-serif;
}

a {
    color: inherit;
    text-decoration: none;
}

.navbar {
    min-height: 70px;
    padding: 15px 5%;
    background: #111114;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    flex-wrap: wrap;
}

.brand {
    color: var(--orange);
    font-size: 27px;
    font-weight: 900;
}

.nav-links {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.nav-links a {
    color: #e4e4e7;
    font-size: 14px;
}

.nav-links a:hover,
.back-link:hover {
    color: var(--orange);
}

.page {
    max-width: 1200px;
    margin: auto;
    padding: 32px 20px 55px;
}

.page-heading {
    margin-bottom: 25px;
}

.page-heading h1 {
    margin: 0 0 8px;
    font-size: clamp(26px, 4vw, 36px);
}

.page-heading p,
.panel-subtitle {
    color: var(--muted);
    line-height: 1.6;
}

.steps {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    margin: 22px 0 28px;
}

.step {
    padding: 10px 15px;
    border: 1px solid var(--border);
    border-radius: 24px;
    color: var(--muted);
    font-size: 13px;
}

.step.active {
    border-color: var(--orange);
    background: rgba(255,107,53,.12);
    color: var(--orange);
}

.layout {
    display: grid;
    grid-template-columns: minmax(0, 1.5fr) minmax(300px, .9fr);
    gap: 24px;
    align-items: start;
}

.panel {
    min-width: 0;
    padding: 24px;
    margin-bottom: 20px;
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 16px;
}

.panel h2 {
    margin: 0 0 8px;
    font-size: 21px;
}

.panel-subtitle {
    margin: 0 0 22px;
    font-size: 13px;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 17px;
}

.field {
    min-width: 0;
}

.field.full {
    grid-column: 1 / -1;
}

.field label {
    display: block;
    margin-bottom: 8px;
    color: #e4e4e7;
    font-size: 13px;
    font-weight: 700;
}

input,
textarea {
    width: 100%;
    min-height: 46px;
    padding: 12px 13px;
    background: #0e0e11;
    color: var(--text);
    border: 1px solid var(--border);
    border-radius: 9px;
    font: inherit;
    font-size: 14px;
    outline: none;
}

textarea {
    min-height: 90px;
    resize: vertical;
}

input:focus,
textarea:focus {
    border-color: var(--orange);
    box-shadow: 0 0 0 2px rgba(255,107,53,.13);
}

input::placeholder,
textarea::placeholder {
    color: #777780;
}

.hint {
    margin-top: 7px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.5;
}

.payment-options {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
}

.payment-option {
    display: block;
    position: relative;
    margin: 0;
    cursor: pointer;
}

.payment-option input {
    position: absolute;
    width: 1px;
    height: 1px;
    min-height: 1px;
    opacity: 0;
}

.payment-card {
    display: flex;
    gap: 12px;
    align-items: flex-start;
    height: 100%;
    min-height: 94px;
    padding: 15px;
    background: #101013;
    border: 1px solid var(--border);
    border-radius: 12px;
}

.payment-option input:checked + .payment-card {
    border-color: var(--orange);
    background: rgba(255,107,53,.09);
}

.payment-option input:focus-visible + .payment-card {
    outline: 2px solid var(--orange);
    outline-offset: 3px;
}

.payment-icon {
    display: grid;
    place-items: center;
    flex: 0 0 40px;
    width: 40px;
    height: 40px;
    background: #29292e;
    border-radius: 10px;
    font-size: 20px;
}

.payment-name {
    display: block;
    margin: 2px 0 6px;
    font-size: 14px;
    font-weight: 800;
}

.payment-description {
    display: block;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.5;
    font-weight: 400;
}

.demo-note {
    margin-top: 16px;
    padding: 12px 14px;
    background: rgba(255,173,66,.07);
    color: #f2c28b;
    border: 1px solid #6b4c2d;
    border-radius: 9px;
    font-size: 12px;
    line-height: 1.6;
}

.summary {
    position: sticky;
    top: 18px;
}

.cart-items {
    display: flex;
    flex-direction: column;
    gap: 15px;
    margin-bottom: 20px;
}

.cart-item {
    display: flex;
    justify-content: space-between;
    gap: 14px;
    padding-bottom: 14px;
    border-bottom: 1px solid var(--border);
}

.item-name {
    font-size: 14px;
    font-weight: 700;
    overflow-wrap: anywhere;
}

.item-quantity {
    margin-top: 5px;
    color: var(--muted);
    font-size: 12px;
}

.item-price {
    font-size: 14px;
    font-weight: 700;
    white-space: nowrap;
}

.price-row {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin: 13px 0;
    color: #d4d4d8;
    font-size: 14px;
}

.price-row span:last-child {
    text-align: right;
    white-space: nowrap;
}

.price-row.total {
    margin-top: 18px;
    padding-top: 18px;
    border-top: 1px solid var(--border);
    font-size: 19px;
    font-weight: 900;
}

.total-value {
    color: var(--orange);
}

.delivery-free,
.discount {
    color: var(--green);
}

.place-order {
    display: block;
    width: 100%;
    min-height: 52px;
    margin-top: 22px;
    padding: 12px;
    border: 0;
    border-radius: 10px;
    background: var(--orange);
    color: white;
    font-size: 16px;
    font-weight: 800;
    cursor: pointer;
}

.place-order:hover {
    background: var(--orange-hover);
}

.place-order:disabled {
    opacity: .65;
    cursor: wait;
}

.back-link {
    display: block;
    margin-top: 16px;
    text-align: center;
    color: var(--muted);
    font-size: 13px;
}

.alert {
    padding: 14px 16px;
    margin-bottom: 20px;
    border-radius: 10px;
    font-size: 14px;
    line-height: 1.5;
}

.alert.error {
    background: rgba(255,98,98,.1);
    border: 1px solid rgba(255,98,98,.4);
    color: #ffaaaa;
}

.alert.success {
    background: rgba(53,199,122,.1);
    border: 1px solid rgba(53,199,122,.4);
    color: #9bf0bf;
}

.secure-note {
    display: flex;
    gap: 10px;
    margin-top: 17px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.5;
}

.footer {
    padding: 24px 15px;
    text-align: center;
    border-top: 1px solid var(--border);
    color: var(--muted);
    font-size: 12px;
}

@media (max-width: 850px) {
    .layout {
        grid-template-columns: 1fr;
    }

    .summary {
        position: static;
    }
}

@media (max-width: 520px) {
    .page {
        padding: 24px 13px 35px;
    }

    .navbar {
        padding: 14px 16px;
    }

    .nav-links {
        gap: 13px;
    }

    .panel {
        padding: 18px;
    }

    .form-grid,
    .payment-options {
        grid-template-columns: 1fr;
    }
}
</style>
</head>

<body>

<header class="navbar">
    <a class="brand" href="<%= cp %>/restaurent">Foodwala.</a>

    <nav class="nav-links">
        <a href="<%= cp %>/restaurent">Restaurants</a>
        <a href="<%= cp %>/cart">My Cart</a>
        <a href="<%= cp %>/myOrders">My Orders</a>
        <a href="<%= cp %>/logout">Logout</a>
    </nav>
</header>

<main class="page">

    <div class="page-heading">
        <h1>Complete your order <span style="color:var(--orange)">🍽️</span></h1>
        <p>Confirm your delivery address and choose your payment method.</p>
    </div>

    <div class="steps">
        <div class="step">✓ 1. Cart</div>
        <div class="step active">● 2. Checkout</div>
        <div class="step">3. Confirmation</div>
    </div>

    <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
        <div class="alert error"><%= escapeHtml(errorMessage) %></div>
    <% } %>

    <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
        <div class="alert success"><%= escapeHtml(successMessage) %></div>
    <% } %>

    <form method="post"
          action="<%= cp %>/placeOrder"
          id="placeOrderForm">

        <div class="layout">

            <div>

                <section class="panel">
                    <h2>📍 Delivery details</h2>
                    <p class="panel-subtitle">
                        Where should we deliver your food?
                    </p>

                    <div class="form-grid">

                        <div class="field">
                            <label for="deliveryName">Full name *</label>
                            <input type="text"
                                   id="deliveryName"
                                   name="deliveryName"
                                   value="<%= escapeHtml(nameValue) %>"
                                   maxlength="100"
                                   autocomplete="name"
                                   required>
                        </div>

                        <div class="field">
                            <label for="deliveryPhone">Mobile number *</label>
                            <input type="tel"
                                   id="deliveryPhone"
                                   name="deliveryPhone"
                                   value="<%= escapeHtml(phoneValue) %>"
                                   placeholder="10-digit mobile number"
                                   pattern="[0-9]{10}"
                                   maxlength="10"
                                   inputmode="numeric"
                                   autocomplete="tel"
                                   required>
                        </div>

                        <div class="field full">
                            <label for="deliveryAddress">House number and street *</label>
                            <textarea id="deliveryAddress"
                                      name="deliveryAddress"
                                      maxlength="500"
                                      autocomplete="street-address"
                                      required><%= escapeHtml(addressValue) %></textarea>
                        </div>

                        <div class="field">
                            <label for="city">City *</label>
                            <input type="text"
                                   id="city"
                                   name="city"
                                   value="<%= escapeHtml(cityValue) %>"
                                   maxlength="80"
                                   required>
                        </div>

                        <div class="field">
                            <label for="pincode">PIN code *</label>
                            <input type="text"
                                   id="pincode"
                                   name="pincode"
                                   value="<%= escapeHtml(pincodeValue) %>"
                                   placeholder="6-digit PIN code"
                                   pattern="[0-9]{6}"
                                   maxlength="6"
                                   inputmode="numeric"
                                   required>
                        </div>

                        <div class="field full">
                            <label for="landmark">Landmark (optional)</label>
                            <input type="text"
                                   id="landmark"
                                   name="landmark"
                                   value="<%= escapeHtml(landmarkValue) %>"
                                   maxlength="150">
                            <div class="hint">
                                A nearby shop or building can help the delivery partner.
                            </div>
                        </div>

                    </div>
                </section>

                <section class="panel">
                    <h2>💳 Choose payment method</h2>
                    <p class="panel-subtitle">
                        Select one payment option for your order.
                    </p>

                    <div class="payment-options">

                        <label class="payment-option">
                            <input type="radio"
                                   name="paymentMode"
                                   value="COD"
                                   <%= "COD".equals(selectedPayment)
                                       || "CASH_ON_DELIVERY".equals(selectedPayment)
                                       ? "checked" : "" %>
                                   required>
                            <span class="payment-card">
                                <span class="payment-icon">💵</span>
                                <span>
                                    <span class="payment-name">Cash on Delivery</span>
                                    <span class="payment-description">
                                        Pay when your food arrives.
                                    </span>
                                </span>
                            </span>
                        </label>

                        <label class="payment-option">
                            <input type="radio"
                                   name="paymentMode"
                                   value="UPI"
                                   <%= "UPI".equals(selectedPayment) ? "checked" : "" %>>
                            <span class="payment-card">
                                <span class="payment-icon">📱</span>
                                <span>
                                    <span class="payment-name">UPI</span>
                                    <span class="payment-description">
                                        Select UPI as your payment method.
                                    </span>
                                </span>
                            </span>
                        </label>

                        <label class="payment-option">
                            <input type="radio"
                                   name="paymentMode"
                                   value="PAYTM"
                                   <%= "PAYTM".equals(selectedPayment) ? "checked" : "" %>>
                            <span class="payment-card">
                                <span class="payment-icon">🔵</span>
                                <span>
                                    <span class="payment-name">Paytm</span>
                                    <span class="payment-description">
                                        Choose Paytm for payment.
                                    </span>
                                </span>
                            </span>
                        </label>

                        <label class="payment-option">
                            <input type="radio"
                                   name="paymentMode"
                                   value="NET_BANKING"
                                   <%= "NET_BANKING".equals(selectedPayment) ? "checked" : "" %>>
                            <span class="payment-card">
                                <span class="payment-icon">🏦</span>
                                <span>
                                    <span class="payment-name">Net Banking</span>
                                    <span class="payment-description">
                                        Choose your bank's payment option.
                                    </span>
                                </span>
                            </span>
                        </label>

                        <label class="payment-option">
                            <input type="radio"
                                   name="paymentMode"
                                   value="CARD"
                                   <%= "CARD".equals(selectedPayment) ? "checked" : "" %>>
                            <span class="payment-card">
                                <span class="payment-icon">💳</span>
                                <span>
                                    <span class="payment-name">Credit / Debit Card</span>
                                    <span class="payment-description">
                                        Select card as your payment method.
                                    </span>
                                </span>
                            </span>
                        </label>

                    </div>

                    <div class="demo-note">
                        <strong>Demo payment:</strong>
                        Online payment options are saved as the selected method;
                        this page does not process actual payments. Never enter
                        your UPI PIN, bank password, card details or OTP here.
                    </div>
                </section>

            </div>

            <aside class="panel summary">

                <h2>🧾 Order summary</h2>
                <p class="panel-subtitle">
                    <%= itemCount %> item(s) in your order
                </p>

                <div class="cart-items">
                    <% for (CartItem item : cart.values()) {
                        if (item == null) continue;
                    %>
                        <div class="cart-item">
                            <div>
                                <div class="item-name">
                                    <%= escapeHtml(item.getItemName()) %>
                                </div>
                                <div class="item-quantity">
                                    Qty: <%= item.getQuantity() %>
                                </div>
                            </div>

                            <div class="item-price">
                                ₹<%= money(item.getTotal()) %>
                            </div>
                        </div>
                    <% } %>
                </div>

                <div class="price-row">
                    <span>Item total</span>
                    <span>₹<%= money(itemsTotal) %></span>
                </div>

                <div class="price-row">
                    <span>Delivery fee</span>
                    <span class="<%= deliveryFee == 0 ? "delivery-free" : "" %>">
                        <%= deliveryFee == 0
                            ? "FREE" : "₹" + money(deliveryFee) %>
                    </span>
                </div>

                <div class="price-row">
                    <span>Platform fee</span>
                    <span>₹<%= money(platformFee) %></span>
                </div>

                <div class="price-row">
                    <span>Packaging fee</span>
                    <span>₹<%= money(packagingFee) %></span>
                </div>

                <div class="price-row">
                    <span>Estimated GST (5%)</span>
                    <span>₹<%= money(gst) %></span>
                </div>

                <div class="price-row total">
                    <span>Grand total</span>
                    <span class="total-value">₹<%= money(grandTotal) %></span>
                </div>

                <div class="hint">
                    Delivery is free when your item total is ₹499 or more.
                    Fees and tax are demo calculations.
                </div>

                <button type="submit"
                        class="place-order"
                        id="placeOrderButton">
                    Place Order · ₹<%= money(grandTotal) %>
                </button>

                <a href="<%= cp %>/cart" class="back-link">
                    ← Return to cart
                </a>

                <div class="secure-note">
                    <span>🔒</span>
                    <span>
                        Your delivery details are submitted to Foodwala
                        to process your order.
                    </span>
                </div>

            </aside>
        </div>
    </form>
</main>

<footer class="footer">
    &copy; <%= java.time.Year.now() %> Foodwala · Fresh food, delivered with care.
</footer>

<script>
(function () {
    const form = document.getElementById("placeOrderForm");
    const button = document.getElementById("placeOrderButton");
    const phone = document.getElementById("deliveryPhone");
    const pincode = document.getElementById("pincode");

    phone.addEventListener("input", function () {
        this.value = this.value.replace(/[^0-9]/g, "").slice(0, 10);
    });

    pincode.addEventListener("input", function () {
        this.value = this.value.replace(/[^0-9]/g, "").slice(0, 6);
    });

    form.addEventListener("submit", function (event) {
        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
            return;
        }

        const payment = form.querySelector(
            'input[name="paymentMode"]:checked'
        );

        if (!payment) {
            event.preventDefault();
            alert("Please select a payment method.");
            return;
        }

        button.disabled = true;
        button.textContent = "Placing your order...";
    });
})();
</script>

</body>
</html>
