
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.module.Menu" %>
<%@ page import="com.tap.module.Restaurent" %>
<%@ page import="com.tap.module.CartItem" %>

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

        String url = String.valueOf(value).trim();
        if (url.isEmpty()) return "";

        // Remove accidental Markdown link formatting.
        if (url.startsWith("[") && url.contains("](") && url.endsWith(")")) {
            int start = url.indexOf("](");
            url = url.substring(start + 2, url.length() - 1).trim();
        }

        String lower = url.toLowerCase(Locale.ROOT);

        if (lower.startsWith("https://") || lower.startsWith("http://")) {
            return url;
        }

        if (url.startsWith("/")
                && !url.startsWith("//")
                && !url.contains("\\")
                && !url.contains("..")) {
            return url;
        }

        if (!url.startsWith("//")
                && !url.contains("\\")
                && !url.contains("..")
                && !url.contains(":")
                && !url.startsWith("#")) {
            return contextPath + "/" + url.replaceAll("^/+", "");
        }

        return "";
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    String contextPath = request.getContextPath();

    Restaurent restaurent =
        (Restaurent) request.getAttribute("restaurent");

    List<Menu> menus =
        (List<Menu>) request.getAttribute("menus");

    Integer restaurentId =
        (Integer) request.getAttribute("restaurentId");

    if (restaurent == null || restaurentId == null) {
        response.sendRedirect(contextPath + "/restaurent");
        return;
    }

    if (menus == null) {
        menus = new java.util.ArrayList<Menu>();
    }

    Object userId = session.getAttribute("userId");

    int cartCount = 0;
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof Map<?, ?>) {
        Map<?, ?> cart = (Map<?, ?>) cartObject;

        for (Object value : cart.values()) {
            if (value instanceof CartItem) {
                cartCount += Math.max(
                    0, ((CartItem) value).getQuantity()
                );
            }
        }
    }

    String cartMessage =
        (String) request.getAttribute("cartMessage");

    double discountPercent = restaurent.getDiscountPercent();

    if (Double.isNaN(discountPercent)
            || Double.isInfinite(discountPercent)) {
        discountPercent = 0;
    }

    discountPercent = Math.max(0, Math.min(100, discountPercent));

    String formattedRating =
        String.format(Locale.US, "%.1f", restaurent.getRating());

    String restaurantImage =
        safeImageUrl(restaurent.getImagePath(), contextPath);

    System.out.println("[Foodwala Menu] Restaurant ID: " + restaurentId);
    System.out.println("[Foodwala Menu] Restaurant: " + restaurent.getName());
    System.out.println("[Foodwala Menu] Image URL: " + restaurantImage);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= esc(restaurent.getName()) %> | Foodwala Menu</title>
<meta name="theme-color" content="#080808">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap"
      rel="stylesheet">

<style>
:root {
    --bg: #080808;
    --panel: #111111;
    --panel-2: #181818;
    --panel-3: #222222;
    --orange: #ff6b00;
    --orange-dark: #e65c00;
    --orange-light: #ff984d;
    --text: #ffffff;
    --muted: #b8b8b8;
    --border: #303030;
    --green: #75e0a0;
    --red: #ff9292;
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
    background: var(--bg);
}

body {
    margin: 0;
    min-height: 100vh;
    background:
        radial-gradient(
            circle at 10% 0%,
            rgba(255, 107, 0, 0.08),
            transparent 30%
        ),
        var(--bg);
    color: var(--text);
    font-family: Inter, Arial, sans-serif;
}

a {
    color: inherit;
    text-decoration: none;
}

button, input {
    font: inherit;
}

button:focus-visible,
a:focus-visible,
input:focus-visible {
    outline: 2px solid var(--orange);
    outline-offset: 3px;
}

.navbar {
    position: sticky;
    top: 0;
    z-index: 10;
    min-height: 70px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 14px;
    padding: 15px 5%;
    background: rgba(8, 8, 8, 0.96);
    border-bottom: 1px solid var(--border);
    box-shadow: 0 5px 22px rgba(0, 0, 0, 0.25);
    backdrop-filter: blur(12px);
}

.brand {
    color: var(--orange);
    font-family: Poppins, sans-serif;
    font-size: 27px;
    font-weight: 800;
    letter-spacing: -.8px;
}

