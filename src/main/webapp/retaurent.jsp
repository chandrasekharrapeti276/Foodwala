
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.module.Restaurent" %>

<%!
    public String esc(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();

    Object userIdObject = session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    boolean loggedIn = userIdObject != null;
    boolean isAdmin = loggedIn
            && role != null
            && "ADMIN".equalsIgnoreCase(role.trim());

    if (username == null || username.trim().isEmpty()) {
        username = "Food Lover";
    }

    List<Restaurent> restaurents =
            (List<Restaurent>) request.getAttribute("restaurents");

    String favoriteMessage =
            (String) session.getAttribute("favoriteMessage");

    String favoriteError =
            (String) session.getAttribute("favoriteError");

    session.removeAttribute("favoriteMessage");
    session.removeAttribute("favoriteError");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Foodwala | Restaurants</title>

<style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    :root {
        --orange: #ff6b00;
        --orange-dark: #e85d00;
        --background: #101010;
        --surface: #1b1b1b;
        --surface-light: #252525;
        --text: #ffffff;
        --muted: #b7b7b7;
        --border: #343434;
        --green: #42c878;
        --red: #ff6464;
    }

    body {
        font-family: Arial, Helvetica, sans-serif;
        background: var(--background);
        color: var(--text);
        min-height: 100vh;
    }

    a {
        color: inherit;
        text-decoration: none;
    }

    button {
        font: inherit;
    }

    .navbar {
        background: #181818;
        border-bottom: 1px solid var(--border);
        padding: 17px 5%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
        flex-wrap: wrap;
    }

    .brand {
        color: var(--orange);
        font-size: 29px;
        font-weight: 800;
        letter-spacing: -1px;
    }

    .brand span {
        color: #ffffff;
    }

    .nav-links {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        flex-wrap: wrap;
        gap: 8px;
    }

    .nav-links a {
        display: inline-block;
        padding: 10px 12px;
        border-radius: 7px;
        font-size: 14px;
        font-weight: 600;
        color: #e5e5e5;
        transition: background 0.2s, color 0.2s;
    }

    .nav-links a:hover {
        background: var(--surface-light);
        color: var(--orange);
    }

    .nav-links .login-button,
    .nav-links .admin-button {
        background: var(--orange);
        color: #ffffff;
    }

    .nav-links .login-button:hover,
    .nav-links .admin-button:hover {
        background: var(--orange-dark);
        color: #ffffff;
    }

    .nav-links .logout-button {
        border: 1px solid var(--orange);
        color: var(--orange);
    }

    .welcome-bar {
        padding: 13px 5%;
        background: #171717;
        color: var(--muted);
        border-bottom: 1px solid #282828;
        font-size: 14px;
    }

    .welcome-bar strong {
        color: #ffffff;
    }

    .highlight {
        color: var(--orange);
        font-weight: 700;
    }

    .container {
        width: 90%;
        max-width: 1400px;
        margin: 0 auto;
        padding: 35px 0 55px;
    }

    .hero {
        margin-bottom: 28px;
    }

    .hero h1 {
        font-size: clamp(28px, 4vw, 40px);
        margin-bottom: 10px;
    }

    .hero h1 span {
        color: var(--orange);
    }

    .hero p {
        color: var(--muted);
        line-height: 1.6;
        font-size: 15px;
    }

    .message {
        padding: 13px 16px;
        border-radius: 8px;
        margin-bottom: 20px;
        font-size: 14px;
    }

    .success-message {
        background: rgba(66, 200, 120, 0.12);
        color: var(--green);
        border: 1px solid rgba(66, 200, 120, 0.3);
    }

    .error-message {
        background: rgba(255, 100, 100, 0.1);
        color: var(--red);
        border: 1px solid rgba(255, 100, 100, 0.3);
    }

    .restaurant-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 24px;
    }

    .restaurant-card {
        min-width: 0;
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 14px;
        overflow: hidden;
        transition: transform 0.2s, border-color 0.2s;
    }

    .restaurant-card:hover {
        transform: translateY(-4px);
        border-color: var(--orange);
    }

    .restaurant-image-wrapper {
        width: 100%;
        height: 215px;
        background: #303030;
        overflow: hidden;
    }

    .restaurant-image {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }

    .restaurant-content {
        padding: 19px;
    }

    .restaurant-name {
        font-size: 21px;
        line-height: 1.4;
        margin-bottom: 8px;
        overflow-wrap: anywhere;
    }

    .cuisine {
        color: var(--orange);
        font-size: 14px;
        font-weight: 700;
        margin-bottom: 12px;
    }

    .restaurant-details {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        color: var(--muted);
        font-size: 13px;
        margin-bottom: 12px;
    }

    .rating {
        color: #ffd166;
        font-weight: 700;
    }

    .address {
        color: var(--muted);
        font-size: 13px;
        line-height: 1.6;
        min-height: 40px;
        margin-bottom: 18px;
        overflow-wrap: anywhere;
    }

    .card-actions {
        display: flex;
        gap: 10px;
        align-items: stretch;
    }

    .card-button {
        width: 100%;
        display: inline-flex;
        justify-content: center;
        align-items: center;
        text-align: center;
        border: none;
        border-radius: 7px;
        padding: 11px 10px;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        transition: background 0.2s;
    }

    .menu-button {
        flex: 1;
        background: var(--orange);
        color: #ffffff;
    }

    .menu-button:hover {
        background: var(--orange-dark);
    }

    .favorite-form {
        flex: 1;
        min-width: 0;
    }

    .favorite-button {
        background: #303030;
        color: #ff8a43;
        border: 1px solid #484848;
    }

    .favorite-button:hover {
        background: #3a2a20;
        border-color: var(--orange);
    }

    .empty-state {
        background: var(--surface);
        border: 1px solid var(--border);
        padding: 45px 20px;
        text-align: center;
        border-radius: 12px;
        color: var(--muted);
        line-height: 1.8;
    }

    .empty-state h2 {
        color: #ffffff;
        margin-bottom: 10px;
    }

    .footer {
        padding: 25px 5%;
        text-align: center;
        background: #181818;
        color: #999999;
        border-top: 1px solid var(--border);
        font-size: 13px;
    }

    .footer span {
        color: var(--orange);
        font-weight: 700;
    }

    @media (max-width: 1000px) {
        .restaurant-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }
    }

    @media (max-width: 650px) {
        .navbar {
            padding: 15px 4%;
        }

        .brand {
            font-size: 25px;
        }

        .nav-links {
            justify-content: flex-start;
            width: 100%;
            gap: 5px;
        }

        .nav-links a {
            padding: 9px 10px;
            font-size: 12px;
        }

        .container {
            width: 92%;
            padding-top: 27px;
        }

        .restaurant-grid {
            grid-template-columns: 1fr;
        }

        .restaurant-image-wrapper {
            height: 220px;
        }
    }
