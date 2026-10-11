
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,com.tap.module.Restaurent" %>

<%!
    private String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String safeImageUrl(Object value, String contextPath) {
        if (value == null) return "";

        String url = value.toString().trim();

        if (url.isEmpty() || url.startsWith("//")
                || url.contains("\r") || url.contains("\n")) {
            return "";
        }

        String lower = url.toLowerCase(java.util.Locale.ROOT);

        if (lower.startsWith("https://") || lower.startsWith("http://")) {
            return url;
        }

        if (url.startsWith("/") && !url.startsWith("//")) {
            return url;
        }

        if (url.matches("^[a-zA-Z][a-zA-Z0-9+.-]*:.*")) {
            return "";
        }

        return contextPath + "/" + url.replaceFirst("^/+", "");
    }
%>

<%
    String cp = request.getContextPath();

    Object userId = session.getAttribute("userId");
    Object roleObject = session.getAttribute("role");

    if (userId == null || roleObject == null
            || !"ADMIN".equalsIgnoreCase(roleObject.toString().trim())) {
        response.sendRedirect(cp + "/Login.jsp");
        return;
    }

    Object usernameObject = session.getAttribute("username");
    String username = usernameObject == null
            ? "Admin" : usernameObject.toString();

    Object messageObject = request.getAttribute("adminMessage");
    String adminMessage = messageObject == null
            ? "" : messageObject.toString();

    List<Restaurent> restaurants = null;
    Object restaurantsObject = request.getAttribute("restaurants");

    if (restaurantsObject instanceof List<?>) {
        restaurants = (List<Restaurent>) restaurantsObject;
    }

    Restaurent editRestaurant = null;
    Object editObject = request.getAttribute("editRestaurant");

    if (editObject instanceof Restaurent) {
        editRestaurant = (Restaurent) editObject;
    }

    String formAction = editRestaurant == null ? "add" : "update";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Foodwala | Restaurant Management</title>

<style>
* { box-sizing: border-box; }

:root {
    --bg: #09090b;
    --panel: #151518;
    --panel2: #101013;
    --border: #29292e;
    --text: #f7f7f8;
    --muted: #a0a0aa;
    --orange: #ff6b35;
    --green: #22c55e;
    --red: #ef4444;
}

body {
    margin: 0;
    background: var(--bg);
    color: var(--text);
    font-family: Arial, Helvetica, sans-serif;
    min-height: 100vh;
}

a { color: inherit; text-decoration: none; }

.navbar {
    padding: 16px 4%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    flex-wrap: wrap;
    background: #101013;
    border-bottom: 1px solid var(--border);
}

.brand {
    font-size: 25px;
    font-weight: 900;
    letter-spacing: -1px;
}

.brand span, .orange { color: var(--orange); }

.nav-right {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
}

.welcome { color: var(--muted); font-size: 13px; }

.nav-btn, .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 10px 13px;
    border: 1px solid var(--border);
    border-radius: 9px;
    background: #202025;
    color: var(--text);
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    font-family: inherit;
}

.nav-btn.primary, .btn-orange {
    background: var(--orange);
    border-color: var(--orange);
    color: white;
}

.container {
    width: min(1400px, calc(100% - 36px));
    margin: auto;
    padding: 34px 0 55px;
}

.top-heading {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: 18px;
    flex-wrap: wrap;
    margin-bottom: 25px;
}

.eyebrow {
    color: var(--orange);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 2px;
    margin-bottom: 8px;
}

h1, h2 { margin-top: 0; }

h1 {
    font-size: clamp(27px, 4vw, 38px);
    margin-bottom: 8px;
}

h1 span { color: var(--orange); }

.subtitle, .panel-heading p {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
}

.layout {
    display: grid;
    grid-template-columns: minmax(280px, .8fr) minmax(0, 1.5fr);
    gap: 20px;
    align-items: start;
}

.panel {
    min-width: 0;
    overflow: hidden;
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 16px;
}

.panel-heading {
    padding: 20px;
    border-bottom: 1px solid var(--border);
}

.panel-heading h2 { font-size: 17px; margin-bottom: 6px; }
.panel-heading p { margin-bottom: 0; }

.form-body { padding: 20px; }
.field { margin-bottom: 15px; }

.field label {
    display: block;
    margin-bottom: 7px;
    font-size: 12px;
    font-weight: 700;
}

.field input, .field textarea {
    display: block;
    width: 100%;
    min-width: 0;
    padding: 12px;
    border: 1px solid #38383f;
    border-radius: 9px;
    background: var(--panel2);
    color: var(--text);
    font: inherit;
    font-size: 13px;
}

.field input:focus, .field textarea:focus {
    outline: 1px solid var(--orange);
    border-color: var(--orange);
}

.field textarea { resize: vertical; min-height: 75px; }

.form-actions, .actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    align-items: center;
}

.form-actions { margin-top: 20px; }

