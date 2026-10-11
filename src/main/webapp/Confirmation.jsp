<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.module.Order" %>
<%@ page import="com.tap.module.OrderItem" %>
<%@ page import="com.tap.module.Menu" %>
<%@ page import="com.tap.module.CartItem" %>


<%!
    /*
     * =========================================================
     * HTML ESCAPE HELPER
     * =========================================================
     */
    private String escapeHtml(String value) {

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>


<%
    /*
     * =========================================================
     * BASIC DATA
     * =========================================================
     */

    String contextPath = request.getContextPath();


    /*
     * =========================================================
     * LOGIN CHECK
     * =========================================================
     */

    Object userId = session.getAttribute("userId");

    if (userId == null) {

        response.sendRedirect(
            contextPath + "/Login.jsp"
        );

        return;
    }


    /*
     * =========================================================
     * ORDER
     * =========================================================
     */

    Order order =
        (Order) request.getAttribute("order");

    if (order == null) {

        response.sendRedirect(
            contextPath + "/orderHistory"
        );

        return;
    }


    /*
     * =========================================================
     * ORDER ITEMS
     * =========================================================
     */

    List<OrderItem> orderItems =
        (List<OrderItem>)
            request.getAttribute("orderItems");


    /*
     * =========================================================
     * MENU ITEMS
     * =========================================================
     */

    Map<Integer, Menu> menuItems =
        (Map<Integer, Menu>)
            request.getAttribute("menuItems");


    /*
     * =========================================================
     * TOTAL ITEMS
     * =========================================================
     */

    Integer totalItems =
        (Integer) request.getAttribute("totalItems");

    if (totalItems == null) {
        totalItems = 0;
    }


    /*
     * =========================================================
     * CART COUNT
     * =========================================================
     */

    int cartCount = 0;

    Object cartObject =
        session.getAttribute("cart");

    if (cartObject instanceof Map<?, ?>) {

        Map<?, ?> cart =
            (Map<?, ?>) cartObject;

        for (Object value : cart.values()) {

            if (value instanceof CartItem) {

                CartItem cartItem =
                    (CartItem) value;

                if (cartItem.getQuantity() > 0) {

                    cartCount +=
                        cartItem.getQuantity();
                }
            }
        }
    }


    /*
     * =========================================================
     * USERNAME
     * =========================================================
     */

    String username =
        (String) session.getAttribute("username");

    if (username == null ||
        username.trim().isEmpty()) {

        username = "Food Lover";
    }


    /*
     * =========================================================
     * ORDER STATUS
     * =========================================================
     */

    String status =
        order.getStatus();

    if (status == null ||
        status.trim().isEmpty()) {

        status = "PLACED";
    }

    status =
        status.trim()
              .toUpperCase();

    String statusDisplay =
        status.replace("_", " ");


    /*
     * =========================================================
     * DELIVERY DETAILS
     * =========================================================
     */

    String deliveryName =
        order.getDeliveryName();

    if (deliveryName == null ||
        deliveryName.trim().isEmpty()) {

        deliveryName = username;
    }


    String deliveryPhone =
        order.getDeliveryPhone();

    if (deliveryPhone == null ||
        deliveryPhone.trim().isEmpty()) {

        deliveryPhone = "Not provided";
    }


    String deliveryAddress =
        order.getDeliveryAddress();

    if (deliveryAddress == null ||
        deliveryAddress.trim().isEmpty()) {

        deliveryAddress =
            "Delivery address not available";
    }


    /*
     * =========================================================
     * STATUS HELPERS
     * =========================================================
     */

    boolean isPlaced =
        "PLACED".equals(status);

    boolean isConfirmed =
        "CONFIRMED".equals(status);

    boolean isPreparing =
        "PREPARING".equals(status);

    boolean isReady =
        "READY".equals(status);

    boolean isOutForDelivery =
        "OUT_FOR_DELIVERY".equals(status);

    boolean isDelivered =
        "DELIVERED".equals(status);

    boolean isCancelled =
        "CANCELLED".equals(status);


    /*
     * =========================================================
     * ORDER DATE
     * =========================================================
     */

    String orderDateText =
        "Recently";

    if (order.getOrderDate() != null) {

        orderDateText =
            order.getOrderDate().toString();
    }


    /*
     * =========================================================
     * STATUS TRACKER
     * =========================================================
     */

    boolean placedDone =
        isPlaced ||
        isConfirmed ||
        isPreparing ||
        isReady ||
        isOutForDelivery ||
        isDelivered;

    boolean confirmedDone =
        isConfirmed ||
        isPreparing ||
        isReady ||
        isOutForDelivery ||
        isDelivered;

    boolean preparingDone =
        isPreparing ||
        isReady ||
        isOutForDelivery ||
        isDelivered;

    boolean readyDone =
        isReady ||
        isOutForDelivery ||
        isDelivered;

    boolean outForDeliveryDone =
        isOutForDelivery ||
        isDelivered;
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <meta name="description"
          content="Foodwala order confirmation">

    <title>Foodwala | Order Confirmed</title>


    <style>

        * {
            box-sizing: border-box;
        }


        html {
            scroll-behavior: smooth;
        }


        body {
            margin: 0;
            min-height: 100vh;

            font-family:
                "Segoe UI",
                Arial,
                Helvetica,
                sans-serif;

            color: #f5f5f5;

            background:
                radial-gradient(
                    circle at 10% 5%,
                    rgba(255, 107, 53, 0.10),
                    transparent 27%
                ),
                radial-gradient(
                    circle at 90% 20%,
                    rgba(255, 159, 67, 0.06),
                    transparent 25%
                ),
                #09090b;
        }


        a {
            text-decoration: none;
        }


        /* =====================================================
           NAVBAR
           ===================================================== */

        .navbar {
            position: sticky;
            top: 0;
            z-index: 1000;

            background:
                rgba(10, 10, 12, 0.94);

            border-bottom:
                1px solid rgba(255, 255, 255, 0.07);

            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);

            box-shadow:
                0 8px 30px rgba(0, 0, 0, 0.30);
        }


        .navbar-inner {
            width: 100%;
            max-width: 1240px;
            min-height: 68px;

            margin: 0 auto;
            padding: 0 22px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;
        }


        .brand {
            color: #ffffff;

            font-size: 27px;
            font-weight: 900;

            letter-spacing: -0.8px;

            white-space: nowrap;
        }


        .brand span {
            color: #ff6b35;
        }


        .nav-links {
            display: flex;
            align-items: center;
            justify-content: flex-end;

            gap: 5px;

            flex-wrap: wrap;
        }


        .nav-link {
            color: #c8c8ce;

            padding: 9px 11px;

            border-radius: 9px;

            font-size: 13px;
            font-weight: 700;

            transition:
                color 0.2s ease,
                background 0.2s ease;
        }


        .nav-link:hover {
            color: #ffffff;

            background:
                rgba(255, 255, 255, 0.07);
        }


        .nav-link.active {
            color: #ffffff;

            background:
                rgba(255, 107, 53, 0.12);

            border:
                1px solid rgba(255, 107, 53, 0.18);
        }


        .user-name {
            color: #92929a;

            padding: 9px 10px;

            max-width: 150px;

            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;

            font-size: 13px;
            font-weight: 700;
        }


        /* =====================================================
           CART BADGE
           ===================================================== */

        .cart-link {
            position: relative;
        }


        .cart-badge {
            position: absolute;

            top: 0;
            right: -2px;

            min-width: 18px;
            height: 18px;

            padding: 0 5px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 20px;

            background: #ff6b35;
            color: #ffffff;

            font-size: 10px;
            font-weight: 900;

            border: 2px solid #0a0a0c;
        }


        /* =====================================================
           MAIN PAGE
           ===================================================== */

        .page {
            width: 100%;
            max-width: 1120px;

            margin: 0 auto;

            padding: 42px 22px 75px;
        }


        /* =====================================================
           SUCCESS HERO
           ===================================================== */

        .success-card {
            position: relative;

            overflow: hidden;

            text-align: center;

            padding: 48px 30px 42px;

            background:
                linear-gradient(
                    145deg,
                    #17171b,
                    #101013
                );

            border:
                1px solid rgba(255, 255, 255, 0.08);

            border-radius: 24px;

            box-shadow:
                0 22px 55px rgba(0, 0, 0, 0.34);
        }


        .success-card::before {
            content: "";

            position: absolute;

            width: 280px;
            height: 280px;

            border-radius: 50%;

            background:
                rgba(255, 107, 53, 0.07);

            top: -170px;
            left: -100px;
        }


        .success-card::after {
            content: "";

            position: absolute;

            width: 260px;
            height: 260px;

            border-radius: 50%;

            background:
                rgba(23, 148, 82, 0.055);

            right: -120px;
            bottom: -160px;
        }


        .success-icon {
            position: relative;
            z-index: 1;

            width: 84px;
            height: 84px;

            margin: 0 auto;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            background:
                linear-gradient(
                    135deg,
                    #179452,
                    #25b765
                );

            color: #ffffff;

            font-size: 42px;
            font-weight: 900;

            box-shadow:
                0 15px 35px rgba(23, 148, 82, 0.22);
        }


        .success-card h1 {
            position: relative;
            z-index: 1;

            margin: 23px 0 10px;

            color: #ffffff;

            font-size:
                clamp(30px, 5vw, 44px);

            font-weight: 900;

            letter-spacing: -1px;
        }


        .success-card p {
            position: relative;
            z-index: 1;

            margin: 0 auto;

            max-width: 650px;

            color: #92929a;

            font-size: 15px;

            line-height: 1.7;
        }


        .order-number {
            position: relative;
            z-index: 1;

            display: inline-flex;

            align-items: center;
            justify-content: center;

            margin-top: 22px;

            padding: 10px 17px;

            border-radius: 30px;

            background:
                rgba(255, 107, 53, 0.10);

            border:
                1px solid rgba(255, 107, 53, 0.20);

            color: #ff996f;

            font-size: 14px;
            font-weight: 900;
        }


        /* =====================================================
           CONTENT GRID
           ===================================================== */

        .content-grid {
            display: grid;

            grid-template-columns:
                minmax(0, 1.3fr)
                minmax(300px, 0.75fr);

            gap: 22px;

            margin-top: 22px;
        }


        /* =====================================================
           CARD
           ===================================================== */

        .card {
            background:
                linear-gradient(
                    145deg,
                    #161619,
                    #101013
                );

            border:
                1px solid rgba(255, 255, 255, 0.075);

            border-radius: 18px;

            padding: 24px;

            box-shadow:
                0 15px 38px rgba(0, 0, 0, 0.27);
        }


        .card + .card {
            margin-top: 20px;
        }


        .card-title {
            margin: 0 0 6px;

            color: #ffffff;

            font-size: 20px;
            font-weight: 900;

            letter-spacing: -0.3px;
        }


        .card-subtitle {
            margin: 0 0 20px;

            color: #808089;

            font-size: 13px;

            line-height: 1.5;
        }


        /* =====================================================
           DELIVERY
           ===================================================== */

        .delivery-box {
            padding: 18px;

            border-radius: 14px;

            background:
                rgba(255, 255, 255, 0.025);

            border:
                1px solid rgba(255, 255, 255, 0.065);
        }


        .delivery-row {
            display: flex;

            align-items: flex-start;

            gap: 13px;

            margin-bottom: 17px;
        }


        .delivery-row:last-child {
            margin-bottom: 0;
        }


        .delivery-icon {
            width: 40px;
            height: 40px;

            flex-shrink: 0;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 11px;

            background:
                rgba(255, 107, 53, 0.10);

            border:
                1px solid rgba(255, 107, 53, 0.15);

            font-size: 17px;
        }


        .delivery-info {
            min-width: 0;
        }


        .delivery-label {
            margin-bottom: 4px;

            color: #707079;

            font-size: 11px;
            font-weight: 800;

            text-transform: uppercase;

            letter-spacing: 0.7px;
        }


        .delivery-value {
            color: #e6e6e9;

            font-size: 14px;
            font-weight: 700;

            line-height: 1.55;

            overflow-wrap: anywhere;
        }


        /* =====================================================
           ORDER ITEMS
           ===================================================== */

        .item-list {
            display: grid;

            gap: 11px;
        }


        .order-item {
            display: flex;

            align-items: center;

            gap: 14px;

            padding: 12px;

            background:
                rgba(255, 255, 255, 0.025);

            border:
                1px solid rgba(255, 255, 255, 0.06);

            border-radius: 13px;

            transition:
                border-color 0.2s ease,
                background 0.2s ease;
        }


        .order-item:hover {
            background:
                rgba(255, 255, 255, 0.035);

            border-color:
                rgba(255, 107, 53, 0.16);
        }


        .item-image {
            width: 64px;
            height: 64px;

            flex-shrink: 0;

            object-fit: cover;

            border-radius: 11px;

            background: #18181b;

            border:
                1px solid rgba(255, 255, 255, 0.06);
        }


        .item-info {
            flex: 1;

            min-width: 0;
        }


        .item-name {
            color: #f3f3f5;

            font-size: 15px;
            font-weight: 800;

            white-space: nowrap;

            overflow: hidden;
            text-overflow: ellipsis;
        }


        .item-meta {
            margin-top: 5px;

            color: #7f7f87;

            font-size: 12px;
        }


        .item-total {
            color: #ff8155;

            font-size: 14px;
            font-weight: 900;

            white-space: nowrap;
        }


        .no-items {
            padding: 25px;

            text-align: center;

            color: #777780;

            background:
                rgba(255, 255, 255, 0.025);

            border-radius: 12px;

            border:
                1px solid rgba(255, 255, 255, 0.05);
        }


        /* =====================================================
           STATUS
           ===================================================== */

        .status-box {
            margin-bottom: 22px;

            padding: 17px;

            border-radius: 14px;

            background:
                rgba(255, 107, 53, 0.065);

            border:
                1px solid rgba(255, 107, 53, 0.16);
        }


        .status-label {
            color: #777780;

            font-size: 11px;
            font-weight: 800;

            text-transform: uppercase;

            letter-spacing: 0.7px;
        }


        .status-value {
            margin-top: 6px;

            color: #ff8c63;

            font-size: 20px;
            font-weight: 900;
        }


        .cancelled-status {
            color: #ff7d7d;

            background:
                rgba(220, 70, 70, 0.07);

            border:
                1px solid rgba(220, 70, 70, 0.18);

            padding: 14px;

            border-radius: 12px;

            margin-bottom: 20px;

            font-size: 13px;
            font-weight: 700;
        }


        /* =====================================================
           STATUS TRACKER
           ===================================================== */

        .tracker {
            display: grid;

            gap: 13px;

            margin-bottom: 24px;
        }


        .tracker-step {
            display: flex;

            align-items: center;

            gap: 11px;

            color: #62626a;

            font-size: 12px;
            font-weight: 700;
        }


        .tracker-dot {
            width: 12px;
            height: 12px;

            flex-shrink: 0;

            border-radius: 50%;

            background: #2a2a2e;

            border: 2px solid #3a3a40;
        }


        .tracker-step.completed {
            color: #bfc0c5;
        }


        .tracker-step.completed .tracker-dot {
            background: #179452;

            border-color: #179452;

            box-shadow:
                0 0 10px rgba(23, 148, 82, 0.30);
        }


        .tracker-step.current {
            color: #ff8b60;
        }


        .tracker-step.current .tracker-dot {
            background: #ff6b35;

            border-color: #ff6b35;

            box-shadow:
                0 0 12px rgba(255, 107, 53, 0.35);
        }


        /* =====================================================
           TOTAL
           ===================================================== */

        .total-box {
            margin-top: 18px;

            padding-top: 18px;

            border-top:
                1px solid rgba(255, 255, 255, 0.07);

            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 15px;
        }


        .total-label {
            color: #aaaab1;

            font-size: 15px;
            font-weight: 800;
        }


        .total-value {
            color: #ff8155;

            font-size: 25px;
            font-weight: 900;

            white-space: nowrap;
        }


        /* =====================================================
           ORDER DATE
           ===================================================== */

        .order-date {
            margin-top: 13px;

            color: #66666e;

            font-size: 11px;

            text-align: right;
        }


        /* =====================================================
           ACTIONS
           ===================================================== */

        .actions {
            display: grid;

            gap: 10px;

            margin-top: 22px;
        }


        .primary-button,
        .secondary-button {
            display: flex;

            align-items: center;
            justify-content: center;

            width: 100%;

            min-height: 45px;

            padding: 12px 16px;

            border-radius: 10px;

            text-align: center;

            font-size: 13px;
            font-weight: 900;

            transition:
                transform 0.2s ease,
                box-shadow 0.2s ease,
                background 0.2s ease;
        }


        .primary-button {
            color: #ffffff;

            background:
                linear-gradient(
                    135deg,
                    #ff743f,
                    #f05220
                );

            border:
                1px solid #ff6b35;

            box-shadow:
                0 9px 20px rgba(255, 107, 53, 0.14);
        }


        .secondary-button {
            color: #c8c8cd;

            background:
                rgba(255, 255, 255, 0.025);

            border:
                1px solid rgba(255, 255, 255, 0.09);
        }


        .primary-button:hover,
        .secondary-button:hover {
            transform: translateY(-1px);
        }


        .secondary-button:hover {
            color: #ffffff;

            border-color:
                rgba(255, 107, 53, 0.22);

            background:
                rgba(255, 107, 53, 0.07);
        }


        /* =====================================================
           THANK YOU
           ===================================================== */

        .thank-you-icon {
            width: 44px;
            height: 44px;

            display: flex;

            align-items: center;
            justify-content: center;

            margin-bottom: 13px;

            border-radius: 12px;

            background:
                rgba(255, 107, 53, 0.10);

            border:
                1px solid rgba(255, 107, 53, 0.16);

            font-size: 20px;
        }


        .thank-you-text {
            margin: 0;

            color: #808089;

            line-height: 1.7;

            font-size: 13px;
        }


        /* =====================================================
           FOOTER
           ===================================================== */

        .footer {
            padding: 25px 20px;

            background: #0d0d0f;

            border-top:
                1px solid rgba(255, 255, 255, 0.06);

            color: #707078;

            text-align: center;

            font-size: 12px;
        }


        .footer strong {
            color: #ff6b35;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 850px) {

            .content-grid {
                grid-template-columns: 1fr;
            }
        }


        @media (max-width: 700px) {

            .navbar-inner {
                min-height: auto;

                padding: 13px 15px;

                flex-direction: column;

                align-items: center;

                gap: 9px;
            }


            .nav-links {
                justify-content: center;
            }


            .page {
                padding: 30px 15px 55px;
            }


            .success-card {
                padding: 38px 20px 34px;
            }


            .success-card h1 {
                font-size: 30px;
            }


            .card {
                padding: 20px;
            }
        }


        @media (max-width: 500px) {

            .brand {
                font-size: 24px;
            }


            .nav-links {
                width: 100%;

                gap: 2px;
            }


            .nav-link,
            .user-name {
                padding: 7px 7px;

                font-size: 11px;
            }


            .user-name {
                max-width: 90px;
            }


            .success-icon {
                width: 72px;
                height: 72px;

                font-size: 36px;
            }


            .success-card h1 {
                font-size: 27px;

                letter-spacing: -0.6px;
            }


            .success-card p {
                font-size: 13px;
            }


            .order-item {
                align-items: flex-start;
            }


            .item-image {
                width: 55px;
                height: 55px;
            }


            .item-total {
                font-size: 13px;
            }


            .total-value {
                font-size: 22px;
            }
        }

    </style>

