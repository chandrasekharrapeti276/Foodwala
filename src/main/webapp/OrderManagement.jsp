
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,java.util.Collections,java.util.Locale,java.text.SimpleDateFormat,com.tap.module.Order,jakarta.servlet.http.HttpServletResponse" %>

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

    private String normalizeStatus(Object value) {
        if (value == null || value.toString().trim().isEmpty()) {
            return "PLACED";
        }

        return value.toString().trim()
            .toUpperCase(Locale.ROOT)
            .replace('_', ' ');
    }

    private String statusClass(String status) {
        if ("DELIVERED".equals(status)) return "delivered";
        if ("CANCELLED".equals(status)) return "cancelled";
        if ("CONFIRMED".equals(status)) return "confirmed";
        if ("PREPARING".equals(status)) return "preparing";
        if ("READY".equals(status)) return "ready";
        if ("OUT FOR DELIVERY".equals(status)) return "out-for-delivery";
        return "placed";
    }

    private String formatOrderDate(Object value) {
        if (value == null) {
            return "Date unavailable";
        }

        if (value instanceof java.util.Date) {
            return new SimpleDateFormat(
                "dd MMM yyyy, hh:mm a", Locale.ENGLISH
            ).format((java.util.Date) value);
        }

        return String.valueOf(value);
    }
%>

<%
    String cp = request.getContextPath();

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(cp + "/Login.jsp");
        return;
    }

    String role = session.getAttribute("role") == null
        ? ""
        : session.getAttribute("role").toString().trim();

    if (!"ADMIN".equalsIgnoreCase(role)) {
        response.sendError(
            HttpServletResponse.SC_FORBIDDEN,
            "Administrator access required."
        );
        return;
    }

    List<Order> orders =
        (List<Order>) request.getAttribute("orders");

    if (orders == null) {
        orders = Collections.emptyList();
    }

    String statusMessage =
        request.getAttribute("statusMessage") == null
        ? ""
        : request.getAttribute("statusMessage").toString();

    String statusError =
        request.getAttribute("statusError") == null
        ? ""
        : request.getAttribute("statusError").toString();

    String[] statuses = {
        "PLACED",
        "CONFIRMED",
        "PREPARING",
        "READY",
        "OUT FOR DELIVERY",
        "DELIVERED",
        "CANCELLED"
    };

    String username = session.getAttribute("username") == null
        ? "Admin"
        : session.getAttribute("username").toString();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Foodwala | Manage Orders</title>

<style>
:root {
    --bg: #09090b;
    --header: #111114;
    --panel: #151518;
    --border: #29292e;
    --text: #f5f5f7;
    --muted: #9696a1;
    --orange: #ff6b35;
    --orange-hover: #ed5a26;
    --green: #a2efbb;
    --green-bg: #123022;
    --red: #ffaaaa;
    --red-bg: #351719;
}

* { box-sizing: border-box; }

html {
    min-height: 100%;
    background: var(--bg);
}

body {
    margin: 0;
    min-height: 100vh;
    background: var(--bg);
    color: var(--text);
    font-family: Arial, Helvetica, sans-serif;
}

a {
    color: inherit;
    text-decoration: none;
}

header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 18px;
    padding: 18px 4%;
    background: var(--header);
    border-bottom: 1px solid var(--border);
    flex-wrap: wrap;
}

.logo {
    font-size: 27px;
    font-weight: 900;
    letter-spacing: -1px;
    color: #fff;
    white-space: nowrap;
}

.logo span { color: var(--orange); }

nav {
    display: flex;
    align-items: center;
    gap: 7px;
    flex-wrap: wrap;
}

nav a {
    padding: 10px 12px;
    border-radius: 9px;
    color: #e4e4e7;
    font-size: 13px;
    font-weight: 700;
}

