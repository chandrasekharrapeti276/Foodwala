
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.module.Menu" %>
<%@ page import="com.tap.module.Restaurent" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%!
    private String escapeHtml(Object value) {
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

    private String cleanImageUrl(Object value) {
        if (value == null) {
            return "";
        }

        String url = String.valueOf(value).trim();

        int markdownStart = url.indexOf("](");
        if (markdownStart >= 0 && url.endsWith(")")) {
            url = url.substring(markdownStart + 2, url.length() - 1).trim();
        }

        if (url.startsWith("https://") || url.startsWith("http://")) {
            return url;
        }

        return "";
    }

    private String formatPrice(double price) {
        return String.format(Locale.US, "%.2f", price);
    }
%>

<%
    String cp = request.getContextPath();

    Object userId = session.getAttribute("userId");
    Object roleObject = session.getAttribute("role");

    if (userId == null) {
        response.sendRedirect(cp + "/Login.jsp");
        return;
    }

    String role = roleObject == null ? "" : roleObject.toString().trim();

    if (!"ADMIN".equalsIgnoreCase(role)) {
        response.sendError(
            HttpServletResponse.SC_FORBIDDEN,
            "Admin access required."
        );
        return;
    }

    List<Restaurent> restaurants =
        (List<Restaurent>) request.getAttribute("restaurants");

    List<Menu> menus =
        (List<Menu>) request.getAttribute("menus");

    Menu edit = (Menu) request.getAttribute("editMenu");

    if (menus == null) {
        menus = Collections.emptyList();
    }

    int selectedId = 0;

    Object selectedValue = request.getAttribute("selectedRestaurentId");

    if (selectedValue == null) {
        selectedValue = request.getAttribute("selectedRestaurantId");
    }

    if (selectedValue != null) {
        try {
            selectedId = Integer.parseInt(selectedValue.toString());
        } catch (NumberFormatException ignored) {
            selectedId = 0;
        }
    }

    String message = (String) request.getAttribute("adminMenuMessage");
    String errorMessage = (String) request.getAttribute("adminMenuError");

    if (message == null || message.trim().isEmpty()) {
        message = (String) request.getAttribute("adminMessage");
    }

    String username = String.valueOf(
        session.getAttribute("username") == null
            ? "Admin"
            : session.getAttribute("username")
    );

    boolean editing = edit != null;

    /*
     * This hidden field lets the controller distinguish an unchecked
     * availability checkbox from a missing parameter.
     */
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Foodwala | Menu Management</title>

<style>
:root {
    --bg: #09090b;
    --header: #101013;
    --panel: #151518;
    --panel-alt: #101013;
    --input: #0e0e11;
    --border: #2b2b31;
    --text: #f7f7f8;
    --muted: #a1a1aa;
    --orange: #ff6b35;
    --orange-dark: #e6531d;
    --green: #86efac;
    --green-bg: #123022;
    --red: #fca5a5;
    --red-bg: #351819;
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

header {
    position: sticky;
    top: 0;
    z-index: 20;
    background: var(--header);
    border-bottom: 1px solid var(--border);
}

.navbar {
    max-width: 1500px;
    margin: auto;
    padding: 18px 3%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    flex-wrap: wrap;
}

.brand {
    font-size: 25px;
    font-weight: 900;
    letter-spacing: -1px;
}

.brand .brand-orange {
    color: var(--orange);
}

.brand small {
    color: var(--muted);
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0;
}

.nav-links {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 8px;
    flex-wrap: wrap;
}

.nav-links a {
    padding: 10px 13px;
    border-radius: 9px;
    color: #e4e4e7;
    font-size: 13px;
    font-weight: 700;
}

.nav-links a:hover {
    background: #242428;
}

.nav-links a.active,
.nav-links a.logout {
    background: var(--orange);
    color: white;
}

.nav-links a.active:hover,
.nav-links a.logout:hover {
    background: var(--orange-dark);
}

.welcome {
    color: var(--muted);
    font-size: 13px;
    padding: 5px;
}

main {
    width: min(1450px, 94%);
    margin: 32px auto 48px;
}

.page-heading {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 18px;
    flex-wrap: wrap;
    margin-bottom: 25px;
}

.eyebrow {
    color: var(--orange);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 10px;
}

h1 {
    font-size: clamp(28px, 4vw, 38px);
    margin: 0 0 10px;
    letter-spacing: -1px;
}

h2 {
    margin: 0 0 19px;
    font-size: 20px;
}

.subtitle {
    color: var(--muted);
    margin: 0;
    line-height: 1.7;
    max-width: 850px;
}

.panel {
    min-width: 0;
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 17px;
    padding: 25px;
    margin-top: 20px;
}

.restaurant-form {
    display: flex;
    align-items: flex-end;
    gap: 13px;
    flex-wrap: wrap;
}

.restaurant-select {
    flex: 1;
    min-width: 240px;
}

label {
    display: block;
    color: #ededf0;
    font-weight: 700;
    font-size: 13px;
    margin-bottom: 9px;
}

input,
select,
textarea {
    display: block;
    width: 100%;
    min-width: 0;
    padding: 13px 14px;
    background: var(--input);
    color: var(--text);
    border: 1px solid #393940;
    border-radius: 9px;
    font: inherit;
    font-size: 14px;
}

input::placeholder,
textarea::placeholder {
    color: #85858f;
}

select option {
    background: var(--panel);
    color: var(--text);
}

input:focus,
select:focus,
textarea:focus {
    outline: 2px solid #ff6b3540;
    border-color: var(--orange);
}

textarea {
    min-height: 100px;
    resize: vertical;
}

.fields {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.field {
    min-width: 0;
}

.field.full {
    grid-column: 1 / -1;
}

.checkbox-row {
    display: flex;
    align-items: center;
    gap: 10px;
    min-height: 42px;
}

.checkbox-row input {
    width: 18px;
    height: 18px;
    accent-color: var(--orange);
    flex: 0 0 auto;
}

.checkbox-row label {
    margin: 0;
    line-height: 1.5;
}

button,
.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    min-height: 42px;
    padding: 11px 16px;
    border: 1px solid transparent;
    border-radius: 9px;
    background: var(--orange);
    color: #fff;
    font: inherit;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    text-align: center;
    white-space: nowrap;
}

button:hover,
.btn:hover {
    background: var(--orange-dark);
}

.btn.secondary {
    background: #27272c;
    border-color: #3a3a42;
    color: #f4f4f5;
}

.btn.secondary:hover {
    background: #34343b;
}

.btn.danger {
    background: #6f2020;
    border-color: #873131;
}

.btn.danger:hover {
    background: #8f2525;
}

.btn.success {
    background: #166534;
}

.notice {
    padding: 14px 16px;
    border-radius: 10px;
    margin: 16px 0;
    line-height: 1.6;
    font-size: 14px;
    overflow-wrap: anywhere;
}

.notice.success {
    background: var(--green-bg);
    color: var(--green);
    border: 1px solid #245438;
}

.notice.error {
    background: var(--red-bg);
    color: var(--red);
    border: 1px solid #683033;
}

.notice.info {
    background: #2b1d12;
    color: #fdba74;
    border: 1px solid #633b20;
}

.section-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 18px;
}

.section-heading h2 {
    margin: 0;
}

.item-count {
    color: var(--muted);
    font-size: 13px;
}

.table-wrap {
    width: 100%;
    overflow-x: auto;
    border: 1px solid var(--border);
    border-radius: 11px;
}

table {
    width: 100%;
    min-width: 800px;
    border-collapse: collapse;
}

th,
td {
    padding: 15px 12px;
    text-align: left;
    vertical-align: middle;
    border-bottom: 1px solid var(--border);
}

th {
    background: #1c1c21;
    color: var(--orange);
    font-size: 11px;
    letter-spacing: .7px;
    text-transform: uppercase;
    white-space: nowrap;
}

td {
    color: #e4e4e7;
    font-size: 13px;
}

tbody tr {
    background: var(--panel);
}

tbody tr:hover {
    background: #1b1b20;
}

tbody tr:last-child td {
    border-bottom: 0;
}

.food-image {
    width: 72px;
    height: 60px;
    object-fit: cover;
    border-radius: 8px;
    display: block;
    margin-bottom: 8px;
    background: #26262c;
}

.food-name {
    font-weight: 800;
    overflow-wrap: anywhere;
}

.description {
    min-width: 160px;
    max-width: 270px;
    color: var(--muted);
    white-space: normal;
    line-height: 1.5;
    overflow-wrap: anywhere;
}

.price {
    color: #fff;
    font-weight: 800;
    white-space: nowrap;
}

.status {
    display: inline-block;
    padding: 6px 10px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
}

.status.available {
    background: var(--green-bg);
    color: var(--green);
}

.status.unavailable {
    background: var(--red-bg);
    color: var(--red);
}

.actions {
    display: flex;
    align-items: center;
    gap: 7px;
    flex-wrap: wrap;
}

.inline-form {
    display: inline-flex;
    margin: 0;
}

.empty-state {
    text-align: center;
    padding: 35px 18px;
    color: var(--muted);
    line-height: 1.8;
}

.empty-state strong {
    color: var(--text);
}

footer {
    background: var(--header);
    border-top: 1px solid var(--border);
    padding: 23px 15px;
    text-align: center;
    color: var(--muted);
    font-size: 12px;
}

@media (max-width: 800px) {
    .navbar {
        padding: 16px 4%;
    }

    .nav-links {
        justify-content: flex-start;
    }

    .fields {
        grid-template-columns: 1fr;
    }

    .field.full {
        grid-column: auto;
    }

    .panel {
        padding: 19px;
    }
}

@media (max-width: 560px) {
    main {
        width: 94%;
        margin-top: 24px;
    }

    .brand {
        font-size: 23px;
    }

    .nav-links a {
        padding: 9px 10px;
    }

    .restaurant-form {
        align-items: stretch;
    }

    .restaurant-select {
        min-width: 100%;
    }

    .restaurant-form button {
        width: 100%;
    }

    .panel {
        padding: 15px;
        border-radius: 13px;
    }

    .actions .btn,
    .actions button {
        flex: 1;
    }
}
</style>
</head>

<body>

<header>
    <div class="navbar">
        <a class="brand" href="<%= cp %>/adminDashboard">
            Food<span class="brand-orange">wala</span>
            <small>/ ADMIN / MENU</small>
        </a>

        <nav class="nav-links">
            <span class="welcome">Hi, <%= escapeHtml(username) %></span>
            <a href="<%= cp %>/adminDashboard">Dashboard</a>
            <a href="<%= cp %>/admin/restaurants">Restaurants</a>
            <a class="active" href="<%= cp %>/adminMenu">Menu Management</a>
            <a href="<%= cp %>/restaurent">Customer Site</a>
            <a class="logout" href="<%= cp %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main>
    <section class="page-heading">
        <div>
            <div class="eyebrow">Foodwala administration</div>
            <h1>Food Menu Management</h1>
            <p class="subtitle">
                Add dishes, update prices, and manage food availability
                across your restaurants.
            </p>
        </div>
    </section>

    <% if (message != null && !message.trim().isEmpty()) { %>
        <div class="notice success"><%= escapeHtml(message) %></div>
    <% } %>

    <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
        <div class="notice error"><%= escapeHtml(errorMessage) %></div>
    <% } %>

    <section class="panel">
        <h2>Select Restaurant</h2>

        <form method="get"
              action="<%= cp %>/adminMenu"
              class="restaurant-form">

            <div class="restaurant-select">
                <label for="restaurentId">Restaurant</label>

                <select name="restaurentId" id="restaurentId" required>
                    <option value="">-- Choose a restaurant --</option>

                    <% if (restaurants != null) {
                        for (Restaurent r : restaurants) {
                            if (r == null) continue;
                    %>
                        <option value="<%= r.getRestaurentId() %>"
                            <%= r.getRestaurentId() == selectedId ? "selected" : "" %>>
                            <%= escapeHtml(r.getName()) %>
                            — <%= escapeHtml(r.getAddress()) %>
                        </option>
                    <%  }
                       } %>
                </select>
            </div>

            <button type="submit">Load Menu</button>
        </form>

        <% if (restaurants == null || restaurants.isEmpty()) { %>
            <div class="notice info">
                No restaurants were supplied by the controller. Check that
                AdminMenuController loads the restaurant list successfully.
            </div>
        <% } %>
    </section>

    <% if (selectedId > 0) { %>
        <section class="panel">
            <h2><%= editing ? "Edit Food Item" : "Add Food Item" %></h2>

            <form method="post"
                  action="<%= cp %>/adminMenu"
                  class="fields">

                <input type="hidden" name="action"
                       value="<%= editing ? "update" : "add" %>">

                <input type="hidden" name="restaurentId"
                       value="<%= selectedId %>">

                <% if (editing) { %>
                    <input type="hidden" name="menuId"
                           value="<%= edit.getMenuId() %>">
                <% } %>

                <div class="field">
                    <label for="itemName">Food Item Name</label>
                    <input id="itemName" name="itemName"
                           maxlength="150"
                           placeholder="Example: Paneer Biryani"
                           required
                           value="<%= editing ? escapeHtml(edit.getItemName()) : "" %>">
                </div>

                <div class="field">
                    <label for="price">Price (₹)</label>
                    <input id="price" name="price" type="number"
                           min="0.01" max="1000000" step="0.01"
                           placeholder="Enter price" required
                           value="<%= editing ? formatPrice(edit.getPrice()) : "" %>">
                </div>

                <div class="field full">
                    <label for="description">Description</label>
                    <textarea id="description" name="description"
                              maxlength="1000"
                              placeholder="Describe the food item"><%= editing && edit.getDescription() != null ? escapeHtml(edit.getDescription()) : "" %></textarea>
                </div>

                <div class="field full">
                    <label for="imagePath">Food Image URL (optional)</label>
                    <input id="imagePath" name="imagePath" type="url"
                           maxlength="1000"
                           placeholder="https://example.com/food-image.jpg"
                           value="<%= editing && edit.getImagePath() != null ? escapeHtml(cleanImageUrl(edit.getImagePath())) : "" %>">
                </div>

                <div class="field full">
                    <div class="checkbox-row">
                        <input type="checkbox"
                               id="isAvailable"
                               name="isAvailable"
                               value="true"
                               <%= !editing || edit.isAvailable() ? "checked" : "" %>>
                        <label for="isAvailable">This food item is available to customers</label>
                    </div>
                </div>

                <div class="field full">
                    <div class="actions">
                        <button type="submit">
                            <%= editing ? "Save Changes" : "Add Food Item" %>
                        </button>

                        <% if (editing) { %>
                            <a class="btn secondary"
                               href="<%= cp %>/adminMenu?restaurentId=<%= selectedId %>">
                                Cancel
                            </a>
                        <% } %>
                    </div>
                </div>
            </form>
        </section>

        <section class="panel">
            <div class="section-heading">
                <h2>Food Items</h2>
                <span class="item-count"><%= menus.size() %> item(s) loaded</span>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Food Item</th>
                            <th>Description</th>
                            <th>Price</th>
                            <th>Availability</th>
                            <th>Actions</th>
                        </tr>
                    </thead>

                    <tbody>
                    <% if (!menus.isEmpty()) {
                        for (Menu m : menus) {
                            if (m == null) continue;

                            String imageUrl = cleanImageUrl(m.getImagePath());
                    %>
                        <tr>
                            <td><%= m.getMenuId() %></td>

                            <td>
                                <% if (!imageUrl.isEmpty()) { %>
                                    <img class="food-image"
                                         src="<%= escapeHtml(imageUrl) %>"
                                         alt="<%= escapeHtml(m.getItemName()) %>"
                                         loading="lazy"
                                         onerror="this.style.display='none'">
                                <% } %>

                                <div class="food-name">
                                    <%= escapeHtml(m.getItemName()) %>
                                </div>
                            </td>

                            <td class="description">
                                <%= escapeHtml(m.getDescription()) %>
                            </td>

                            <td class="price">
                                ₹<%= formatPrice(m.getPrice()) %>
                            </td>

                            <td>
                                <% if (m.isAvailable()) { %>
                                    <span class="status available">Available</span>
                                <% } else { %>
                                    <span class="status unavailable">Unavailable</span>
                                <% } %>
                            </td>

                            <td>
                                <div class="actions">
                                    <a class="btn secondary"
                                       href="<%= cp %>/adminMenu?action=edit&amp;id=<%= m.getMenuId() %>&amp;restaurentId=<%= selectedId %>">
                                        Edit
                                    </a>

                                    <form class="inline-form"
                                          method="post"
                                          action="<%= cp %>/adminMenu"
                                          onsubmit="return confirm('Change availability for this food item?');">

                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="menuId"
                                               value="<%= m.getMenuId() %>">
                                        <input type="hidden" name="restaurentId"
                                               value="<%= selectedId %>">

                                        <button type="submit" class="btn secondary">
                                            <%= m.isAvailable() ? "Disable" : "Enable" %>
                                        </button>
                                    </form>

                                    <form class="inline-form"
                                          method="post"
                                          action="<%= cp %>/adminMenu"
                                          onsubmit="return confirm('Delete this food item? This may fail if an order references it.');">

                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="menuId"
                                               value="<%= m.getMenuId() %>">
                                        <input type="hidden" name="restaurentId"
                                               value="<%= selectedId %>">

                                        <button type="submit" class="btn danger">
                                            Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <%  }
                       } else { %>
                        <tr>
                            <td colspan="6">
                                <div class="empty-state">
                                    <strong>No menu items found for this restaurant.</strong>
                                    <br>
                                    Check that this restaurant has menu rows in MySQL
                                    and that the controller loaded them successfully.
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    <% } else { %>
        <section class="panel">
            <div class="empty-state">
                <strong>Select a restaurant and click Load Menu.</strong>
                <br>
                Its food items will appear here.
            </div>
        </section>
    <% } %>
</main>

<footer>
    Foodwala Admin Panel &copy; <%= java.time.Year.now().getValue() %>
</footer>

</body>
</html>