</head>


<body>


<!-- =====================================================
     NAVBAR
     ===================================================== -->

<nav class="navbar">

    <div class="navbar-inner">


        <a
            class="brand"
            href="<%= contextPath %>/restaurent">

            Foodwala<span>.</span>

        </a>


        <div class="nav-links">


            <a
                class="nav-link"
                href="<%= contextPath %>/restaurent">

                Restaurants

            </a>


            <a
                class="nav-link active"
                href="<%= contextPath %>/orderHistory">

                Orders

            </a>


            <a
                class="nav-link"
                href="<%= contextPath %>/favorites">

                Favorites

            </a>


            <a
                class="nav-link cart-link"
                href="<%= contextPath %>/cart">

                Cart

                <% if (cartCount > 0) { %>

                    <span class="cart-badge">

                        <%= cartCount %>

                    </span>

                <% } %>

            </a>


            <span class="user-name">

                Hi, <%= escapeHtml(username) %>

            </span>


            <a
                class="nav-link"
                href="<%= contextPath %>/logout">

                Logout

            </a>


        </div>

    </div>

</nav>


<!-- =====================================================
     MAIN
     ===================================================== -->

<main class="page">


    <!-- =================================================
         SUCCESS HERO
         ================================================= -->

    <section class="success-card">


        <div class="success-icon">

            ✓

        </div>


        <h1>

            Order placed successfully!

        </h1>


        <p>

            Thank you for ordering with Foodwala.
            Your order has been received and is being processed.

        </p>


        <div class="order-number">

            Order #<%= order.getOrderId() %>

        </div>


    </section>


    <!-- =================================================
         CONTENT
         ================================================= -->

    <div class="content-grid">


        <!-- =============================================
             LEFT COLUMN
             ============================================= -->

        <div>


            <!-- DELIVERY DETAILS -->

            <section class="card">

                <h2 class="card-title">

                    Delivery details

                </h2>


                <p class="card-subtitle">

                    Your order will be delivered to the following address.

                </p>


                <div class="delivery-box">


                    <div class="delivery-row">

                        <div class="delivery-icon">

                            👤

                        </div>


                        <div class="delivery-info">

                            <div class="delivery-label">

                                Deliver to

                            </div>


                            <div class="delivery-value">

                                <%= escapeHtml(deliveryName) %>

                            </div>

                        </div>

                    </div>


                    <div class="delivery-row">

                        <div class="delivery-icon">

                            📞

                        </div>


                        <div class="delivery-info">

                            <div class="delivery-label">

                                Phone

                            </div>


                            <div class="delivery-value">

                                <%= escapeHtml(deliveryPhone) %>

                            </div>

                        </div>

                    </div>


                    <div class="delivery-row">

                        <div class="delivery-icon">

                            🏠

                        </div>


                        <div class="delivery-info">

                            <div class="delivery-label">

                                Address

                            </div>


                            <div class="delivery-value">

                                <%= escapeHtml(deliveryAddress) %>

                            </div>

                        </div>

                    </div>


                </div>

            </section>


            <!-- ORDER ITEMS -->

            <section class="card">

                <h2 class="card-title">

                    Ordered items

                </h2>


                <p class="card-subtitle">

                    <%= totalItems %>

                    item<%= totalItems == 1 ? "" : "s" %>

                    in this order.

                </p>


                <div class="item-list">


                    <% if (orderItems != null &&
                           !orderItems.isEmpty()) { %>


                        <% for (OrderItem item : orderItems) {

                            Menu menu = null;

                            if (menuItems != null) {

                                menu =
                                    menuItems.get(
                                        item.getMenuId()
                                    );
                            }


                            String itemName =
                                menu != null &&
                                menu.getItemName() != null &&
                                !menu.getItemName()
                                    .trim()
                                    .isEmpty()

                                ? menu.getItemName()
                                : "Food Item";


                            String imagePath =
                                menu != null
                                ? menu.getImagePath()
                                : null;


                            if (imagePath == null ||
                                imagePath.trim().isEmpty()) {

                                imagePath =
                                    contextPath
                                    + "/images/foodwala-placeholder.png";
                            }

                        %>


                            <div class="order-item">


                                <img
                                    class="item-image"
                                    src="<%= escapeHtml(imagePath) %>"
                                    alt="<%= escapeHtml(itemName) %>"
                                    loading="lazy"
                                    onerror="this.onerror=null;this.src='<%= contextPath %>/images/foodwala-placeholder.png';"
                                >


                                <div class="item-info">


                                    <div class="item-name">

                                        <%= escapeHtml(itemName) %>

                                    </div>


                                    <div class="item-meta">

                                        Qty:
                                        <%= item.getQuantity() %>

                                    </div>


                                </div>


                                <div class="item-total">

                                    ₹<%= String.format(
                                        "%.2f",
                                        item.getItemTotal()
                                    ) %>

                                </div>


                            </div>


                        <% } %>


                    <% } else { %>


                        <div class="no-items">

                            Order item details are unavailable.

                        </div>


                    <% } %>


                </div>

            </section>


        </div>


        <!-- =============================================
             RIGHT COLUMN
             ============================================= -->

        <aside>


            <!-- ORDER STATUS -->

            <section class="card">


                <% if (isCancelled) { %>


                    <div class="cancelled-status">

                        This order has been cancelled.

                    </div>


                <% } else { %>


                    <div class="status-box">

                        <div class="status-label">

                            Current status

                        </div>


                        <div class="status-value">

                            <%= escapeHtml(statusDisplay) %>

                        </div>

                    </div>


                    <!-- STATUS TRACKER -->

                    <div class="tracker">


                        <div class="tracker-step
                            <%= placedDone ? "completed" : "" %>
                            <%= isPlaced ? "current" : "" %>">

                            <span class="tracker-dot"></span>

                            Order placed

                        </div>


                        <div class="tracker-step
                            <%= confirmedDone ? "completed" : "" %>
                            <%= isConfirmed ? "current" : "" %>">

                            <span class="tracker-dot"></span>

                            Confirmed

                        </div>


                        <div class="tracker-step
                            <%= preparingDone ? "completed" : "" %>
                            <%= isPreparing ? "current" : "" %>">

                            <span class="tracker-dot"></span>

                            Preparing

                        </div>


                        <div class="tracker-step
                            <%= readyDone ? "completed" : "" %>
                            <%= isReady ? "current" : "" %>">

                            <span class="tracker-dot"></span>

                            Ready

                        </div>


                        <div class="tracker-step
                            <%= outForDeliveryDone ? "completed" : "" %>
                            <%= isOutForDelivery ? "current" : "" %>">

                            <span class="tracker-dot"></span>

                            Out for delivery

                        </div>


                        <div class="tracker-step
                            <%= isDelivered ? "completed current" : "" %>">

                            <span class="tracker-dot"></span>

                            Delivered

                        </div>


                    </div>


                <% } %>


                <!-- TOTAL -->

                <div class="total-box">

                    <span class="total-label">

                        Order total

                    </span>


                    <span class="total-value">

                        ₹<%= String.format(
                            "%.2f",
                            order.getTotalAmount()
                        ) %>

                    </span>

                </div>


                <!-- ORDER DATE -->

                <div class="order-date">

                    Placed:
                    <%= escapeHtml(orderDateText) %>

                </div>


                <!-- ACTIONS -->

                <div class="actions">


                    <a
                        class="primary-button"
                        href="<%= contextPath %>/orderHistory">

                        View My Orders

                    </a>


                    <a
                        class="secondary-button"
                        href="<%= contextPath %>/restaurent">

                        Order More Food

                    </a>


                    <a
                        class="secondary-button"
                        href="<%= contextPath %>/favorites">

                        My Favorites

                    </a>


                </div>


            </section>


            <!-- THANK YOU -->

            <section class="card">


                <div class="thank-you-icon">

                    💛

                </div>


                <h2 class="card-title">

                    Thank you!

                </h2>


                <p class="thank-you-text">

                    Your order has been successfully
                    received by Foodwala.
                    You can track its progress anytime
                    from the Orders section.

                </p>


            </section>


        </aside>


    </div>


</main>


<!-- =====================================================
     FOOTER
     ===================================================== -->

<footer class="footer">

    <strong>Foodwala</strong>

    &nbsp;&bull;&nbsp;

    Fresh food. Great restaurants.
    Happy moments.

</footer>


</body>

</html>