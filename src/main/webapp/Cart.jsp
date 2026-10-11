
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.module.CartItem" %>

<%!
    private String esc(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String money(double value) {
        if (Double.isNaN(value) || Double.isInfinite(value)) {
            value = 0.0;
        }

        return String.format(
            Locale.US,
            "%.2f",
            Math.max(0.0, value)
        );
    }
%>

<%
    String contextPath = request.getContextPath();

    // Read the cart prepared by CartController.
    Map<Integer, CartItem> cart =
        (Map<Integer, CartItem>) request.getAttribute("cart");

    double itemsTotal = 0.0;
    int totalItems = 0;
    int validCartLines = 0;

    if (cart != null) {
        for (CartItem item : cart.values()) {
            if (item != null && item.getQuantity() > 0) {
                double lineTotal = item.getTotal();

                if (!Double.isNaN(lineTotal)
                        && !Double.isInfinite(lineTotal)
                        && lineTotal >= 0) {
                    itemsTotal += lineTotal;
                    totalItems += item.getQuantity();
                    validCartLines++;
                }
            }
        }
    }

    double deliveryFee = validCartLines > 0 ? 40.00 : 0.00;
    double platformFee = validCartLines > 0 ? 5.00 : 0.00;
    double packagingFee = validCartLines > 0 ? 10.00 : 0.00;
    double discount = 0.00;
    double gst = itemsTotal * 0.05;

    double grandTotal = itemsTotal
        + deliveryFee
        + platformFee
        + packagingFee
        + gst
        - discount;

    boolean loggedIn = session.getAttribute("userId") != null;

    Object usernameValue = session.getAttribute("username");
    String username = "Food Lover";

    if (usernameValue != null
            && !usernameValue.toString().trim().isEmpty()) {
        username = usernameValue.toString().trim();
    }

    String cartMessage = request.getAttribute("cartMessage") == null
        ? ""
        : String.valueOf(request.getAttribute("cartMessage"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="theme-color" content="#090a0c">
<meta name="description"
      content="Review your Foodwala cart and continue to checkout.">

<title>Foodwala | Your Cart</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap"
      rel="stylesheet">

<style>
:root {
    --bg: #090a0c;
    --panel: #15161a;
    --panel-alt: #1d1f24;
    --orange: #ff6b35;
    --orange-light: #ff9a70;
    --text: #f8f8f8;
    --muted: #92939b;
    --border: rgba(255,255,255,.09);
    --green: #8af2a1;
    --red: #ff8d8d;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;
    background:
        radial-gradient(circle at 10% 0%, rgba(255,107,53,.09), transparent 28%),
        radial-gradient(circle at 90% 15%, rgba(255,170,70,.05), transparent 25%),
        var(--bg);
    color: var(--text);
    font-family: Inter, Arial, sans-serif;
}

a {
    color: inherit;
    text-decoration: none;
}

button {
    font: inherit;
}

a:focus-visible,
button:focus-visible {
    outline: 2px solid var(--orange);
    outline-offset: 3px;
}

.navbar {
    position: sticky;
    top: 0;
    z-index: 10;
    background: rgba(11,11,13,.96);
    border-bottom: 1px solid var(--border);
    backdrop-filter: blur(14px);
}

.nav-inner {
    width: min(1180px, 94%);
    min-height: 70px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 18px;
    flex-wrap: wrap;
    padding: 12px 0;
}

.logo {
    color: var(--orange);
    font-family: Poppins, sans-serif;
    font-size: 27px;
    font-weight: 800;
    letter-spacing: -.8px;
    white-space: nowrap;
}

.logo span {
    color: white;
}

.nav-links {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 6px;
}

.nav-links a,
.nav-user {
    padding: 9px 12px;
    border-radius: 9px;
    color: #b5b5bc;
    font-size: 12px;
    font-weight: 700;
}

.nav-links a:hover {
    background: #19191e;
    color: white;
}

.nav-links .active {
    background: var(--orange);
    color: #21110a;
}

.nav-user {
    color: var(--muted);
}

.page {
    width: min(1180px, 94%);
    margin: 36px auto 70px;
}

.hero {
    position: relative;
    overflow: hidden;
    margin-bottom: 24px;
    padding: clamp(24px, 4vw, 36px);
    border: 1px solid #302a27;
    border-radius: 20px;
    background:
        radial-gradient(circle at 85% 10%, rgba(255,137,70,.15), transparent 30%),
        linear-gradient(135deg, #181416, #101012);
}

.hero-label {
    display: inline-block;
    margin-bottom: 12px;
    padding: 7px 11px;
    border: 1px solid #3b281f;
    border-radius: 30px;
    background: rgba(255,107,53,.08);
    color: var(--orange-light);
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .8px;
    text-transform: uppercase;
}

.hero h1 {
    margin: 0 0 9px;
    font-family: Poppins, sans-serif;
    font-size: clamp(30px, 4vw, 42px);
    line-height: 1.2;
    letter-spacing: -.8px;
}

.hero p {
    max-width: 600px;
    margin: 0;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.7;
}

.notice {
    margin-bottom: 20px;
    padding: 13px 15px;
    border: 1px solid rgba(82,210,125,.25);
    border-radius: 10px;
    background: rgba(82,210,125,.08);
    color: var(--green);
    font-size: 13px;
    line-height: 1.6;
    overflow-wrap: anywhere;
}

.layout {
    display: grid;
    grid-template-columns: minmax(0, 1.5fr) minmax(300px, .8fr);
    align-items: start;
    gap: 24px;
}

.panel,
.summary {
    min-width: 0;
    border: 1px solid #28282e;
    border-radius: 18px;
    background: linear-gradient(180deg, #151519, #111114);
    box-shadow: 0 15px 40px rgba(0,0,0,.2);
}

.panel {
    padding: 23px;
}

.panel-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 8px;
}

.panel-heading h2,
.summary h2 {
    margin: 0;
    font-family: Poppins, sans-serif;
    font-size: 20px;
}

.count {
    padding: 6px 10px;
    border: 1px solid #3a2a22;
    border-radius: 20px;
    background: #211a17;
    color: var(--orange-light);
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
}

.subtitle {
    margin: 0 0 18px;
    color: #85858e;
    font-size: 12px;
    line-height: 1.6;
}

.cart-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
    gap: 13px 18px;
    align-items: center;
    padding: 19px 0;
    border-top: 1px solid #28282e;
}

.item-info {
    min-width: 0;
}

.item-name {
    margin: 0 0 7px;
    color: #f1f1f3;
    font-size: 15px;
    font-weight: 800;
    line-height: 1.45;
    overflow-wrap: anywhere;
}

.unit-price {
    margin: 0;
    color: var(--muted);
    font-size: 12px;
}

.unit-price strong {
    color: #d9d9de;
}

.remove-form {
    margin-top: 9px;
}

.remove-button {
    padding: 4px 0;
    border: 0;
    background: transparent;
    color: #9999a2;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
}

.remove-button:hover {
    color: var(--red);
}

.quantity-form {
    margin: 0;
}

.quantity-control {
    display: inline-flex;
    align-items: center;
    overflow: hidden;
    border: 1px solid #34343a;
    border-radius: 10px;
    background: #0d0d10;
}

.quantity-button {
    width: 38px;
    height: 38px;
    border: 0;
    background: transparent;
    color: var(--orange-light);
    font-size: 21px;
    font-weight: 700;
    cursor: pointer;
}

.quantity-button:hover:not(:disabled) {
    background: #2a1c16;
}

.quantity-button:disabled {
    opacity: .35;
    cursor: not-allowed;
}

.quantity-value {
    min-width: 36px;
    text-align: center;
    color: white;
    font-size: 13px;
    font-weight: 800;
}

.item-total {
    grid-column: 2;
    text-align: right;
    color: white;
    font-size: 15px;
    font-weight: 800;
    white-space: nowrap;
}

.summary {
    position: sticky;
    top: 92px;
    padding: 23px;
}

.summary h2 {
    margin-bottom: 5px;
}

.summary-subtitle {
    margin: 0 0 19px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.6;
}

.price-breakdown {
    padding-top: 8px;
    border-top: 1px solid #29292f;
}

.price-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 9px 0;
    color: #a1a1aa;
    font-size: 12px;
}

.price-row strong {
    color: #dedee2;
    font-weight: 750;
    white-space: nowrap;
}

.price-row.discount strong {
    color: var(--green);
}

.grand-total {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-top: 10px;
    padding-top: 16px;
    border-top: 1px solid #38383e;
}

.grand-total-label {
    font-size: 14px;
    font-weight: 800;
}

.grand-total-value {
    color: var(--orange);
    font-size: 24px;
    font-weight: 900;
    white-space: nowrap;
}

.savings {
    margin-top: 15px;
    padding: 11px 12px;
    border: 1px solid #203c2a;
    border-radius: 10px;
    background: rgba(54,180,99,.07);
    color: #75dc94;
    font-size: 11px;
    line-height: 1.6;
}

.actions {
    display: grid;
    gap: 10px;
    margin-top: 18px;
}

.action {
    min-height: 46px;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 11px 14px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 800;
    text-align: center;
    transition: transform .18s ease, background .18s ease;
}

.checkout-button {
    background: linear-gradient(135deg, #ff6b35, #ff8a45);
    color: #21110a;
}

.checkout-button:hover {
    transform: translateY(-1px);
    background: #ff895b;
}

.continue-button {
    border: 1px solid #303037;
    background: #17171b;
    color: #c5c5cc;
}

.continue-button:hover {
    background: #202026;
    color: white;
}

.secure-note {
    margin-top: 13px;
    color: #777780;
    text-align: center;
    font-size: 10px;
}

.empty {
    padding: 54px 15px;
    text-align: center;
}

.empty-icon {
    margin-bottom: 14px;
    font-size: 43px;
}

.empty h2 {
    margin: 0 0 10px;
    font-family: Poppins, sans-serif;
    font-size: 22px;
}

.empty p {
    max-width: 390px;
    margin: 0 auto 22px;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.7;
}

.browse-button {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    min-height: 44px;
    padding: 0 18px;
    border-radius: 10px;
    background: var(--orange);
    color: #21110a;
    font-size: 13px;
    font-weight: 800;
}

.footer {
    padding: 28px 18px;
    border-top: 1px solid #202025;
    background: #080809;
    color: #777780;
    text-align: center;
    font-size: 11px;
}

.footer strong {
    color: var(--orange);
}

@media (max-width: 900px) {
    .layout {
        grid-template-columns: 1fr;
    }

    .summary {
        position: static;
    }
}

@media (max-width: 600px) {
    .nav-inner {
        align-items: flex-start;
        flex-direction: column;
        gap: 8px;
    }

    .nav-links {
        width: 100%;
        gap: 3px;
    }

    .nav-links a,
    .nav-user {
        padding: 8px;
        font-size: 11px;
    }

    .page {
        width: 92%;
        margin-top: 24px;
    }

    .panel,
    .summary {
        padding: 17px;
        border-radius: 15px;
    }

    .cart-row {
        gap: 12px;
    }

    .quantity-button {
        width: 34px;
        height: 36px;
    }

    .quantity-value {
        min-width: 30px;
    }

    .grand-total-value {
        font-size: 21px;
    }
}

@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        scroll-behavior: auto !important;
        transition: none !important;
    }
}
</style>
</head>

<body>

<header class="navbar">
    <div class="nav-inner">

        <a class="logo" href="<%= contextPath %>/restaurent">
            Food<span>wala.</span>
        </a>

        <nav class="nav-links" aria-label="Main navigation">
            <a href="<%= contextPath %>/restaurent">Restaurants</a>

            <a class="active" href="<%= contextPath %>/cart">
                Cart (<%= totalItems %>)
            </a>

            <% if (loggedIn) { %>
                <a href="<%= contextPath %>/myOrders">My Orders</a>
                <span class="nav-user">Hi, <%= esc(username) %></span>
                <a href="<%= contextPath %>/logout">Logout</a>
            <% } else { %>
                <a href="<%= contextPath %>/Login.jsp">Login</a>
            <% } %>
        </nav>

    </div>
</header>

<main class="page">

    <section class="hero">
        <span class="hero-label">Your food basket</span>
        <h1>Your Cart</h1>
        <p>
            Review your selected dishes, change quantities,
            and continue to checkout when you're ready.
        </p>
    </section>

    <% if (!cartMessage.trim().isEmpty()) { %>
        <div class="notice" role="status" aria-live="polite">
            <%= esc(cartMessage) %>
        </div>
    <% } %>

    <div class="layout">

        <section class="panel" aria-labelledby="itemsHeading">

            <% if (validCartLines == 0) { %>

                <div class="empty">
                    <div class="empty-icon" aria-hidden="true">&#128722;</div>
                    <h2>Your cart is empty</h2>
                    <p>
                        Your next delicious meal is waiting.
                        Browse our restaurants and add something you love.
                    </p>
                    <a class="browse-button"
                       href="<%= contextPath %>/restaurent">
                        Browse Restaurants
                    </a>
                </div>

            <% } else { %>

                <div class="panel-heading">
                    <h2 id="itemsHeading">Your items</h2>
                    <span class="count">
                        <%= totalItems %>
                        <%= totalItems == 1 ? "item" : "items" %>
                    </span>
                </div>

                <p class="subtitle">
                    Restaurant discounts are already reflected in item prices.
                </p>

                <% for (CartItem item : cart.values()) {
                    if (item == null || item.getQuantity() <= 0) {
                        continue;
                    }

                    String itemName = item.getItemName() == null
                        ? "Food item" : item.getItemName();

                    int quantity = item.getQuantity();
                    int menuId = item.getMenuId();
                %>

                    <article class="cart-row">

                        <div class="item-info">
                            <h3 class="item-name">
                                <%= esc(itemName) %>
                            </h3>

                            <p class="unit-price">
                                <strong>
                                    ₹<%= money(item.getPrice()) %>
                                </strong>
                                each
                            </p>

                            <form class="remove-form"
                                  action="<%= contextPath %>/updateCart"
                                  method="post">

                                <input type="hidden"
                                       name="menuId"
                                       value="<%= menuId %>">

                                <input type="hidden"
                                       name="quantity"
                                       value="0">

                                <button type="submit"
                                        class="remove-button">
                                    Remove item
                                </button>
                            </form>
                        </div>

                        <form class="quantity-form"
                              action="<%= contextPath %>/updateCart"
                              method="post">

                            <input type="hidden"
                                   name="menuId"
                                   value="<%= menuId %>">

                            <!-- Do not add a hidden quantity input here.
                                 The clicked button submits the new quantity. -->
                            <div class="quantity-control">

                                <button type="submit"
                                        class="quantity-button"
                                        name="quantity"
                                        value="<%= quantity - 1 %>"
                                        aria-label="Decrease <%= esc(itemName) %> quantity"
                                        <%= quantity <= 1 ? "disabled" : "" %>>
                                    −
                                </button>

                                <span class="quantity-value">
                                    <%= quantity %>
                                </span>

                                <button type="submit"
                                        class="quantity-button"
                                        name="quantity"
                                        value="<%= quantity + 1 %>"
                                        aria-label="Increase <%= esc(itemName) %> quantity"
                                        <%= quantity >= 99 ? "disabled" : "" %>>
                                    +
                                </button>

                            </div>
                        </form>

                        <div class="item-total">
                            ₹<%= money(item.getTotal()) %>
                        </div>

                    </article>

                <% } %>

            <% } %>

        </section>

        <% if (validCartLines > 0) { %>

            <aside class="summary" aria-labelledby="summaryHeading">

                <h2 id="summaryHeading">Order summary</h2>
                <p class="summary-subtitle">
                    Review your estimated order total.
                </p>

                <div class="price-breakdown">

                    <div class="price-row">
                        <span>Items total</span>
                        <strong>₹<%= money(itemsTotal) %></strong>
                    </div>

                    <div class="price-row">
                        <span>Delivery fee</span>
                        <strong>₹<%= money(deliveryFee) %></strong>
                    </div>

                    <div class="price-row">
                        <span>Platform fee</span>
                        <strong>₹<%= money(platformFee) %></strong>
                    </div>

                    <div class="price-row">
                        <span>Packaging fee</span>
                        <strong>₹<%= money(packagingFee) %></strong>
                    </div>

                    <div class="price-row">
                        <span>Estimated GST (5%)</span>
                        <strong>₹<%= money(gst) %></strong>
                    </div>

                    <% if (discount > 0) { %>
                        <div class="price-row discount">
                            <span>Additional discount</span>
                            <strong>− ₹<%= money(discount) %></strong>
                        </div>
                    <% } %>

                </div>

                <div class="grand-total">
                    <span class="grand-total-label">Grand total</span>
                    <span class="grand-total-value">
                        ₹<%= money(grandTotal) %>
                    </span>
                </div>

                <div class="savings">
                    ✓ Restaurant discounts have already been applied
                    to your item prices.
                </div>

                <div class="actions">
                    <a class="action checkout-button"
                       href="<%= contextPath %>/checkout">
                        Proceed to Checkout →
                    </a>

                    <a class="action continue-button"
                       href="<%= contextPath %>/restaurent">
                        ← Continue Shopping
                    </a>
                </div>

                <div class="secure-note">
                    Review your delivery details at checkout.
                </div>

            </aside>

        <% } %>

    </div>

</main>

<footer class="footer">
    <strong>Foodwala</strong>
    &nbsp;•&nbsp; Fresh food. Great restaurants. Happy moments.
</footer>

</body>
</html>