.btn-small { padding: 8px 10px; font-size: 11px; }
.btn-green { color: #86efac; border-color: #276749; }
.btn-red { color: #fca5a5; border-color: #7f1d1d; }

.inline-form { display: inline-flex; margin: 0; }

.message {
    padding: 13px 15px;
    margin-bottom: 20px;
    border: 1px solid #276749;
    border-radius: 10px;
    background: #123022;
    color: #a7f3c0;
    font-size: 13px;
    overflow-wrap: anywhere;
}

.notice {
    margin: 0 20px 20px;
    padding: 12px 14px;
    border: 1px solid #6b4a1a;
    border-radius: 9px;
    color: #fbbf24;
    background: #241b0c;
    font-size: 12px;
    line-height: 1.6;
}

.table-wrap { width: 100%; overflow-x: auto; }

table {
    width: 100%;
    min-width: 760px;
    border-collapse: collapse;
}

th, td {
    padding: 14px 15px;
    text-align: left;
    vertical-align: middle;
    border-bottom: 1px solid var(--border);
    font-size: 12px;
}

th {
    background: #101013;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: .5px;
    font-size: 10px;
}

td { color: #e4e4e7; }
tr:last-child td { border-bottom: none; }

.food-image, .no-image {
    width: 58px;
    height: 48px;
    border-radius: 8px;
    object-fit: cover;
    background: #27272a;
}

.no-image {
    align-items: center;
    justify-content: center;
    color: var(--muted);
    font-size: 10px;
}

.restaurant-name { font-weight: 800; margin-bottom: 5px; }

.restaurant-address {
    max-width: 220px;
    margin-top: 4px;
    color: var(--muted);
    font-size: 11px;
    overflow-wrap: anywhere;
}

.pill {
    display: inline-block;
    padding: 5px 8px;
    border-radius: 30px;
    font-size: 10px;
    font-weight: 800;
}

.pill-active { color: #86efac; background: #123022; }
.pill-inactive { color: #fca5a5; background: #351819; }

.empty {
    padding: 42px 20px;
    text-align: center;
}

.empty h3 { margin-bottom: 8px; }

.empty p {
    color: var(--muted);
    font-size: 12px;
    line-height: 1.6;
}

footer {
    border-top: 1px solid var(--border);
    padding: 22px;
    text-align: center;
    color: #71717a;
    font-size: 11px;
}

@media (max-width: 950px) {
    .layout { grid-template-columns: 1fr; }
}

@media (max-width: 520px) {
    .navbar { padding: 14px 16px; }
    .brand { font-size: 22px; }
    .container {
        width: calc(100% - 24px);
        padding-top: 24px;
    }
    .welcome { display: none; }
    .form-body, .panel-heading { padding: 16px; }
    .notice { margin: 0 16px 16px; }
}
</style>
</head>

<body>
<nav class="navbar">
    <a class="brand" href="<%= cp %>/adminDashboard">Food<span>wala</span></a>

    <div class="nav-right">
        <span class="welcome">Welcome, <%= esc(username) %></span>
        <a class="nav-btn" href="<%= cp %>/restaurent">View Store</a>
        <a class="nav-btn primary" href="<%= cp %>/logout">Logout</a>
    </div>
</nav>

<main class="container">
    <div class="top-heading">
        <div>
            <div class="eyebrow">FOODWALA ADMIN</div>
            <h1>Restaurant <span>Management</span></h1>
            <p class="subtitle">
                Add restaurants, update details, manage discounts,
                and activate or deactivate listings.
            </p>
        </div>
        <a class="btn" href="<%= cp %>/adminDashboard">← Back to Dashboard</a>
    </div>

    <% if (!adminMessage.trim().isEmpty()) { %>
        <div class="message" role="status"><%= esc(adminMessage) %></div>
    <% } %>

    <div class="layout">
        <section class="panel">
            <div class="panel-heading">
                <h2><%= editRestaurant == null ? "Add Restaurant" : "Edit Restaurant" %></h2>
                <p><%= editRestaurant == null
                    ? "Enter the restaurant details below."
                    : "Update the selected restaurant's details." %></p>
            </div>

            <form class="form-body"
                  action="<%= cp %>/admin/restaurants"
                  method="post">

                <input type="hidden" name="action" value="<%= formAction %>">

                <% if (editRestaurant != null) { %>
                    <input type="hidden" name="id"
                           value="<%= editRestaurant.getRestaurentId() %>">
                <% } %>

                <div class="field">
                    <label for="name">Restaurant Name *</label>
                    <input id="name" name="name" type="text" maxlength="150"
                           required
                           value="<%= esc(editRestaurant == null ? "" : editRestaurant.getName()) %>"
                           placeholder="e.g. Namma Oota">
                </div>

                <div class="field">
                    <label for="cuisineType">Cuisine Type *</label>
                    <input id="cuisineType" name="cuisineType" type="text"
                           maxlength="100" required
                           value="<%= esc(editRestaurant == null ? "" : editRestaurant.getCuisineType()) %>"
                           placeholder="e.g. South Indian">
                </div>

                <div class="field">
                    <label for="deliveryTime">Delivery Time *</label>
                    <input id="deliveryTime" name="deliveryTime" type="text"
                           maxlength="50" required
                           value="<%= esc(editRestaurant == null ? "" : editRestaurant.getDeliveryTime()) %>"
                           placeholder="e.g. 25-35 mins">
                </div>

                <div class="field">
                    <label for="address">Address *</label>
                    <textarea id="address" name="address" maxlength="500"
                              required
                              placeholder="Restaurant location"><%= esc(editRestaurant == null ? "" : editRestaurant.getAddress()) %></textarea>
                </div>

                <div class="field">
                    <label for="rating">Rating (0 to 5) *</label>
                    <input id="rating" name="rating" type="number"
                           min="0" max="5" step="0.1" required
                           value="<%= editRestaurant == null ? "4.0" : editRestaurant.getRating() %>">
                </div>

                <div class="field">
                    <label for="discountPercent">Discount Percentage (0 to 100) *</label>
                    <input id="discountPercent" name="discountPercent"
                           type="number" min="0" max="100" step="0.01"
                           required
                           value="<%= editRestaurant == null ? "0" : editRestaurant.getDiscountPercent() %>">
                </div>

                <div class="field">
                    <label for="imagePath">Restaurant Image URL</label>
                    <input id="imagePath" name="imagePath" type="url"
                           maxlength="1000"
                           value="<%= esc(editRestaurant == null ? "" : editRestaurant.getImagePath()) %>"
                           placeholder="https://example.com/restaurant.jpg">
                </div>

                <div class="form-actions">
                    <button class="btn btn-orange" type="submit">
                        <%= editRestaurant == null ? "Add Restaurant" : "Save Changes" %>
                    </button>

                    <% if (editRestaurant != null) { %>
                        <a class="btn" href="<%= cp %>/admin/restaurants">Cancel</a>
                    <% } %>
                </div>
            </form>

            <div class="notice">
                Enter a direct image URL. This form does not upload image files to the server.
            </div>
        </section>

        <section class="panel">
            <div class="panel-heading">
                <h2>Restaurant Listings</h2>
                <p><%= restaurants == null ? 0 : restaurants.size() %>
                   restaurant(s) returned by your DAO</p>
            </div>

            <% if (restaurants != null && !restaurants.isEmpty()) { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Image</th>
                                <th>Restaurant</th>
                                <th>Cuisine</th>
                                <th>Rating</th>
                                <th>Discount</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (Restaurent restaurant : restaurants) {
                               if (restaurant == null) continue;
                               String imageUrl = safeImageUrl(
                                       restaurant.getImagePath(), cp);
                        %>
                            <tr>
                                <td>
                                    <% if (!imageUrl.isEmpty()) { %>
                                        <img class="food-image"
                                             src="<%= esc(imageUrl) %>"
                                             alt="Restaurant image"
                                             loading="lazy"
                                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                        <div class="no-image" style="display:none">No image</div>
                                    <% } else { %>
                                        <div class="no-image" style="display:flex">No image</div>
                                    <% } %>
                                </td>

                                <td>
                                    <div class="restaurant-name"><%= esc(restaurant.getName()) %></div>
                                    <div class="restaurant-address"><%= esc(restaurant.getAddress()) %></div>
                                    <div class="restaurant-address">
                                        ID: <%= restaurant.getRestaurentId() %>
                                        · <%= esc(restaurant.getDeliveryTime()) %>
                                    </div>
                                </td>

                                <td><%= esc(restaurant.getCuisineType()) %></td>
                                <td>★ <%= restaurant.getRating() %></td>
                                <td><%= restaurant.getDiscountPercent() %>%</td>

                                <td>
                                    <% if (restaurant.isActive()) { %>
                                        <span class="pill pill-active">ACTIVE</span>
                                    <% } else { %>
                                        <span class="pill pill-inactive">INACTIVE</span>
                                    <% } %>
                                </td>

                                <td>
                                    <div class="actions">
                                        <a class="btn btn-small"
                                           href="<%= cp %>/admin/restaurants?action=edit&id=<%= restaurant.getRestaurentId() %>">
                                            Edit
                                        </a>

                                        <form class="inline-form"
                                              action="<%= cp %>/admin/restaurants"
                                              method="post"
                                              onsubmit="return confirm('Change this restaurant status?');">
                                            <input type="hidden" name="action" value="toggle">
                                            <input type="hidden" name="id"
                                                   value="<%= restaurant.getRestaurentId() %>">
                                            <button class="btn btn-small btn-green" type="submit">
                                                <%= restaurant.isActive() ? "Deactivate" : "Activate" %>
                                            </button>
                                        </form>

                                        <form class="inline-form"
                                              action="<%= cp %>/admin/restaurants"
                                              method="post"
                                              onsubmit="return confirm('Delete this restaurant? Related records may prevent deletion. Continue?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id"
                                                   value="<%= restaurant.getRestaurentId() %>">
                                            <button class="btn btn-small btn-red" type="submit">
                                                Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <div class="empty">
                    <h3>No Restaurants Found</h3>
                    <p>No restaurants were returned by the DAO. Check the database and the DAO query.</p>
                </div>
            <% } %>
        </section>
    </div>
</main>

<footer>
    © <%= java.time.Year.now().getValue() %>
    <span class="orange">Foodwala</span> · Restaurant Management
</footer>
</body>
</html>