</style>
</head>

<body>

<header class="navbar">
    <a class="brand" href="<%= contextPath %>/restaurent">
        Food<span>wala</span>
    </a>

    <nav class="nav-links" aria-label="Main navigation">

        <a href="<%= contextPath %>/restaurent">Restaurants</a>

        <a href="<%= contextPath %>/favorites">Favorites</a>

        <a href="<%= contextPath %>/Cart.jsp">Cart</a>

        <% if (isAdmin) { %>

            <a class="admin-button"
               href="<%= contextPath %>/adminDashboard">
                Admin Dashboard
            </a>

            <!-- Correct mapping from OrderManagementController -->
            <a class="admin-button"
               href="<%= contextPath %>/orderManagement">
                Manage Orders
            </a>

        <% } %>

        <% if (loggedIn) { %>

            <a class="logout-button"
               href="<%= contextPath %>/logout">
                Logout
            </a>

        <% } else { %>

            <a class="login-button"
               href="<%= contextPath %>/Login.jsp">
                Login
            </a>

        <% } %>

    </nav>
</header>

<div class="welcome-bar">
    Welcome, <strong><%= esc(username) %></strong>!
    <span class="highlight">Discover your next favourite meal.</span>
</div>

<main class="container">

    <section class="hero">
        <h1>Discover Restaurants <span>Near You</span></h1>
        <p>
            Explore delicious food, discover local restaurants,
            and choose your next meal with Foodwala.
        </p>
    </section>

    <% if (favoriteMessage != null && !favoriteMessage.trim().isEmpty()) { %>
        <div class="message success-message">
            <%= esc(favoriteMessage) %>
        </div>
    <% } %>

    <% if (favoriteError != null && !favoriteError.trim().isEmpty()) { %>
        <div class="message error-message">
            <%= esc(favoriteError) %>
        </div>
    <% } %>

    <% if (restaurents != null && !restaurents.isEmpty()) { %>

        <section class="restaurant-grid">

            <% for (Restaurent restaurant : restaurents) {

                String restaurantName = restaurant.getName();
                String cuisineType = restaurant.getCuisineType();
                String address = restaurant.getAddress();
                String imagePath = restaurant.getImagePath();

                if (imagePath == null || imagePath.trim().isEmpty()) {
                    imagePath = contextPath
                            + "/images/restaurant-placeholder.jpg";
                }

                String ratingText =
                        String.valueOf(restaurant.getRating());

                String deliveryTime =
                        String.valueOf(restaurant.getDeliveryTime());
            %>

                <article class="restaurant-card">

                    <div class="restaurant-image-wrapper">
                        <img
                            class="restaurant-image"
                            src="<%= esc(imagePath) %>"
                            alt="<%= esc(restaurantName) %>"
                            loading="lazy"
                            onerror="this.onerror=null;this.src='<%= contextPath %>/images/restaurant-placeholder.jpg';">
                    </div>

                    <div class="restaurant-content">

                        <h2 class="restaurant-name">
                            <%= esc(restaurantName) %>
                        </h2>

                        <div class="cuisine">
                            <%= esc(cuisineType) %>
                        </div>

                        <div class="restaurant-details">
                            <span class="rating">
                                ★ <%= esc(ratingText) %>
                            </span>

                            <span>
                                Delivery: <%= esc(deliveryTime) %>
                            </span>
                        </div>

                        <p class="address">
                            <%= esc(address) %>
                        </p>

                        <div class="card-actions">

                            <a class="card-button menu-button"
                               href="<%= contextPath %>/menu?restaurentId=<%= restaurant.getRestaurentId() %>">
                                View Menu
                            </a>

                            <form class="favorite-form"
                                  action="<%= contextPath %>/favorites"
                                  method="post">

                                <input type="hidden"
                                       name="action"
                                       value="add">

                                <input type="hidden"
                                       name="restaurentId"
                                       value="<%= restaurant.getRestaurentId() %>">

                                <button type="submit"
                                        class="card-button favorite-button">
                                    ♥ Favorite
                                </button>

                            </form>

                        </div>
                    </div>
                </article>

            <% } %>

        </section>

    <% } else { %>

        <section class="empty-state">
            <h2>No Restaurants Available</h2>
            <p>
                No restaurants are currently being displayed.
                Please check your restaurant database and servlet query.
            </p>
        </section>

    <% } %>

</main>

<footer class="footer">
    Made with <span>♥</span> by Foodwala
</footer>

</body>
</html>
