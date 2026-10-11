<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.module.Order" %>
<%@ page import="com.tap.module.CartItem" %>

<%
    /*
     * ============================================================
     * FOODWALA - MY ORDERS
     * ============================================================
     */

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    List<Order> orders =
            (List<Order>) request.getAttribute("orders");

    /*
     * If the controller did not provide orders, reload through
     * OrderHistoryController instead of rendering a broken page.
     */
    if (orders == null) {
        response.sendRedirect(
                request.getContextPath() + "/orderHistory"
        );
        return;
    }

    /*
     * ============================================================
     * CART COUNT
     * ============================================================
     */
    int cartCount = 0;

    Object cartObject =
            session.getAttribute("cart");

    if (cartObject instanceof Map<?, ?>) {

        Map<?, ?> cart =
                (Map<?, ?>) cartObject;

        for (Object value : cart.values()) {

            if (value instanceof CartItem) {

                CartItem item =
                        (CartItem) value;

                if (item.getQuantity() > 0) {
                    cartCount += item.getQuantity();
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Orders | Foodwala</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            min-height: 100vh;
            font-family:
                Inter,
                "Segoe UI",
                Arial,
                Helvetica,
                sans-serif;

            color: #ffffff;

            background:
                radial-gradient(
                    circle at 10% 0%,
                    rgba(255, 106, 0, 0.12),
                    transparent 28%
                ),
                radial-gradient(
                    circle at 90% 15%,
                    rgba(255, 159, 67, 0.06),
                    transparent 25%
                ),
                #08080a;

            background-attachment: fixed;
        }

        a {
            text-decoration: none;
        }

        button,
        a {
            -webkit-tap-highlight-color: transparent;
        }


        /* =========================================================
           NAVBAR
           ========================================================= */

        .navbar {
            position: sticky;
            top: 0;
            z-index: 1000;

            width: 100%;
            min-height: 72px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 0 6%;

            background:
                rgba(10, 10, 12, 0.94);

            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);

            border-bottom:
                1px solid rgba(255, 255, 255, 0.07);

            box-shadow:
                0 8px 30px rgba(0, 0, 0, 0.28);
        }

        .brand {
            color: #ff6a00;

            font-size: 28px;
            font-weight: 900;

            letter-spacing: -1px;
        }

        .brand span {
            color: #ffffff;
        }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .nav-link {
            min-height: 40px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            padding: 0 15px;

            color: #b8b8bd;

            border-radius: 10px;

            font-size: 14px;
            font-weight: 700;

            transition:
                color 0.2s ease,
                background 0.2s ease,
                transform 0.2s ease;
        }

        .nav-link:hover {
            color: #ffffff;

            background:
                rgba(255, 255, 255, 0.06);

            transform: translateY(-1px);
        }

        .nav-link.cart-link {
            color: #ffffff;

            border:
                1px solid rgba(255, 106, 0, 0.35);

            background:
                rgba(255, 106, 0, 0.08);
        }

        .nav-link.cart-link:hover {
            color: #ffffff;

            background:
                rgba(255, 106, 0, 0.16);
        }

        .cart-count {
            min-width: 21px;
            height: 21px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            margin-left: 6px;

            padding: 0 5px;

            border-radius: 50%;

            color: #ffffff;

            background: #ff6a00;

            font-size: 10px;
            font-weight: 900;
        }


        /* =========================================================
           PAGE
           ========================================================= */

        .page-wrapper {
            width: min(92%, 1120px);

            margin: 0 auto;

            padding:
                48px 0 80px;
        }

        .page-header {
            margin-bottom: 30px;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;

            gap: 8px;

            margin-bottom: 12px;

            color: #ff9a55;

            font-size: 11px;
            font-weight: 800;

            letter-spacing: 1.5px;

            text-transform: uppercase;
        }

        .eyebrow-dot {
            width: 7px;
            height: 7px;

            border-radius: 50%;

            background: #ff6a00;

            box-shadow:
                0 0 12px rgba(255, 106, 0, 0.7);
        }

        .page-header h1 {
            color: #ffffff;

            font-size:
                clamp(30px, 4vw, 42px);

            font-weight: 900;

            letter-spacing: -1.2px;

            margin-bottom: 8px;
        }

        .page-header h1 span {
            color: #ff6a00;
        }

        .page-header p {
            color: #85858c;

            font-size: 14px;

            line-height: 1.6;
        }


        /* =========================================================
           ORDER CARD
           ========================================================= */

        .order-card {
            position: relative;

            margin-bottom: 22px;

            overflow: hidden;

            background:
                linear-gradient(
                    145deg,
                    rgba(24, 24, 28, 0.98),
                    rgba(14, 14, 17, 0.98)
                );

            border:
                1px solid rgba(255, 255, 255, 0.075);

            border-radius: 20px;

            box-shadow:
                0 18px 50px rgba(0, 0, 0, 0.30);

            transition:
                transform 0.25s ease,
                border-color 0.25s ease,
                box-shadow 0.25s ease;
        }

        .order-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;
            right: 0;

            height: 2px;

            background:
                linear-gradient(
                    90deg,
                    transparent,
                    rgba(255, 106, 0, 0.8),
                    transparent
                );

            opacity: 0.65;
        }

        .order-card:hover {
            transform: translateY(-3px);

            border-color:
                rgba(255, 106, 0, 0.30);

            box-shadow:
                0 22px 60px rgba(0, 0, 0, 0.42);
        }


        /* =========================================================
           ORDER TOP
           ========================================================= */

        .order-top {
            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 20px;

            padding: 22px 24px;

            border-bottom:
                1px solid rgba(255, 255, 255, 0.06);
        }

        .order-number {
            color: #ffffff;

            font-size: 19px;
            font-weight: 850;

            margin-bottom: 6px;
        }

        .order-number span {
            color: #ff6a00;
        }

        .order-date {
            color: #74747b;

            font-size: 12px;
        }


        /* =========================================================
           STATUS BADGES
           ========================================================= */

        .status {
            display: inline-flex;
            align-items: center;

            gap: 8px;

            padding: 8px 13px;

            border-radius: 999px;

            color: #ffb27d;

            background:
                rgba(255, 106, 0, 0.09);

            border:
                1px solid rgba(255, 106, 0, 0.24);

            font-size: 11px;
            font-weight: 850;

            letter-spacing: 0.6px;

            white-space: nowrap;
        }

        .status-dot {
            width: 7px;
            height: 7px;

            border-radius: 50%;

            background: #ff6a00;

            box-shadow:
                0 0 9px rgba(255, 106, 0, 0.65);
        }

        .status-green {
            color: #58dc8b;

            background:
                rgba(37, 199, 111, 0.08);

            border-color:
                rgba(37, 199, 111, 0.25);
        }

        .status-green .status-dot {
            background: #25c76f;

            box-shadow:
                0 0 9px rgba(37, 199, 111, 0.6);
        }

        .status-blue {
            color: #72bfff;

            background:
                rgba(64, 150, 255, 0.08);

            border-color:
                rgba(64, 150, 255, 0.25);
        }

        .status-blue .status-dot {
            background: #4096ff;

            box-shadow:
                0 0 9px rgba(64, 150, 255, 0.6);
        }

        .status-cancelled {
            color: #ff7770;

            background:
                rgba(231, 76, 60, 0.08);

            border-color:
                rgba(231, 76, 60, 0.25);
        }

        .status-cancelled .status-dot {
            background: #e74c3c;

            box-shadow:
                0 0 9px rgba(231, 76, 60, 0.5);
        }


        /* =========================================================
           ORDER CONTENT
           ========================================================= */

        .order-content {
            padding: 24px;
        }

        .foodwala-row {
            display: flex;
            align-items: center;

            gap: 14px;

            margin-bottom: 22px;
        }

        .food-icon {
            width: 50px;
            height: 50px;

            flex-shrink: 0;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 15px;

            background:
                linear-gradient(
                    135deg,
                    #ff7b22,
                    #e85000
                );

            font-size: 23px;

            box-shadow:
                0 8px 24px rgba(255, 106, 0, 0.20);
        }

        .foodwala-name strong {
            display: block;

            color: #ffffff;

            font-size: 15px;

            margin-bottom: 4px;
        }

        .foodwala-name span {
            color: #77777e;

            font-size: 12px;
        }


        /* =========================================================
           ORDER SUMMARY
           ========================================================= */

        .summary-box {
            display: grid;

            grid-template-columns: 1fr auto;

            align-items: center;

            gap: 20px;

            padding: 18px 20px;

            margin-bottom: 25px;

            border-radius: 14px;

            background:
                rgba(255, 255, 255, 0.025);

            border:
                1px solid rgba(255, 255, 255, 0.065);
        }

        .summary-label {
            color: #77777e;

            font-size: 11px;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: 0.7px;

            margin-bottom: 5px;
        }

        .summary-value {
            color: #ffffff;

            font-size: 25px;
            font-weight: 900;
        }

        .rupee {
            color: #ff6a00;
        }

        .order-id-small {
            color: #696970;

            font-size: 12px;

            text-align: right;
        }

        .order-id-small span {
            color: #d6d6da;

            font-weight: 700;
        }


        /* =========================================================
           TRACKING
           ========================================================= */

        .tracking-container {
            width: 100%;

            padding:
                18px 12px 20px;

            margin-bottom: 22px;

            border-radius: 15px;

            background:
                rgba(255, 255, 255, 0.018);

            border:
                1px solid rgba(255, 255, 255, 0.05);
        }

        .tracking-row {
            position: relative;

            display: grid;

            grid-template-columns:
                repeat(5, 1fr);

            align-items: center;

            width: 100%;
        }

        .tracking-row::before {
            content: "";

            position: absolute;

            left: 10%;
            right: 10%;

            top: 50%;

            height: 2px;

            transform: translateY(-50%);

            background: #29292e;

            z-index: 0;
        }

        .tracking-point {
            position: relative;

            z-index: 1;

            display: flex;

            justify-content: center;
            align-items: center;
        }

        .track-circle {
            width: 30px;
            height: 30px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            color: #696970;

            background: #1c1c20;

            border:
                1px solid #36363b;

            font-size: 11px;
            font-weight: 900;

            box-shadow:
                0 0 0 5px #111114;
        }

        .track-completed {
            color: #ffffff;

            background: #25b968;

            border-color: #25b968;

            box-shadow:
                0 0 0 5px #111114,
                0 0 14px rgba(37, 185, 104, 0.22);
        }

        .track-active {
            color: #ffffff;

            background: #ff6a00;

            border-color: #ff6a00;

            box-shadow:
                0 0 0 5px #111114,
                0 0 18px rgba(255, 106, 0, 0.34);
        }

        .track-cancelled {
            color: #ffffff;

            background: #e74c3c;

            border-color: #e74c3c;

            box-shadow:
                0 0 0 5px #111114,
                0 0 15px rgba(231, 76, 60, 0.25);
        }

        .tracking-labels {
            display: grid;

            grid-template-columns:
                repeat(5, 1fr);

            width: 100%;

            margin-top: 12px;
        }

        .tracking-label {
            color: #77777e;

            text-align: center;

            font-size: 10px;

            line-height: 1.3;
        }

        .tracking-label.active-label {
            color: #eeeeee;

            font-weight: 700;
        }


        /* =========================================================
           CANCELLED MESSAGE
           ========================================================= */

        .cancelled-message {
            display: flex;

            align-items: center;

            gap: 10px;

            padding: 13px 15px;

            margin-bottom: 21px;

            border-radius: 11px;

            color: #ff8b84;

            background:
                rgba(231, 76, 60, 0.06);

            border:
                1px solid rgba(231, 76, 60, 0.18);

            font-size: 12px;

            line-height: 1.5;
        }

        .cancelled-icon {
            width: 25px;
            height: 25px;

            flex-shrink: 0;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            background:
                rgba(231, 76, 60, 0.14);

            color: #ff7068;

            font-weight: 900;
        }


        /* =========================================================
           ACTIONS
           ========================================================= */

        .action-area {
            display: flex;

            justify-content: flex-end;
            align-items: center;

            gap: 10px;

            flex-wrap: wrap;
        }

        .action-button {
            min-height: 42px;

            display: inline-flex;

            align-items: center;
            justify-content: center;

            padding: 0 18px;

            border-radius: 10px;

            font-size: 13px;
            font-weight: 800;

            transition:
                transform 0.2s ease,
                background 0.2s ease,
                border-color 0.2s ease,
                box-shadow 0.2s ease;
        }

        .action-button:hover {
            transform: translateY(-2px);
        }

        .view-details {
            color: #dddddf;

            background:
                rgba(255, 255, 255, 0.035);

            border:
                1px solid rgba(255, 255, 255, 0.12);
        }

        .view-details:hover {
            color: #ffffff;

            background:
                rgba(255, 255, 255, 0.08);

            border-color:
                rgba(255, 255, 255, 0.22);
        }

        .order-again {
            color: #ffffff;

            background:
                linear-gradient(
                    135deg,
                    #ff7820,
                    #ed5700
                );

            border:
                1px solid #ff6a00;

            box-shadow:
                0 7px 20px rgba(255, 106, 0, 0.16);
        }

        .order-again:hover {
            box-shadow:
                0 10px 28px rgba(255, 106, 0, 0.26);
        }

        .cancel-order {
            color: #ff7770;

            background:
                rgba(231, 76, 60, 0.04);

            border:
                1px solid rgba(231, 76, 60, 0.42);
        }

        .cancel-order:hover {
            color: #ffffff;

            background: #e74c3c;

            border-color: #e74c3c;
        }


        /* =========================================================
           EMPTY ORDERS
           ========================================================= */

        .empty-container {
            text-align: center;

            padding: 72px 25px;

            border-radius: 20px;

            background:
                linear-gradient(
                    145deg,
                    #18181c,
                    #101013
                );

            border:
                1px solid rgba(255, 255, 255, 0.07);

            box-shadow:
                0 18px 50px rgba(0, 0, 0, 0.25);
        }

        .empty-icon {
            width: 78px;
            height: 78px;

            margin: 0 auto 20px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            background:
                rgba(255, 106, 0, 0.10);

            border:
                1px solid rgba(255, 106, 0, 0.18);

            font-size: 31px;
        }

        .empty-container h2 {
            color: #ffffff;

            font-size: 24px;
            font-weight: 850;

            margin-bottom: 9px;
        }

        .empty-container p {
            color: #77777e;

            font-size: 13px;

            margin-bottom: 25px;
        }

        .browse-button {
            display: inline-flex;

            align-items: center;
            justify-content: center;

            min-height: 44px;

            padding: 0 23px;

            border-radius: 10px;

            color: #ffffff;

            background:
                linear-gradient(
                    135deg,
                    #ff7820,
                    #ed5700
                );

            border:
                1px solid #ff6a00;

            font-size: 13px;
            font-weight: 800;

            box-shadow:
                0 8px 22px rgba(255, 106, 0, 0.16);

            transition: 0.2s ease;
        }

        .browse-button:hover {
            transform: translateY(-2px);

            box-shadow:
                0 11px 28px rgba(255, 106, 0, 0.25);
        }


        /* =========================================================
           CONTINUE SHOPPING
           ========================================================= */

        .continue-section {
            text-align: center;

            margin-top: 34px;
        }

        .continue-button {
            display: inline-flex;

            align-items: center;
            justify-content: center;

            min-height: 42px;

            padding: 0 21px;

            border-radius: 10px;

            color: #ff8b4c;

            background:
                rgba(255, 106, 0, 0.04);

            border:
                1px solid rgba(255, 106, 0, 0.30);

            font-size: 13px;
            font-weight: 800;

            transition: 0.2s ease;
        }

        .continue-button:hover {
            color: #ffffff;

            background:
                rgba(255, 106, 0, 0.12);

            border-color: #ff6a00;

            transform: translateY(-1px);
        }


        /* =========================================================
           TABLET
           ========================================================= */

        @media (max-width: 800px) {

            .navbar {
                padding: 0 4%;
            }

            .page-wrapper {
                width: 94%;

                padding-top: 35px;
            }

            .tracking-label {
                font-size: 9px;
            }
        }


        /* =========================================================
           MOBILE
           ========================================================= */

        @media (max-width: 600px) {

            .navbar {
                min-height: 66px;
            }

            .brand {
                font-size: 24px;
            }

            .nav-right {
                gap: 4px;
            }

            .nav-link {
                min-height: 36px;

                padding: 0 9px;

                font-size: 12px;
            }

            .page-wrapper {
                width: 94%;

                padding:
                    30px 0 60px;
            }

            .page-header {
                margin-bottom: 24px;
            }

            .page-header h1 {
                font-size: 29px;
            }

            .page-header p {
                font-size: 13px;
            }

            .order-top {
                flex-direction: column;

                align-items: flex-start;

                padding: 18px;
            }

            .order-content {
                padding: 18px;
            }

            .summary-box {
                grid-template-columns: 1fr;

                gap: 12px;
            }

            .order-id-small {
                text-align: left;
            }

            .tracking-container {
                padding:
                    16px 7px 18px;
            }

            .tracking-row::before {
                left: 8%;
                right: 8%;
            }

            .track-circle {
                width: 27px;
                height: 27px;

                font-size: 10px;
            }

            .tracking-label {
                font-size: 8px;
            }

            .action-area {
                width: 100%;

                flex-direction: column;

                align-items: stretch;
            }

            .action-button {
                width: 100%;
            }

            .continue-button {
                width: 100%;

                max-width: 320px;
            }
        }


        /* =========================================================
           VERY SMALL MOBILE
           ========================================================= */

        @media (max-width: 380px) {

            .nav-link {
                padding: 0 7px;

                font-size: 11px;
            }

            .brand {
                font-size: 22px;
            }

            .tracking-label {
                font-size: 7px;
            }

            .order-number {
                font-size: 17px;
            }

            .summary-value {
                font-size: 22px;
            }
        }

    </style>

</head>


<body>


    <!-- =========================================================
         NAVBAR
         ========================================================= -->

    <nav class="navbar">

        <a
            href="<%= request.getContextPath() %>/restaurent"
            class="brand">

            Food<span>wala</span>

        </a>


        <div class="nav-right">

            <a
                href="<%= request.getContextPath() %>/restaurent"
                class="nav-link">

                Restaurants

            </a>


            <a
                href="<%= request.getContextPath() %>/cart"
                class="nav-link cart-link">

                🛒 Cart

                <% if (cartCount > 0) { %>

                    <span class="cart-count">
                        <%= cartCount %>
                    </span>

                <% } %>

            </a>

        </div>

    </nav>


    <!-- =========================================================
         MAIN
         ========================================================= -->

    <main class="page-wrapper">


        <!-- PAGE HEADER -->

        <div class="page-header">

            <div class="eyebrow">

                <span class="eyebrow-dot"></span>

                Foodwala Account

            </div>


            <h1>

                My <span>Orders</span>

            </h1>


            <p>

                Track your orders, reorder your favourites,
                and manage your Foodwala deliveries.

            </p>

        </div>


        <% if (orders.isEmpty()) { %>


            <!-- =================================================
                 EMPTY STATE
                 ================================================= -->

            <div class="empty-container">

                <div class="empty-icon">
                    🍽️
                </div>


                <h2>
                    No orders yet
                </h2>


                <p>
                    Your delicious journey starts with your first order.
                </p>


                <a
                    href="<%= request.getContextPath() %>/restaurent"
                    class="browse-button">

                    Explore Restaurants

                </a>

            </div>


        <% } else { %>


            <!-- =================================================
                 ORDERS
                 ================================================= -->

            <%
                for (Order order : orders) {

                    String status =
                            order.getStatus() == null
                            ? "PLACED"
                            : order.getStatus()
                                    .trim()
                                    .toUpperCase();

                    boolean cancelled =
                            "CANCELLED".equals(status);

                    boolean placed =
                            "PLACED".equals(status);

                    boolean confirmed =
                            "CONFIRMED".equals(status);

                    boolean preparing =
                            "PREPARING".equals(status);

                    boolean ready =
                            "READY".equals(status);

                    boolean outForDelivery =
                            "OUT_FOR_DELIVERY".equals(status);

                    boolean delivered =
                            "DELIVERED".equals(status);

                    boolean activeOrder =
                            !cancelled && !delivered;

                    String displayStatus =
                            status.replace("_", " ");

                    /*
                     * Tracking state.
                     *
                     * Stage 1 = PLACED
                     * Stage 2 = CONFIRMED
                     * Stage 3 = PREPARING / READY
                     * Stage 4 = OUT_FOR_DELIVERY
                     * Stage 5 = DELIVERED
                     */

                    boolean placedCompleted =
                            confirmed ||
                            preparing ||
                            ready ||
                            outForDelivery ||
                            delivered;

                    boolean confirmedCompleted =
                            preparing ||
                            ready ||
                            outForDelivery ||
                            delivered;

                    boolean preparingCompleted =
                            ready ||
                            outForDelivery ||
                            delivered;

                    boolean deliveryCompleted =
                            delivered;
            %>


                <!-- =================================================
                     ORDER CARD
                     ================================================= -->

                <div class="order-card">


                    <!-- ORDER HEADER -->

                    <div class="order-top">

                        <div>

                            <div class="order-number">

                                Order

                                <span>
                                    #<%= order.getOrderId() %>
                                </span>

                            </div>


                            <div class="order-date">

                                <%= order.getOrderDate() %>

                            </div>

                        </div>


                        <!-- STATUS -->

                        <% if (cancelled) { %>

                            <div class="status status-cancelled">

                                <span class="status-dot"></span>

                                CANCELLED

                            </div>


                        <% } else if (delivered) { %>

                            <div class="status status-green">

                                <span class="status-dot"></span>

                                DELIVERED

                            </div>


                        <% } else if (outForDelivery) { %>

                            <div class="status status-blue">

                                <span class="status-dot"></span>

                                OUT FOR DELIVERY

                            </div>


                        <% } else if (confirmed || preparing || ready) { %>

                            <div class="status">

                                <span class="status-dot"></span>

                                <%= displayStatus %>

                            </div>


                        <% } else { %>

                            <div class="status status-green">

                                <span class="status-dot"></span>

                                <%= displayStatus %>

                            </div>

                        <% } %>

                    </div>


                    <!-- ORDER CONTENT -->

                    <div class="order-content">


                        <!-- FOODWALA BRAND -->

                        <div class="foodwala-row">

                            <div class="food-icon">
                                🍴
                            </div>


                            <div class="foodwala-name">

                                <strong>
                                    Foodwala Order
                                </strong>

                                <span>
                                    Your food delivery order
                                </span>

                            </div>

                        </div>


                        <!-- TOTAL -->

                        <div class="summary-box">

                            <div>

                                <div class="summary-label">
                                    Order Total
                                </div>


                                <div class="summary-value">

                                    <span class="rupee">
                                        &#8377;
                                    </span>

                                    <%= String.format(
                                            Locale.US,
                                            "%.2f",
                                            order.getTotalAmount()
                                    ) %>

                                </div>

                            </div>


                            <div class="order-id-small">

                                Order ID

                                <span>
                                    #<%= order.getOrderId() %>
                                </span>

                            </div>

                        </div>


                        <!-- =================================================
                             ACTIVE ORDER TRACKING
                             ================================================= -->

                        <% if (activeOrder) { %>

                            <div class="tracking-container">

                                <div class="tracking-row">


                                    <!-- PLACED -->

                                    <div class="tracking-point">

                                        <div class="track-circle
                                            <%= placed
                                                    ? "track-active"
                                                    : (placedCompleted
                                                            ? "track-completed"
                                                            : "") %>">

                                            <%= placed
                                                    ? "1"
                                                    : (placedCompleted
                                                            ? "✓"
                                                            : "1") %>

                                        </div>

                                    </div>


                                    <!-- CONFIRMED -->

                                    <div class="tracking-point">

                                        <div class="track-circle
                                            <%= confirmed
                                                    ? "track-active"
                                                    : (confirmedCompleted
                                                            ? "track-completed"
                                                            : "") %>">

                                            <%= confirmed
                                                    ? "2"
                                                    : (confirmedCompleted
                                                            ? "✓"
                                                            : "2") %>

                                        </div>

                                    </div>


                                    <!-- PREPARING -->

                                    <div class="tracking-point">

                                        <div class="track-circle
                                            <%= preparing || ready
                                                    ? "track-active"
                                                    : (preparingCompleted
                                                            ? "track-completed"
                                                            : "") %>">

                                            <%= preparing || ready
                                                    ? "3"
                                                    : (preparingCompleted
                                                            ? "✓"
                                                            : "3") %>

                                        </div>

                                    </div>


                                    <!-- OUT FOR DELIVERY -->

                                    <div class="tracking-point">

                                        <div class="track-circle
                                            <%= outForDelivery
                                                    ? "track-active"
                                                    : (deliveryCompleted
                                                            ? "track-completed"
                                                            : "") %>">

                                            <%= outForDelivery
                                                    ? "4"
                                                    : (deliveryCompleted
                                                            ? "✓"
                                                            : "4") %>

                                        </div>

                                    </div>


                                    <!-- DELIVERED -->

                                    <div class="tracking-point">

                                        <div class="track-circle">

                                            5

                                        </div>

                                    </div>

                                </div>


                                <div class="tracking-labels">

                                    <div class="tracking-label
                                        <%= placed
                                                ? "active-label"
                                                : "" %>">

                                        Order placed

                                    </div>


                                    <div class="tracking-label
                                        <%= confirmed
                                                ? "active-label"
                                                : "" %>">

                                        Confirmed

                                    </div>


                                    <div class="tracking-label
                                        <%= preparing || ready
                                                ? "active-label"
                                                : "" %>">

                                        Preparing

                                    </div>


                                    <div class="tracking-label
                                        <%= outForDelivery
                                                ? "active-label"
                                                : "" %>">

                                        On the way

                                    </div>


                                    <div class="tracking-label">

                                        Delivered

                                    </div>

                                </div>

                            </div>

                        <% } %>


                        <!-- =================================================
                             DELIVERED TRACKING
                             ================================================= -->

                        <% if (delivered) { %>

                            <div class="tracking-container">

                                <div class="tracking-row">


                                    <div class="tracking-point">

                                        <div class="track-circle track-completed">
                                            ✓
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle track-completed">
                                            ✓
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle track-completed">
                                            ✓
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle track-completed">
                                            ✓
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle track-active">
                                            ✓
                                        </div>

                                    </div>

                                </div>


                                <div class="tracking-labels">

                                    <div class="tracking-label">
                                        Order placed
                                    </div>

                                    <div class="tracking-label">
                                        Confirmed
                                    </div>

                                    <div class="tracking-label">
                                        Preparing
                                    </div>

                                    <div class="tracking-label">
                                        On the way
                                    </div>

                                    <div class="tracking-label active-label">
                                        Delivered
                                    </div>

                                </div>

                            </div>

                        <% } %>


                        <!-- =================================================
                             CANCELLED ORDER
                             ================================================= -->

                        <% if (cancelled) { %>

                            <div class="tracking-container">

                                <div class="tracking-row">


                                    <div class="tracking-point">

                                        <div class="track-circle track-completed">
                                            ✓
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle track-cancelled">
                                            ×
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle">
                                            3
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle">
                                            4
                                        </div>

                                    </div>


                                    <div class="tracking-point">

                                        <div class="track-circle">
                                            5
                                        </div>

                                    </div>

                                </div>


                                <div class="tracking-labels">

                                    <div class="tracking-label">
                                        Order placed
                                    </div>

                                    <div class="tracking-label active-label">
                                        Cancelled
                                    </div>

                                    <div class="tracking-label">
                                        --
                                    </div>

                                    <div class="tracking-label">
                                        --
                                    </div>

                                    <div class="tracking-label">
                                        --
                                    </div>

                                </div>

                            </div>


                            <div class="cancelled-message">

                                <span class="cancelled-icon">
                                    !
                                </span>

                                <span>

                                    This order has been cancelled.
                                    You can order the same items again
                                    whenever you want.

                                </span>

                            </div>

                        <% } %>


                        <!-- =================================================
                             ACTIONS
                             ================================================= -->

                        <div class="action-area">


                            <!-- VIEW DETAILS -->

                            <a
                                href="<%= request.getContextPath() %>/orderDetails?orderId=<%= order.getOrderId() %>"
                                class="action-button view-details">

                                👁&nbsp; View Details

                            </a>


                            <!-- ORDER AGAIN -->

                            <a
                                href="<%= request.getContextPath() %>/orderAgain?orderId=<%= order.getOrderId() %>"
                                class="action-button order-again">

                                ↻&nbsp; Order Again

                            </a>


                            <!-- CANCEL -->

                            <% if (
                                    placed ||
                                    confirmed ||
                                    preparing ||
                                    ready
                            ) { %>

                                <a
                                    href="<%= request.getContextPath() %>/cancelOrder?orderId=<%= order.getOrderId() %>"
                                    class="action-button cancel-order"
                                    onclick="return confirm('Are you sure you want to cancel this order?');">

                                    ×&nbsp; Cancel Order

                                </a>

                            <% } %>

                        </div>

                    </div>

                </div>


            <%
                }
            %>


        <% } %>


        <!-- =========================================================
             CONTINUE SHOPPING
             ========================================================= -->

        <div class="continue-section">

            <a
                href="<%= request.getContextPath() %>/restaurent"
                class="continue-button">

                ←&nbsp; Continue Shopping

            </a>

        </div>


    </main>

</body>

</html>