.brand span {
    color: var(--text);
}

.nav-links {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 18px;
    color: var(--muted);
    font-size: 13px;
    font-weight: 700;
}

.nav-links a {
    transition: color .2s ease;
}

.nav-links a:hover {
    color: var(--orange-light);
}

.cart-link {
    padding: 10px 13px;
    border: 1px solid var(--orange);
    border-radius: 9px;
    color: var(--orange-light) !important;
}

.container {
    width: min(1400px, 92%);
    margin: 0 auto;
}

.back-link {
    display: inline-flex;
    margin: 25px 0 18px;
    color: var(--orange-light);
    font-size: 13px;
    font-weight: 800;
}

.back-link:hover {
    color: #ffffff;
}

/* Restaurant banner */

.restaurant-banner {
    position: relative;
    isolation: isolate;
    overflow: hidden;
    min-height: 340px;
    margin-bottom: 36px;
    border: 1px solid var(--border);
    border-radius: 20px;
    background: #151515;
    box-shadow: 0 8px 28px rgba(0, 0, 0, .25);
}

.restaurant-banner-fallback {
    position: absolute;
    inset: 0 0 0 auto;
    z-index: 0;
    width: 55%;
    display: grid;
    place-items: center;
    background: linear-gradient(135deg, #292929, #151515);
    color: var(--orange-light);
    font-size: 64px;
}

.restaurant-banner-image {
    position: absolute;
    inset: 0 0 0 auto;
    z-index: 1;
    width: 55%;
    height: 100%;
    display: block;
    object-fit: cover;
    object-position: center;
}

.restaurant-banner-shade {
    position: absolute;
    inset: 0;
    z-index: 2;
    pointer-events: none;
    background: linear-gradient(
        90deg,
        #151515 0%,
        #151515 30%,
        rgba(21, 21, 21, .98) 40%,
        rgba(21, 21, 21, .85) 49%,
        rgba(21, 21, 21, .35) 64%,
        rgba(21, 21, 21, .05) 82%,
        transparent 100%
    );
}

.restaurant-banner-content {
    position: relative;
    z-index: 3;
    width: 68%;
    padding: clamp(25px, 4vw, 45px);
    color: var(--text);
}

.restaurant-tag {
    display: inline-block;
    margin-bottom: 13px;
    padding: 8px 12px;
    color: #ffffff;
    background: var(--orange);
    border-radius: 30px;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1px;
}

.restaurant-banner h1 {
    margin: 0 0 12px;
    font-family: Poppins, sans-serif;
    font-size: clamp(30px, 4vw, 46px);
    line-height: 1.2;
    overflow-wrap: anywhere;
}

.restaurant-banner p {
    margin: 8px 0;
    color: #d0d0d0;
    font-size: 14px;
    line-height: 1.7;
    overflow-wrap: anywhere;
}

.restaurant-meta {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 14px;
    color: #e5e5e5;
    font-size: 13px;
}

.rating {
    color: #ffbd59;
    font-weight: 800;
}

.discount-note {
    margin-top: 15px !important;
    color: var(--green) !important;
    font-weight: 800;
}

.success-message {
    margin: 0 0 22px;
    padding: 14px 16px;
    border: 1px solid #285d3a;
    border-radius: 10px;
    background: #102819;
    color: #9af0b4;
    font-size: 13px;
    font-weight: 700;
    line-height: 1.6;
}

/* Menu heading and search */

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: end;
    flex-wrap: wrap;
    gap: 18px;
    margin-bottom: 23px;
}

.section-heading h2 {
    margin: 0;
    font-family: Poppins, sans-serif;
    font-size: clamp(22px, 3vw, 30px);
    color: #ffffff;
}

.section-heading p {
    margin: 8px 0 0;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
}

.search-wrap {
    width: min(100%, 360px);
}

.search-label {
    display: block;
    margin-bottom: 7px;
    color: #d0d0d0;
    font-size: 11px;
    font-weight: 800;
}

.search {
    width: 100%;
    min-height: 46px;
    padding: 0 14px;
    border: 1px solid #383838;
    border-radius: 10px;
    background: #171717;
    color: #ffffff;
    font-size: 14px;
}

.search::placeholder {
    color: #999999;
}