nav a:hover { background: #252529; }

nav a.active {
    background: var(--orange);
    color: #fff;
}

nav a.active:hover { background: var(--orange-hover); }

.nav-user {
    color: var(--muted);
    font-size: 12px;
    padding: 6px;
}

main {
    width: 100%;
    max-width: 1550px;
    margin: 0 auto;
    padding: 34px 3% 50px;
}

.page-heading {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 20px;
    flex-wrap: wrap;
    margin-bottom: 24px;
}

.eyebrow {
    color: var(--orange);
    font-size: 11px;
    font-weight: 900;
    letter-spacing: 2px;
}

h1 {
    font-size: clamp(29px, 4vw, 42px);
    margin: 12px 0;
    letter-spacing: -1px;
}

.subtitle {
    color: #aaa;
    line-height: 1.7;
    margin: 0;
}

.summary {
    display: flex;
    align-items: center;
    gap: 12px;
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 15px 19px;
}

.summary-number {
    color: var(--orange);
    font-size: 25px;
    font-weight: 900;
}

.summary-label {
    color: var(--muted);
    font-size: 12px;
}

.notice {
    padding: 15px 18px;
    border-radius: 11px;
    margin: 18px 0;
    border: 1px solid;
    line-height: 1.6;
    overflow-wrap: anywhere;
}

.success {
    background: #10251a;
    color: #b7f4ca;
    border-color: #275d3b;
}

.failure {
    background: #2b1513;
    color: #ffd0c9;
    border-color: #7e3930;
}

.table-wrap {
    overflow-x: auto;
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 16px;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 980px;
}

th, td {
    text-align: left;
    padding: 17px 15px;
    border-bottom: 1px solid var(--border);
    vertical-align: middle;
}

th {
    color: var(--orange);
    background: #1b1b20;
    font-size: 11px;
    letter-spacing: .7px;
    text-transform: uppercase;
    white-space: nowrap;
}

td {
    font-size: 13px;
    color: #e7e7eb;
}

tbody tr { background: var(--panel); }
tbody tr:hover { background: #1b1b1f; }
tbody tr:last-child td { border-bottom: 0; }

.order-id {
    color: #fff;
    font-weight: 800;
    white-space: nowrap;
}

.amount {
    font-weight: 800;
    color: #fff;
    white-space: nowrap;
}

.order-date {
    color: #d4d4d8;
    white-space: nowrap;
    font-size: 12px;
}

.status {
    display: inline-block;
    padding: 7px 10px;
    border-radius: 20px;
    font-size: 10px;
    font-weight: 800;
    white-space: nowrap;
    background: #302216;
    color: #ffbf8d;
}

.status.delivered {
    background: var(--green-bg);
    color: var(--green);
}

.status.cancelled {
    background: var(--red-bg);
    color: var(--red);
}

.status.confirmed, .status.ready {
    background: #172a42;
    color: #a8d2ff;
}

.status.preparing, .status.out-for-delivery {
    background: #332713;
    color: #ffd28a;
}

.status.placed {
    background: #302216;
    color: #ffbf8d;
}

.status-form {
    display: flex;
    gap: 8px;
    align-items: center;
}

select {
    min-width: 155px;
    max-width: 210px;
    background: #09090b;
    color: #f5f5f7;
    border: 1px solid #414148;
    border-radius: 8px;
    padding: 11px;
    font-size: 13px;
}

select:focus, button:focus-visible, nav a:focus-visible {
    outline: 2px solid var(--orange);
    outline-offset: 3px;
}

button {
    min-height: 40px;
    border: 0;
    border-radius: 8px;
    background: var(--orange);
    color: white;
    padding: 11px 15px;
    font-size: 12px;
    font-weight: 800;
    cursor: pointer;
}

button:hover { background: var(--orange-hover); }

.empty {
    text-align: center;
    color: var(--muted);
    padding: 48px 20px;
    line-height: 1.8;
}

.empty strong {
    color: #f5f5f7;
    font-size: 18px;
}

.empty a {
    display: inline-block;
    margin-top: 14px;
    padding: 10px 15px;
    border-radius: 8px;
    background: var(--orange);
    color: #fff;
    font-weight: 800;
}

footer {
    border-top: 1px solid var(--border);
    background: var(--header);
    text-align: center;
    color: var(--muted);
    padding: 22px 12px;
    font-size: 12px;
}

@media (max-width: 760px) {
    header { padding: 16px; }
    nav { width: 100%; }
    main { padding: 24px 14px 35px; }
    .summary { width: 100%; }
}

@media (max-width: 480px) {
    nav a { padding: 9px; font-size: 12px; }
    .status-form { align-items: stretch; }
    select { min-width: 0; width: 100%; flex: 1; }
}
</style>

<script>
function confirmStatus(form) {
    const select = form.querySelector('select[name="status"]');
    const previous = form.dataset.currentStatus || "";
    const next = select ? select.value : "";
    const orderId = form.dataset.orderId || "";

    if (!next) {
        alert("Please choose an order status.");
        return false;
    }

    if (next === previous) {
        alert("This order already has that status.");
        return false;
    }

    return window.confirm(
        "Update order #" + orderId +
        " from " + previous +
        " to " + next + "?"
    );
}
</script>
</head>

<body>

<header>
    <a class="logo" href="<%= cp %>/adminDashboard">
        Food<span>wala</span>
    </a>

    <nav>
        <span class="nav-user">Hi, <%= esc(username) %></span>
        <a href="<%= cp %>/restaurent">Restaurants</a>
        <a href="<%= cp %>/adminDashboard">Dashboard</a>
        <a class="active" href="<%= cp %>/orderManagement">Manage Orders</a>
        <a href="<%= cp %>/adminMenu">Manage Menu</a>
        <a href="<%= cp %>/logout">Logout</a>
    </nav>
</header>

<main>
    <section class="page-heading">
        <div>
            <div class="eyebrow">FOODWALA ADMINISTRATION</div>
            <h1>Manage Orders</h1>
            <p class="subtitle">
                View customer orders and update their order status.
            </p>
        </div>

        <div class="summary">
            <div>
                <div class="summary-number"><%= orders.size() %></div>
                <div class="summary-label">Orders loaded</div>
            </div>
        </div>
    </section>

    <% if (!statusMessage.isEmpty()) { %>
        <div class="notice success" role="status">
            <strong>✓ Success</strong><br>
            <%= esc(statusMessage) %>
        </div>
    <% } %>

    <% if (!statusError.isEmpty()) { %>
        <div class="notice failure" role="alert">
            <strong>Update failed</strong><br>
            <%= esc(statusError) %>
        </div>
    <% } %>

    <div class="table-wrap">
    <% if (orders.isEmpty()) { %>
        <div class="empty">
            <strong>No orders found</strong>
            <br>
            Orders will appear here when customers place them.
            <br>
            <a href="<%= cp %>/adminDashboard">Return to Dashboard</a>
        </div>
    <% } else { %>

        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>User ID</th>
                    <th>Total Amount</th>
                    <th>Current Status</th>
                    <th>Order Date &amp; Time</th>
                    <th>Update Status</th>
                </tr>
            </thead>

            <tbody>
            <% for (Order order : orders) {
                if (order == null) {
                    continue;
                }

                String current = normalizeStatus(order.getStatus());
                String cssStatus = statusClass(current);
                String formattedDate = formatOrderDate(order.getOrderDate());
            %>
                <tr>
                    <td class="order-id">#<%= order.getOrderId() %></td>

                    <td><%= order.getUserId() %></td>

                    <td class="amount">
                        ₹<%= String.format(Locale.US, "%.2f", order.getTotalAmount()) %>
                    </td>

                    <td>
                        <span class="status <%= cssStatus %>">
                            <%= esc(current) %>
                        </span>
                    </td>

                    <td class="order-date">
                        <%= esc(formattedDate) %>
                    </td>

                    <td>
                        <form class="status-form"
                              method="post"
                              action="<%= cp %>/orderManagement"
                              data-order-id="<%= order.getOrderId() %>"
                              data-current-status="<%= esc(current) %>"
                              onsubmit="return confirmStatus(this);">

                            <input type="hidden"
                                   name="orderId"
                                   value="<%= order.getOrderId() %>">

                            <select name="status"
                                    required
                                    aria-label="New status for order <%= order.getOrderId() %>">
                                <% for (String option : statuses) { %>
                                    <option value="<%= esc(option) %>"
                                        <%= option.equals(current) ? "selected" : "" %>>
                                        <%= esc(option) %>
                                    </option>
                                <% } %>
                            </select>

                            <button type="submit">Save</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>

    <% } %>
    </div>
</main>

<footer>
    Foodwala Admin Panel &copy; <%= java.time.Year.now().getValue() %>
</footer>

</body>
</html>
