<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="com.tap.module.Order" %>
<%@ page import="com.tap.module.OrderItem" %>
<%@ page import="com.tap.module.Menu" %>
<%@ page import="com.tap.module.CartItem" %>

<%
    /* =========================================================
       LOGIN CHECK
       ========================================================= */

    if (session == null
            || session.getAttribute("userId") == null) {

        session.setAttribute(
                "redirectAfterLogin",
                "/orderHistory"
        );

        response.sendRedirect(
                request.getContextPath() + "/Login.jsp"
        );

        return;
    }


    /* =========================================================
       GET DATA FROM CONTROLLER
       ========================================================= */

    Order order =
            (Order) request.getAttribute("order");

    @SuppressWarnings("unchecked")
    List<OrderItem> orderItems =
            (List<OrderItem>)
                    request.getAttribute("orderItems");

    @SuppressWarnings("unchecked")
    Map<Integer, Menu> menuItems =
            (Map<Integer, Menu>)
                    request.getAttribute("menuItems");


    if (order == null) {

        response.sendRedirect(
                request.getContextPath() + "/orderHistory"
        );

        return;
    }


    if (orderItems == null) {
        orderItems = new ArrayList<OrderItem>();
    }


    if (menuItems == null) {
        menuItems = new HashMap<Integer, Menu>();
    }


    /* =========================================================
       USER
       ========================================================= */

    String username =
            session.getAttribute("username") != null
                    ? String.valueOf(
                            session.getAttribute("username")
                    )
                    : "Food Lover";


    /* =========================================================
       ORDER DATA
       ========================================================= */

    String status =
            order.getStatus() != null
                    ? order.getStatus().trim()
                    : "PLACED";

    if (status.isEmpty()) {
        status = "PLACED";
    }


    String statusDisplay =
            status.replace("_", " ");


    double totalAmount =
            order.getTotalAmount();


    int totalItems = 0;


    for (OrderItem item : orderItems) {

        if (item != null
                && item.getQuantity() > 0) {

            totalItems += item.getQuantity();
        }
    }


    /* =========================================================
       STATUS FLAGS
       ========================================================= */

    boolean isCancelled =
            "CANCELLED".equalsIgnoreCase(status);

    boolean isDelivered =
            "DELIVERED".equalsIgnoreCase(status);

    boolean isPlaced =
            "PLACED".equalsIgnoreCase(status);

    boolean isConfirmed =
            "CONFIRMED".equalsIgnoreCase(status);

    boolean isPreparing =
            "PREPARING".equalsIgnoreCase(status);

    boolean isReady =
            "READY".equalsIgnoreCase(status);

    boolean isOutForDelivery =
            "OUT_FOR_DELIVERY".equalsIgnoreCase(status);


    boolean canCancel =
            isPlaced
            || isConfirmed
            || isPreparing
            || isReady;


    /* =========================================================
       TRACKER STATE
       ========================================================= */

    boolean confirmedDone =
            isConfirmed
            || isPreparing
            || isReady
            || isOutForDelivery
            || isDelivered;


    boolean preparingDone =
            isPreparing
            || isReady
            || isOutForDelivery
            || isDelivered;


    boolean deliveredDone =
            isDelivered;


    /* =========================================================
       STATUS CLASS
       ========================================================= */

    String statusClass =
            status
                    .toLowerCase()
                    .replace("_", "-")
                    .replace(" ", "-");


    if (isCancelled) {

        statusClass = "cancelled";

    } else if (isDelivered) {

        statusClass = "delivered";
    }


    /* =========================================================
       CART COUNT
       ========================================================= */

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


    /* =========================================================
       HELPER VALUES
       ========================================================= */

    String formattedTotal =
            String.format(
                    java.util.Locale.US,
                    "%.2f",
                    totalAmount
            );
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <meta name="description"
          content="Foodwala order details">

    <title>
        Foodwala | Order #<%= order.getOrderId() %>
    </title>


    <style>

        /* =====================================================
           GLOBAL
           ===================================================== */

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
                Arial,
                Helvetica,
                sans-serif;

            background:
                radial-gradient(
                    circle at top left,
                    rgba(255, 107, 53, 0.08),
                    transparent 32%
                ),
                radial-gradient(
                    circle at top right,
                    rgba(255, 166, 0, 0.05),
                    transparent 28%
                ),
                #0b0d10;

            color: #f5f5f5;

            padding-bottom: 30px;
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
                rgba(11, 13, 16, 0.94);

            border-bottom:
                1px solid rgba(255, 255, 255, 0.08);

            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);

            padding: 13px 20px;

            box-shadow:
                0 8px 30px
                rgba(0, 0, 0, 0.35);
        }


        .nav-inner {
            width: 100%;
            max-width: 1200px;
            min-height: 52px;

            margin: 0 auto;

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


        .nav-links {
            display: flex;
            align-items: center;
            justify-content: flex-end;

            gap: 5px;

            flex-wrap: wrap;
        }


        .nav-links a {
            color: #c9c9c9;

            padding: 9px 11px;

            border-radius: 9px;

            font-size: 12px;
            font-weight: 700;

            transition:
                background 0.2s ease,
                color 0.2s ease,
                transform 0.2s ease;
        }


        .nav-links a:hover {
            background:
                rgba(255, 107, 53, 0.10);

            color: #ffffff;

            transform:
                translateY(-1px);
        }


        .nav-links .active {
            background:
                rgba(255, 107, 53, 0.14);

            color: #ff8a5b;
        }


        .user-name {
            max-width: 145px;

            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;

            color: #eeeeee;

            padding: 8px;

            font-size: 12px;
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

            top: 1px;
            right: 1px;

            min-width: 18px;
            height: 18px;

            padding: 0 5px;

            border-radius: 20px;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #ff6b35;
            color: #ffffff;

            font-size: 10px;
            font-weight: 900;

            border:
                2px solid #0b0d10;
        }


        /* =====================================================
           MAIN
           ===================================================== */

        .container {
            width: 100%;
            max-width: 1000px;

            margin: 0 auto;

            padding:
                43px 20px 70px;
        }


        /* =====================================================
           PAGE HEADING
           ===================================================== */

        .page-heading {
            margin-bottom: 25px;
        }


        .eyebrow {
            display: inline-flex;
            align-items: center;

            gap: 7px;

            margin-bottom: 10px;

            color: #ff8a5b;

            font-size: 10px;
            font-weight: 900;

            text-transform: uppercase;

            letter-spacing: 1.7px;
        }


        .eyebrow::before {
            content: "";

            width: 22px;
            height: 2px;

            border-radius: 10px;

            background: #ff6b35;
        }


        .page-heading h1 {
            margin: 0;

            color: #ffffff;

            font-size: 37px;
            font-weight: 900;

            letter-spacing: -1px;
        }


        .order-date {
            margin-top: 8px;

            color: #777d85;

            font-size: 12px;
        }


        /* =====================================================
           STATUS CARD
           ===================================================== */

        .status-card {
            margin-bottom: 19px;

            padding: 24px;

            background:
                linear-gradient(
                    145deg,
                    #181b20,
                    #101216
                );

            border:
                1px solid rgba(255, 255, 255, 0.08);

            border-radius: 19px;

            box-shadow:
                0 15px 40px
                rgba(0, 0, 0, 0.35);
        }


        .status-card.cancelled {
            border-color:
                rgba(239, 68, 68, 0.20);

            background:
                linear-gradient(
                    145deg,
                    #1b1719,
                    #111113
                );
        }


        .status-top {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;

            gap: 18px;

            margin-bottom: 28px;
        }


        .status-title {
            color: #ffffff;

            font-size: 19px;
            font-weight: 900;
        }


        .status-description {
            max-width: 610px;

            margin-top: 7px;

            color: #858b93;

            font-size: 12px;

            line-height: 1.7;
        }


        .status-pill {
            flex-shrink: 0;

            padding: 8px 13px;

            border-radius: 20px;

            background:
                rgba(255, 107, 53, 0.11);

            border:
                1px solid rgba(255, 107, 53, 0.25);

            color: #ff9a72;

            font-size: 10px;
            font-weight: 900;

            text-transform: uppercase;

            letter-spacing: 0.5px;
        }


        .status-pill.cancelled {
            background:
                rgba(239, 68, 68, 0.10);

            border-color:
                rgba(239, 68, 68, 0.25);

            color: #ff7777;
        }


        .status-pill.delivered {
            background:
                rgba(45, 211, 124, 0.10);

            border-color:
                rgba(45, 211, 124, 0.25);

            color: #62e69c;
        }


        /* =====================================================
           ORDER TRACKER
           ===================================================== */

        .tracker {
            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap: 7px;
        }


        .tracker-step {
            position: relative;

            text-align: center;
        }


        .tracker-line {
            position: absolute;

            top: 7px;
            left: 50%;

            width: 100%;
            height: 2px;

            background:
                rgba(255, 255, 255, 0.09);

            z-index: 0;
        }


        .tracker-step:last-child
        .tracker-line {
            display: none;
        }


        .tracker-dot {
            position: relative;
            z-index: 1;

            width: 16px;
            height: 16px;

            margin: 0 auto;

            border-radius: 50%;

            background: #30343a;

            border:
                3px solid #181b20;
        }


        .tracker-step.completed
        .tracker-dot {
            background: #ff6b35;

            box-shadow:
                0 0 0 4px
                rgba(255, 107, 53, 0.10);
        }


        .tracker-step.active
        .tracker-dot {
            background: #2dd37c;

            box-shadow:
                0 0 0 4px
                rgba(45, 211, 124, 0.10);
        }


        .tracker-step.cancelled-step
        .tracker-dot {
            background: #ef4444;

            box-shadow:
                0 0 0 4px
                rgba(239, 68, 68, 0.10);
        }


        .tracker-label {
            display: block;

            margin-top: 9px;

            color: #656b73;

            font-size: 9px;
            font-weight: 800;
        }


        .tracker-step.completed
        .tracker-label,

        .tracker-step.active
        .tracker-label {
            color: #b8bdc4;
        }


        .tracker-step.cancelled-step
        .tracker-label {
            color: #ff7777;
        }


        /* =====================================================
           COMMON CARD
           ===================================================== */

        .card {
            margin-bottom: 19px;

            overflow: hidden;

            background:
                linear-gradient(
                    145deg,
                    #171a1f,
                    #101216
                );

            border:
                1px solid rgba(255, 255, 255, 0.08);

            border-radius: 18px;

            box-shadow:
                0 13px 35px
                rgba(0, 0, 0, 0.30);
        }


        .card-header {
            padding: 18px 20px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 12px;

            border-bottom:
                1px solid rgba(255, 255, 255, 0.07);
        }


        .card-header h2 {
            margin: 0;

            color: #ffffff;

            font-size: 17px;
            font-weight: 900;
        }


        .item-count {
            color: #777d85;

            font-size: 11px;
            font-weight: 700;
        }


        /* =====================================================
           ORDER ITEMS
           ===================================================== */

        .order-item {
            padding: 17px 20px;

            display: flex;
            align-items: center;

            gap: 14px;

            border-bottom:
                1px solid rgba(255, 255, 255, 0.06);
        }


        .order-item:last-child {
            border-bottom: none;
        }


        .item-image {
            width: 64px;
            height: 64px;

            flex-shrink: 0;

            overflow: hidden;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 12px;

            background:
                linear-gradient(
                    135deg,
                    #292019,
                    #171512
                );

            color: #ff8a5b;

            font-size: 10px;
            font-weight: 900;
        }


        .item-image img {
            width: 100%;
            height: 100%;

            object-fit: cover;

            display: block;
        }


        .item-info {
            min-width: 0;

            flex: 1;
        }


        .item-name {
            margin-bottom: 6px;

            overflow: hidden;

            color: #eeeeef;

            font-size: 13px;
            font-weight: 800;

            white-space: nowrap;

            text-overflow: ellipsis;
        }


        .item-meta {
            color: #777d85;

            font-size: 11px;
        }


        .item-total {
            flex-shrink: 0;

            color: #ff8a5b;

            font-size: 14px;
            font-weight: 900;
        }


        /* =====================================================
           PAYMENT INFORMATION
           ===================================================== */

        .info-body {
            padding: 20px;
        }


        .info-message {
            display: flex;
            align-items: flex-start;

            gap: 12px;

            padding: 15px;

            border:
                1px solid rgba(255, 255, 255, 0.07);

            border-radius: 12px;

            background:
                rgba(255, 255, 255, 0.025);
        }


        .info-icon {
            flex-shrink: 0;

            width: 34px;
            height: 34px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            background:
                rgba(255, 107, 53, 0.10);

            color: #ff8a5b;

            font-size: 13px;
            font-weight: 900;
        }


        .info-title {
            margin-bottom: 5px;

            color: #eeeeef;

            font-size: 12px;
            font-weight: 900;
        }


        .info-text {
            color: #858b93;

            font-size: 11px;

            line-height: 1.7;
        }


        .info-text strong {
            color: #ff8a5b;
        }


        /* =====================================================
           ORDER SUMMARY
           ===================================================== */

        .summary {
            padding: 18px 20px;
        }


        .summary-row {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 15px;

            padding: 8px 0;

            color: #858b93;

            font-size: 12px;
        }


        .summary-row.status-row {
            color: #aeb3ba;
        }


        .summary-row.total {
            margin-top: 9px;

            padding-top: 17px;

            border-top:
                1px solid rgba(255, 255, 255, 0.08);

            color: #ffffff;

            font-size: 15px;
            font-weight: 900;
        }


        .summary-row.total strong {
            color: #ff8a5b;

            font-size: 21px;
        }


        .summary-row.total.cancelled-total strong {
            color: #ff7777;
        }


        /* =====================================================
           ACTIONS
           ===================================================== */

        .actions {
            margin-top: 6px;

            display: grid;

            grid-template-columns:
                repeat(3, 1fr);

            gap: 10px;
        }


        .button {
            min-height: 47px;

            padding: 0 15px;

            display: flex;
            align-items: center;
            justify-content: center;

            border:
                1px solid rgba(255, 255, 255, 0.11);

            border-radius: 10px;

            background:
                rgba(255, 255, 255, 0.035);

            color: #b9bdc3;

            font-size: 12px;
            font-weight: 900;

            text-align: center;

            transition:
                transform 0.2s ease,
                background 0.2s ease,
                border-color 0.2s ease,
                color 0.2s ease;
        }


        .button:hover {
            transform:
                translateY(-2px);

            background:
                rgba(255, 107, 53, 0.08);

            border-color:
                rgba(255, 107, 53, 0.30);

            color: #ffffff;
        }


        .button.primary {
            background:
                linear-gradient(
                    135deg,
                    #ff713c,
                    #f4511e
                );

            border-color:
                #ff6b35;

            color: #ffffff;

            box-shadow:
                0 9px 24px
                rgba(255, 107, 53, 0.17);
        }


        .button.primary:hover {
            background:
                linear-gradient(
                    135deg,
                    #ff8150,
                    #ff5c27
                );

            border-color:
                #ff8150;

            color: #ffffff;

            box-shadow:
                0 12px 28px
                rgba(255, 107, 53, 0.25);
        }


        .button.danger {
            color: #ff7777;

            border-color:
                rgba(239, 68, 68, 0.20);
        }


        .button.danger:hover {
            background:
                rgba(239, 68, 68, 0.09);

            border-color:
                rgba(239, 68, 68, 0.35);

            color: #ff9696;
        }


        /* =====================================================
           FOOTER
           ===================================================== */

        .footer {
            margin-top: 20px;

            padding: 22px 15px;

            background: #08090b;

            border-top:
                1px solid rgba(255, 255, 255, 0.07);

            color: #70757d;

            text-align: center;

            font-size: 12px;
        }


        /* =====================================================
           TABLET / MOBILE
           ===================================================== */

        @media (max-width: 700px) {

            .navbar {
                padding: 11px 13px;
            }


            .nav-inner {
                flex-direction: column;

                gap: 8px;
            }


            .nav-links {
                justify-content: center;
            }


            .container {
                padding:
                    30px 14px 50px;
            }


            .page-heading h1 {
                font-size: 30px;
            }


            .status-card {
                padding: 19px;
            }


            .status-top {
                flex-direction: column;
            }


            .status-pill {
                align-self: flex-start;
            }


            .actions {
                grid-template-columns: 1fr;
            }


            .button {
                width: 100%;
            }
        }


        /* =====================================================
           SMALL MOBILE
           ===================================================== */

        @media (max-width: 480px) {

            .brand {
                font-size: 23px;
            }


            .nav-links a {
                padding: 7px 7px;

                font-size: 10px;
            }


            .user-name {
                max-width: 90px;

                font-size: 10px;
            }


            .page-heading h1 {
                font-size: 26px;
            }


            .tracker {
                gap: 2px;
            }


            .tracker-label {
                font-size: 7px;
            }


            .item-image {
                width: 54px;
                height: 54px;
            }


            .item-name {
                font-size: 12px;
            }


            .item-total {
                font-size: 12px;
            }


            .order-item {
                padding: 15px;
            }


            .card-header {
                padding: 16px;
            }


            .summary {
                padding:
                    17px 16px;
            }
        }

    </style>

</head>


<body>


    <!-- =====================================================
         NAVBAR
         ===================================================== -->

    <header class="navbar">

        <div class="nav-inner">

            <a
                href="<%= request.getContextPath() %>/restaurent"
                class="brand">

                Foodwala

            </a>


            <nav class="nav-links">

                <a
                    href="<%= request.getContextPath() %>/restaurent">

                    Restaurants

                </a>


                <a
                    href="<%= request.getContextPath() %>/cart"
                    class="cart-link">

                    🛒 Cart

                    <% if (cartCount > 0) { %>

                        <span class="cart-badge">

                            <%= cartCount %>

                        </span>

                    <% } %>

                </a>


                <a
                    href="<%= request.getContextPath() %>/favorites">

                    ♡ Favorites

                </a>


                <a
                    href="<%= request.getContextPath() %>/orderHistory"
                    class="active">

                    Orders

                </a>


                <span class="user-name">

                    Hi, <%= username %>

                </span>


                <a
                    href="<%= request.getContextPath() %>/logout">

                    Logout

                </a>

            </nav>

        </div>

    </header>


    <!-- =====================================================
         MAIN
         ===================================================== -->

    <main class="container">


        <!-- =================================================
             HEADING
             ================================================= -->

        <section class="page-heading">

            <div class="eyebrow">

                Order Details

            </div>


            <h1>

                Order #<%= order.getOrderId() %>

            </h1>


            <% if (order.getOrderDate() != null) { %>

                <div class="order-date">

                    Placed on
                    <%= order.getOrderDate() %>

                </div>

            <% } %>

        </section>


        <!-- =================================================
             STATUS CARD
             ================================================= -->

        <section
            class="status-card <%= isCancelled ? "cancelled" : "" %>">


            <div class="status-top">


                <div>

                    <div class="status-title">

                        <%
                            if (isCancelled) {
                        %>

                            Your order was cancelled

                        <%
                            } else if (isDelivered) {
                        %>

                            Your order has been delivered

                        <%
                            } else if (isOutForDelivery) {
                        %>

                            Your order is out for delivery

                        <%
                            } else if (isReady) {
                        %>

                            Your order is ready

                        <%
                            } else if (isPreparing) {
                        %>

                            Your order is being prepared

                        <%
                            } else if (isConfirmed) {
                        %>

                            Your order is confirmed

                        <%
                            } else {
                        %>

                            Your order has been placed

                        <%
                            }
                        %>

                    </div>


                    <div class="status-description">

                        <%
                            if (isCancelled) {
                        %>

                            This order has been cancelled.
                            Your order information is still
                            available for your records.

                        <%
                            } else if (isDelivered) {
                        %>

                            Your order has been successfully
                            delivered. Enjoy your meal!

                        <%
                            } else if (isOutForDelivery) {
                        %>

                            Your food is on the way.

                        <%
                            } else if (isReady) {
                        %>

                            Your food is ready and will be
                            dispatched shortly.

                        <%
                            } else if (isPreparing) {
                        %>

                            The restaurant is preparing
                            your food.

                        <%
                            } else if (isConfirmed) {
                        %>

                            The restaurant has confirmed
                            your order and will start preparing it.

                        <%
                            } else {
                        %>

                            Your order has been received
                            successfully.

                        <%
                            }
                        %>

                    </div>

                </div>


                <div
                    class="status-pill <%= statusClass %>">

                    <%= statusDisplay %>

                </div>

            </div>


            <!-- =================================================
                 TRACKER
                 ================================================= -->

            <%

                if (isCancelled) {

            %>


                <div class="tracker">


                    <div class="tracker-step completed">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Placed

                        </span>

                    </div>


                    <div class="tracker-step cancelled-step">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Cancelled

                        </span>

                    </div>


                    <div class="tracker-step">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Preparing

                        </span>

                    </div>


                    <div class="tracker-step">

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Delivered

                        </span>

                    </div>


                </div>


            <%

                } else {

            %>


                <div class="tracker">


                    <!-- PLACED -->

                    <div
                        class="tracker-step completed">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Placed

                        </span>

                    </div>


                    <!-- CONFIRMED -->

                    <div
                        class="tracker-step
                        <%= confirmedDone ? "completed" : "" %>
                        <%= isConfirmed ? "active" : "" %>">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Confirmed

                        </span>

                    </div>


                    <!-- PREPARING -->

                    <div
                        class="tracker-step
                        <%= preparingDone ? "completed" : "" %>
                        <%= isPreparing
                            || isReady
                            || isOutForDelivery
                                ? "active"
                                : "" %>">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Preparing

                        </span>

                    </div>


                    <!-- DELIVERED -->

                    <div
                        class="tracker-step
                        <%= deliveredDone ? "active" : "" %>">

                        <div class="tracker-line"></div>

                        <div class="tracker-dot"></div>

                        <span class="tracker-label">

                            Delivered

                        </span>

                    </div>


                </div>


            <%

                }

            %>


        </section>


        <!-- =================================================
             ORDER ITEMS
             ================================================= -->

        <section class="card">


            <div class="card-header">

                <h2>

                    Items Ordered

                </h2>


                <span class="item-count">

                    <%= totalItems %>

                    <%= totalItems == 1
                            ? "item"
                            : "items" %>

                </span>

            </div>


            <%

                if (orderItems.isEmpty()) {

            %>


                <div class="order-item">

                    <div class="item-info">

                        <div class="item-name">

                            No item information available.

                        </div>

                    </div>

                </div>


            <%

                } else {

                    for (OrderItem item : orderItems) {

                        if (item == null) {
                            continue;
                        }


                        Menu menu =
                                menuItems.get(
                                        item.getMenuId()
                                );


                        String itemName =
                                "Food Item";


                        String imagePath =
                                null;


                        if (menu != null) {

                            if (menu.getItemName() != null
                                    && !menu.getItemName()
                                            .trim()
                                            .isEmpty()) {

                                itemName =
                                        menu.getItemName();
                            }


                            imagePath =
                                    menu.getImagePath();
                        }


                        double itemTotal =
                                item.getItemTotal();

            %>


                <div class="order-item">


                    <!-- ITEM IMAGE -->

                    <div class="item-image">


                        <%

                            if (imagePath != null
                                    && !imagePath.trim().isEmpty()) {

                        %>

                            <img
                                src="<%= imagePath %>"
                                alt="<%= itemName %>">


                        <%

                            } else {

                        %>

                            FOOD

                        <%

                            }

                        %>


                    </div>


                    <!-- ITEM DETAILS -->

                    <div class="item-info">


                        <div class="item-name">

                            <%= itemName %>

                        </div>


                        <div class="item-meta">

                            Quantity:
                            <%= item.getQuantity() %>

                        </div>


                    </div>


                    <!-- ITEM TOTAL -->

                    <div class="item-total">

                        ₹<%= String.format(
                                java.util.Locale.US,
                                "%.2f",
                                itemTotal
                            ) %>

                    </div>


                </div>


            <%

                    }

                }

            %>


        </section>


        <!-- =================================================
             PAYMENT INFORMATION
             ================================================= -->

        <section class="card">


            <div class="card-header">

                <h2>

                    Payment

                </h2>

            </div>


            <div class="info-body">


                <div class="info-message">


                    <div class="info-icon">

                        ₹

                    </div>


                    <div>

                        <div class="info-title">

                            Payment information

                        </div>


                        <div class="info-text">

                            Payment-method details are not
                            stored in the current order
                            database schema.

                            Your recorded order total is

                            <strong>

                                ₹<%= formattedTotal %>

                            </strong>.

                        </div>

                    </div>


                </div>


            </div>

        </section>


        <!-- =================================================
             ORDER SUMMARY
             ================================================= -->

        <section class="card">


            <div class="card-header">

                <h2>

                    Order Summary

                </h2>

            </div>


            <div class="summary">


                <div class="summary-row">

                    <span>

                        Items

                    </span>

                    <span>

                        <%= totalItems %>

                        <%= totalItems == 1
                                ? "item"
                                : "items" %>

                    </span>

                </div>


                <div class="summary-row status-row">

                    <span>

                        Order Status

                    </span>

                    <span>

                        <%= statusDisplay %>

                    </span>

                </div>


                <div
                    class="summary-row total
                    <%= isCancelled
                            ? "cancelled-total"
                            : "" %>">

                    <span>

                        Total Amount

                    </span>


                    <strong>

                        ₹<%= formattedTotal %>

                    </strong>

                </div>


            </div>

        </section>


        <!-- =================================================
             ACTIONS
             ================================================= -->

        <div class="actions">


            <!-- ORDER AGAIN -->

            <a
                href="<%= request.getContextPath() %>/orderAgain?orderId=<%= order.getOrderId() %>"
                class="button primary">

                ↻ Order Again

            </a>


            <!-- MY ORDERS -->

            <a
                href="<%= request.getContextPath() %>/orderHistory"
                class="button">

                My Orders

            </a>


            <%

                if (canCancel) {

            %>


                <!-- CANCEL -->

                <a
                    href="<%= request.getContextPath() %>/cancelOrder?orderId=<%= order.getOrderId() %>"
                    class="button danger">

                    ✕ Cancel Order

                </a>


            <%

                } else {

            %>


                <!-- CONTINUE SHOPPING -->

                <a
                    href="<%= request.getContextPath() %>/restaurent"
                    class="button">

                    Continue Shopping

                </a>


            <%

                }

            %>


        </div>


    </main>


    <!-- =====================================================
         FOOTER
         ===================================================== -->

    <footer class="footer">

        Foodwala · Fresh food. Simple ordering.

    </footer>


</body>

</html>