.search:focus {
    border-color: var(--orange);
}

/* Food cards */

.menu-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 22px;
    padding-bottom: 55px;
}

.food-card {
    min-width: 0;
    overflow: hidden;
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 16px;
    box-shadow: 0 4px 18px rgba(0, 0, 0, .18);
    transition: transform .2s ease, border-color .2s ease;
}

.food-card:hover {
    transform: translateY(-3px);
    border-color: var(--orange);
}

.food-card[hidden],
.empty-state[hidden] {
    display: none;
}

.food-image-wrap {
    position: relative;
    height: 205px;
    overflow: hidden;
    background: #222222;
}

.food-image {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform .35s ease;
}

.food-card:hover .food-image {
    transform: scale(1.035);
}

.image-fallback {
    display: none;
    width: 100%;
    height: 100%;
    place-items: center;
    background: linear-gradient(135deg, #292929, #171717);
    color: var(--orange-light);
    font-size: 50px;
}

.availability {
    position: absolute;
    top: 12px;
    left: 12px;
    padding: 7px 9px;
    border-radius: 30px;
    background: #163d27;
    color: #8ef0b1;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .3px;
}

.availability.unavailable {
    background: #401d1d;
    color: #ffaaaa;
}

.food-details {
    padding: 18px;
    background: var(--panel);
}

.food-details h3 {
    margin: 0 0 8px;
    font-family: Poppins, sans-serif;
    font-size: 17px;
    line-height: 1.4;
    color: #ffffff;
    overflow-wrap: anywhere;
}

.description {
    min-height: 40px;
    margin: 0 0 17px;
    color: #c2c2c2;
    font-size: 12px;
    line-height: 1.7;
    overflow-wrap: anywhere;
}

.food-bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
}

.price {
    color: var(--orange-light);
    font-size: 19px;
    font-weight: 800;
    white-space: nowrap;
}

.original-price {
    display: block;
    margin-bottom: 4px;
    color: #aaaaaa;
    font-size: 12px;
    font-weight: 500;
    text-decoration: line-through;
}

.add-form {
    margin: 0;
}

.add-button {
    min-height: 42px;
    padding: 10px 14px;
    border: 1px solid var(--orange);
    border-radius: 9px;
    background: var(--orange);
    color: #ffffff;
    font-size: 12px;
    font-weight: 800;
    cursor: pointer;
    transition: background .2s ease, transform .2s ease;
}

.add-button:hover {
    background: var(--orange-dark);
    border-color: var(--orange-dark);
}

.add-button:active:not(:disabled) {
    transform: scale(.97);
}

.add-button:disabled {
    background: #333333;
    border-color: #444444;
    color: #aaaaaa;
    cursor: not-allowed;
}

/* Empty state */

.empty-state {
    grid-column: 1 / -1;
    padding: 48px 20px;
    border: 1px solid var(--border);
    border-radius: 16px;
    background: var(--panel);
    color: #ffffff;
    text-align: center;
}

.empty-icon {
    margin-bottom: 12px;
    font-size: 35px;
}

.empty-state h3 {
    margin: 0 0 10px;
    font-family: Poppins, sans-serif;
    font-size: 20px;
    color: #ffffff;
}

.empty-state p {
    max-width: 450px;
    margin: 0 auto;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.7;
}

/* Footer */

.footer {
    padding: 25px 5%;
    border-top: 1px solid var(--border);
    background: #050505;
    color: #b8b8b8;
    text-align: center;
    font-size: 12px;
    line-height: 1.7;
}

@media (max-width: 900px) {
    .menu-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 17px;
    }

    .food-image-wrap {
        height: 190px;
    }

    .restaurant-banner {
        min-height: 320px;
    }

    .restaurant-banner-content {
        width: 75%;
    }
}

