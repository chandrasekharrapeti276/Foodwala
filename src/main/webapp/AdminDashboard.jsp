
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,java.util.Locale,java.text.SimpleDateFormat,com.tap.module.Order" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String money(Object value) {
        if (value == null) return "₹0.00";
        try {
            double amount = Double.parseDouble(value.toString());
            return "₹" + String.format(Locale.US, "%,.2f", amount);
        } catch (NumberFormatException e) {
            return "₹0.00";
        }
    }

    private String number(Object value) {
        if (value == null) return "0";
        try {
            return String.format(Locale.US, "%,d",
                Long.parseLong(value.toString()));
        } catch (NumberFormatException e) {
            return "0";
        }
    }

    private String displayStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            return "Unknown";
        }
        return status.trim().replace('_', ' ');
    }

    private String statusClass(String status) {
        if (status == null) return "status-default";

        String normalized = status.trim()
                                  .toUpperCase(Locale.ROOT)
                                  .replace('_', ' ');

        if ("DELIVERED".equals(normalized)) return "status-delivered";
        if ("CANCELLED".equals(normalized) ||
            "CANCELED".equals(normalized)) return "status-cancelled";

        if ("PLACED".equals(normalized) ||
            "CONFIRMED".equals(normalized) ||
            "PREPARING".equals(normalized) ||
            "READY".equals(normalized) ||
            "OUT FOR DELIVERY".equals(normalized)) {
            return "status-pending";
        }

        return "status-default";
    }
%>