@media (max-width: 600px) {
    .navbar {
        padding: 13px 4%;
    }

    .brand {
        font-size: 24px;
    }

    .nav-links {
        gap: 12px;
        font-size: 12px;
    }

    .container {
        width: 92%;
    }

    .menu-grid {
        grid-template-columns: 1fr;
        gap: 17px;
    }

    .food-image-wrap {
        height: 225px;
    }

    .section-heading {
        align-items: stretch;
    }

    .search-wrap {
        width: 100%;
    }

    .restaurant-banner {
        min-height: 440px;
    }

    .restaurant-banner-image,
    .restaurant-banner-fallback {
        inset: auto 0 0 0;
        width: 100%;
        height: 45%;
    }

    .restaurant-banner-shade {
        background: linear-gradient(
            180deg,
            #151515 0%,
            #151515 40%,
            rgba(21, 21, 21, .95) 52%,
            rgba(21, 21, 21, .35) 75%,
            transparent 100%
        );
    }

    .restaurant-banner-content {
        width: 100%;
        padding: 24px;
    }
}

@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        scroll-behavior: auto !important;
        transition: none !important;
        animation: none !important;
    }
}
</style>
</head>

<body>

<header class="navbar">
    <a class="brand"
       href="<%= contextPath %>/restaurent"
       aria-label="Foodwala restaurant list">
        Food<span>wala.</span>
    </a>

    <nav class="nav-links" aria-label="Main navigation">
        <a href="<%= contextPath %>/restaurent">Restaurants</a>
        <a href="<%= contextPath %>/favorites">Favorites</a>

        <a class="cart-link" href="<%= contextPath %>/cart">
            Cart (<%= cartCount %>)
        </a>

        <% if (userId != null) { %>
            <a href="<%= contextPath %>/MyOrders.jsp">My Orders</a>
            <a href="<%= contextPath %>/logout">Logout</a>
        <% } else { %>
            <a href="<%= contextPath %>/Login.jsp">Login</a>
        <% } %>
    </nav>
</header>