<%
    String cp = request.getContextPath();

    // Authentication and authorization
    Object sessionUserId = session.getAttribute("userId");
    if (sessionUserId == null) {
        response.sendRedirect(cp + "/Login.jsp");
        return;
    }

    String role = String.valueOf(session.getAttribute("role"));
    if (!"ADMIN".equalsIgnoreCase(role)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                           "Admin access required.");
        return;
    }

    String username = (String) session.getAttribute("username");
    if (username == null || username.trim().isEmpty()) {
        username = "Admin";
    }

    String dashboardError =
        (String) request.getAttribute("dashboardError");

    Object totalOrders = request.getAttribute("totalOrders");
    Object totalUsers = request.getAttribute("totalUsers");
    Object totalRestaurants = request.getAttribute("totalRestaurants");
    Object activeRestaurants = request.getAttribute("activeRestaurants");
    Object pendingOrders = request.getAttribute("pendingOrders");
    Object deliveredOrders = request.getAttribute("deliveredOrders");
    Object cancelledOrders = request.getAttribute("cancelledOrders");
    Object totalRevenue = request.getAttribute("totalRevenue");

    List<Order> recentOrders =
        (List<Order>) request.getAttribute("recentOrders");

    SimpleDateFormat dateFormat =
        new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Foodwala | Admin Dashboard</title>

    <style>
        :root {
            --bg: #09090b;
            --panel: #151518;
            --panel-hover: #1c1c21;
            --border: #303036;
            --orange: #ff6b35;
            --orange-light: #ff8a50;
            --text: #f5f5f5;
            --muted: #a1a1aa;
            --green: #34d399;
            --red: #f87171;
            --yellow: #fbbf24;
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

        .topbar {
            min-height: 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 16px 5%;
            background: #111114;
            border-bottom: 1px solid var(--border);
        }

        .brand {
            font-size: 25px;
            font-weight: 800;
            letter-spacing: -0.6px;
        }

        .brand span {
            color: var(--orange);
        }

        .top-actions {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        .welcome {
            color: var(--muted);
            font-size: 14px;
        }

        .button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 40px;
            padding: 10px 15px;
            border: 1px solid var(--border);
            border-radius: 9px;
            font-size: 13px;
            font-weight: 700;
            transition: background 0.2s ease;
        }

        .button:hover {
            background: var(--panel-hover);
        }

        .button-primary {
            background: var(--orange);
            color: #17100d;
            border-color: var(--orange);
        }

        .button-primary:hover {
            background: var(--orange-light);
        }

        .container {
            width: min(1200px, 92%);
            margin: 0 auto;
            padding: 32px 0 48px;
        }

        .page-heading {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 25px;
        }

        .eyebrow {
            color: var(--orange);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        h1 {
            margin: 8px 0;
            font-size: clamp(27px, 4vw, 36px);
        }

        .subtitle {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.6;
        }

        .error {
            padding: 14px 16px;
            margin-bottom: 20px;
            border: 1px solid #7f1d1d;
            border-radius: 10px;
            background: #2b1414;
            color: #fecaca;
            overflow-wrap: anywhere;
        }

        .metrics {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 16px;
            margin-bottom: 26px;
        }

        .metric {
            padding: 21px;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 15px;
            min-width: 0;
        }

        .metric-label {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.5;
        }

        .metric-value {
            margin: 13px 0 8px;
            font-size: clamp(23px, 3vw, 31px);
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        .metric-note {
            color: var(--muted);
            font-size: 12px;
        }

        .accent {
            color: var(--orange);
        }

        .section {
            margin-top: 24px;
            padding: 22px;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 15px;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 18px;
        }

        h2 {
            margin: 0;
            font-size: 19px;
        }

        .section-note {
            color: var(--muted);
            font-size: 12px;
        }

        .table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            white-space: nowrap;
        }

        th {
            padding: 13px 12px;
            color: var(--muted);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            border-bottom: 1px solid var(--border);
        }

        td {
            padding: 15px 12px;
            border-bottom: 1px solid #29292f;
            font-size: 13px;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        tbody tr:hover {
            background: var(--panel-hover);
        }

        .order-id {
            color: var(--orange-light);
            font-weight: 800;
        }

        .order-date {
            color: #d4d4d8;
            font-size: 12px;
        }

        .status {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            text-transform: capitalize;
        }

        .status-delivered {
            color: var(--green);
            background: #123127;
        }

        .status-cancelled {
            color: var(--red);
            background: #35191b;
        }

        .status-pending {
            color: var(--yellow);
            background: #332b16;
        }

        .status-default {
            color: #d4d4d8;
            background: #29292f;
        }

        .empty {
            padding: 28px 12px;
            text-align: center;
            color: var(--muted);
            line-height: 1.6;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
        }

        .summary-item {
            padding: 17px;
            background: #101013;
            border: 1px solid var(--border);
            border-radius: 11px;
        }

        .summary-label {
            color: var(--muted);
            font-size: 12px;
        }

        .summary-value {
            margin-top: 10px;
            font-size: 23px;
            font-weight: 800;
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 12px;
        }

        .quick-link {
            display: block;
            padding: 17px;
            background: #101013;
            border: 1px solid var(--border);
            border-radius: 11px;
            transition: border-color 0.2s ease,
                        background 0.2s ease;
        }

        .quick-link:hover {
            border-color: var(--orange);
            background: var(--panel-hover);
        }

        .quick-link strong {
            display: block;
            margin-bottom: 7px;
            font-size: 14px;
        }

        .quick-link span {
            color: var(--muted);
            font-size: 12px;
            line-height: 1.5;
        }

        footer {
            padding: 24px 12px 0;
            color: var(--muted);
            text-align: center;
            font-size: 12px;
        }

        @media (max-width: 900px) {
            .metrics {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .quick-actions {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 560px) {
            .topbar {
                align-items: flex-start;
                flex-direction: column;
            }

            .container {
                width: 94%;
                padding-top: 24px;
            }

            .metrics {
                gap: 10px;
            }

            .metric {
                padding: 15px;
            }

            .section {
                padding: 15px;
            }

            .summary-grid {
                grid-template-columns: 1fr;
            }

            .quick-actions {
                grid-template-columns: 1fr;
            }

            .welcome {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<header class="topbar">
    <a class="brand" href="<%= cp %>/adminDashboard">
        Food<span>wala</span>
    </a>

    <div class="top-actions">
        <span class="welcome">
            Welcome, <strong><%= esc(username) %></strong>
        </span>

        <a class="button" href="<%= cp %>/restaurent">View Store</a>
        <a class="button button-primary" href="<%= cp %>/logout">Logout</a>
    </div>
</header>

<main class="container">

    <div class="page-heading">
        <div>
            <div class="eyebrow">Administration</div>
            <h1>Dashboard Overview</h1>
            <p class="subtitle">
                Monitor Foodwala orders, revenue, users, and restaurants.
            </p>
        </div>
    </div>

    <% if (dashboardError != null && !dashboardError.trim().isEmpty()) { %>
        <div class="error">
            <strong>Dashboard data could not be fully loaded.</strong><br>
            <%= esc(dashboardError) %>
        </div>
    <% } %>

    <section class="metrics" aria-label="Dashboard statistics">

        <article class="metric">
            <div class="metric-label">Total Revenue</div>
            <div class="metric-value accent">
                <%= money(totalRevenue) %>
            </div>
            <div class="metric-note">Excludes cancelled orders when calculated by the controller</div>
        </article>

        <article class="metric">
            <div class="metric-label">Total Orders</div>
            <div class="metric-value"><%= number(totalOrders) %></div>
            <div class="metric-note">All recorded orders</div>
        </article>

        <article class="metric">
            <div class="metric-label">Registered Users</div>
            <div class="metric-value"><%= number(totalUsers) %></div>
            <div class="metric-note">Customer accounts</div>
        </article>

        <article class="metric">
            <div class="metric-label">Restaurants</div>
            <div class="metric-value"><%= number(totalRestaurants) %></div>
            <div class="metric-note">
                <span class="accent"><%= number(activeRestaurants) %></span>
                active restaurants
            </div>
        </article>

    </section>

    <section class="section">
        <div class="section-heading">
            <h2>Recent Orders</h2>
            <span class="section-note">Latest orders first</span>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User ID</th>
                        <th>Order Date &amp; Time</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody>
                    <% if (recentOrders != null && !recentOrders.isEmpty()) {
                           for (Order order : recentOrders) {
                               if (order == null) continue;

                               String statusText =
                                   displayStatus(order.getStatus());

                               String formattedDate = "Date unavailable";
                               if (order.getOrderDate() != null) {
                                   formattedDate =
                                       dateFormat.format(order.getOrderDate());
                               }
                    %>
                        <tr>
                            <td class="order-id">
                                #<%= order.getOrderId() %>
                            </td>

                            <td><%= order.getUserId() %></td>

                            <td class="order-date">
                                <%= esc(formattedDate) %>
                            </td>

                            <td><%= money(order.getTotalAmount()) %></td>

                            <td>
                                <span class="status <%= statusClass(order.getStatus()) %>">
                                    <%= esc(statusText) %>
                                </span>
                            </td>
                        </tr>
                    <%
                           }
                       } else {
                    %>
                        <tr>
                            <td colspan="5" class="empty">
                                No recent orders found.<br>
                                Orders will appear here after customers place them.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <section class="section">
        <div class="section-heading">
            <h2>Order Summary</h2>
            <span class="section-note">Current order status counts</span>
        </div>

        <div class="summary-grid">
            <div class="summary-item">
                <div class="summary-label">Pending / In Progress</div>
                <div class="summary-value" style="color: var(--yellow);">
                    <%= number(pendingOrders) %>
                </div>
            </div>

            <div class="summary-item">
                <div class="summary-label">Delivered</div>
                <div class="summary-value" style="color: var(--green);">
                    <%= number(deliveredOrders) %>
                </div>
            </div>

            <div class="summary-item">
                <div class="summary-label">Cancelled</div>
                <div class="summary-value" style="color: var(--red);">
                    <%= number(cancelledOrders) %>
                </div>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="section-heading">
            <h2>Quick Actions</h2>
            <span class="section-note">Manage your store</span>
        </div>

        <div class="quick-actions">

            <a class="quick-link" href="<%= cp %>/orderManagement">
                <strong>Manage Orders</strong>
                <span>Review orders and update their status.</span>
            </a>

            <a class="quick-link" href="<%= cp %>/admin/restaurants">
                <strong>Manage Restaurants</strong>
                <span>Add, edit, activate, or deactivate restaurants.</span>
            </a>

            <a class="quick-link" href="<%= cp %>/adminMenu">
                <strong>Manage Menu</strong>
                <span>Maintain restaurant menu items.</span>
            </a>

            <a class="quick-link" href="<%= cp %>/adminUsers">
                <strong>Manage Users</strong>
                <span>View and manage user accounts.</span>
            </a>

        </div>
    </section>

    <footer>
        Foodwala Admin Dashboard
    </footer>

</main>

</body>
</html>