<main class="container">

    <a class="back-link" href="<%= contextPath %>/restaurent">
        &#8592; Back to restaurants
    </a>

    <section class="restaurant-banner" aria-labelledby="restaurantTitle">

        <div class="restaurant-banner-fallback" aria-hidden="true">
            &#127860;
        </div>

        <% if (!restaurantImage.isEmpty()) { %>
            <img
                class="restaurant-banner-image"
                src="<%= esc(restaurantImage) %>"
                alt="<%= esc(restaurent.getName()) %> restaurant"
                fetchpriority="high"
                onerror="this.style.display='none';">
        <% } %>

        <div class="restaurant-banner-shade" aria-hidden="true"></div>

        <div class="restaurant-banner-content">
            <span class="restaurant-tag">FOODWALA RESTAURANT</span>

            <h1 id="restaurantTitle">
                <%= esc(restaurent.getName()) %>
            </h1>

            <p><%= esc(restaurent.getCuisineType()) %></p>

            <div class="restaurant-meta">
                <span class="rating">&#9733; <%= formattedRating %></span>
                <span aria-hidden="true">&bull;</span>
                <span>Delivery: <%= esc(restaurent.getDeliveryTime()) %></span>
            </div>

            <p><%= esc(restaurent.getAddress()) %></p>

            <% if (discountPercent > 0) { %>
                <p class="discount-note">
                    Save <%= String.format(Locale.US, "%.0f",
                        discountPercent) %>% on eligible menu items
                </p>
            <% } %>
        </div>
    </section>

    <% if (cartMessage != null && !cartMessage.trim().isEmpty()) { %>
        <div class="success-message" role="status" aria-live="polite">
            <%= esc(cartMessage) %>
        </div>
    <% } %>

    <section aria-labelledby="menuHeading">
        <div class="section-heading">
            <div>
                <h2 id="menuHeading">Explore the menu</h2>
                <p>Discover your favourites and add them to your cart.</p>
            </div>

            <div class="search-wrap">
                <label class="search-label" for="menuSearch">
                    FIND YOUR FAVOURITE
                </label>
                <input class="search"
                    id="menuSearch"
                    type="search"
                    placeholder="Search food items..."
                    autocomplete="off"
                    aria-controls="menuGrid">
            </div>
        </div>

        <div class="menu-grid" id="menuGrid">

        <% if (menus.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon" aria-hidden="true">&#127869;</div>
                <h3>No menu items available yet</h3>
                <p>
                    This restaurant has no menu items to display right now.
                    Please check back later.
                </p>
            </div>
        <% } else { %>

            <% for (Menu item : menus) {
                if (item == null) continue;

                String itemName = item.getItemName() == null
                    ? "Food item" : item.getItemName().trim();

                if (itemName.isEmpty()) itemName = "Food item";

                String description = item.getDescription() == null
                    || item.getDescription().trim().isEmpty()
                    ? "Freshly prepared for you."
                    : item.getDescription().trim();

                String imageUrl =
                    safeImageUrl(item.getImagePath(), contextPath);

                boolean available = item.isAvailable();

                double originalPrice = item.getPrice();

                if (Double.isNaN(originalPrice)
                        || Double.isInfinite(originalPrice)
                        || originalPrice < 0) {
                    originalPrice = 0;
                }

                double discountedPrice =
                    restaurent.getDiscountedPrice(originalPrice);

                if (Double.isNaN(discountedPrice)
                        || Double.isInfinite(discountedPrice)
                        || discountedPrice < 0) {
                    discountedPrice = originalPrice;
                }

                String searchableName = itemName.toLowerCase(Locale.ROOT);
                String searchableDescription =
                    description.toLowerCase(Locale.ROOT);
            %>

            <article class="food-card"
                data-name="<%= esc(searchableName) %>"
                data-description="<%= esc(searchableDescription) %>">

                <div class="food-image-wrap">
                    <% if (!imageUrl.isEmpty()) { %>
                        <img class="food-image"
                            src="<%= esc(imageUrl) %>"
                            alt="<%= esc(itemName) %>"
                            loading="lazy"
                            onerror="this.style.display='none';this.nextElementSibling.style.display='grid';">
                    <% } %>

                    <div class="image-fallback"
                        role="img"
                        aria-label="Food image unavailable"
                        style="<%= imageUrl.isEmpty()
                            ? "display:grid" : "" %>">&#127829;</div>

                    <span class="availability <%= available
                        ? "" : "unavailable" %>">
                        <%= available ? "AVAILABLE" : "SOLD OUT" %>
                    </span>
                </div>

                <div class="food-details">
                    <h3><%= esc(itemName) %></h3>
                    <p class="description"><%= esc(description) %></p>

                    <div class="food-bottom">
                        <div class="price">
                            <% if (discountPercent > 0
                                    && discountedPrice < originalPrice) { %>
                                <span class="original-price">
                                    &#8377;<%= String.format(Locale.US,
                                        "%.2f", originalPrice) %>
                                </span>
                            <% } %>

                            &#8377;<%= String.format(Locale.US,
                                "%.2f", discountedPrice) %>
                        </div>

                        <% if (available) { %>
                            <form class="add-form"
                                action="<%= contextPath %>/addToCart"
                                method="post">

                                <input type="hidden" name="menuId"
                                    value="<%= item.getMenuId() %>">

                                <input type="hidden" name="restaurentId"
                                    value="<%= restaurentId %>">

                                <button type="submit" class="add-button">
                                    + Add to Cart
                                </button>
                            </form>
                        <% } else { %>
                            <button type="button" class="add-button" disabled>
                                Sold Out
                            </button>
                        <% } %>
                    </div>
                </div>
            </article>

            <% } %>

            <div class="empty-state" id="noSearchResults" hidden>
                <div class="empty-icon" aria-hidden="true">&#128269;</div>
                <h3>No matching food items</h3>
                <p>Try another search term to find something delicious.</p>
            </div>
        <% } %>

        </div>
    </section>
</main>

<footer class="footer">
    Foodwala &copy; <%= java.time.Year.now().getValue() %>
    — Good food, delivered with love.
</footer>

<script>
(function () {
    "use strict";

    const search = document.getElementById("menuSearch");
    const grid = document.getElementById("menuGrid");
    const noResults = document.getElementById("noSearchResults");

    if (!search || !grid) return;

    const cards = Array.from(grid.querySelectorAll(".food-card"));

    function filterMenu() {
        const query = search.value.trim().toLocaleLowerCase();
        let visibleCount = 0;

        cards.forEach(function (card) {
            const name = card.dataset.name || "";
            const description = card.dataset.description || "";

            const matches =
                name.includes(query) || description.includes(query);

            card.hidden = !matches;

            if (matches) visibleCount++;
        });

        if (noResults) {
            noResults.hidden =
                visibleCount !== 0 || cards.length === 0;
        }
    }

    search.addEventListener("input", filterMenu);
})();
</script>

</body>
</html>
