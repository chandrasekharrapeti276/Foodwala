<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.module.Favorite" %>

<%
    /*
     * ============================================================
     * LOGIN CHECK
     * ============================================================
     */

    Object userIdObject = session.getAttribute("userId");

    if (userIdObject == null) {

        session.setAttribute(
                "redirectAfterLogin",
                "/favorites"
        );

        response.sendRedirect(
                request.getContextPath() + "/Login.jsp"
        );

        return;
    }

    String username =
            (String) session.getAttribute("username");

    if (username == null || username.trim().isEmpty()) {
        username = "Food Lover";
    }


    /*
     * ============================================================
     * FAVORITES
     * ============================================================
     */

    List<Favorite> favorites =
            (List<Favorite>) request.getAttribute("favorites");


    /*
     * ============================================================
     * MESSAGES
     * ============================================================
     *
     * FavoritesController uses:
     *
     * favoriteMessage
     * favoriteError
     *
     */

    String favoriteMessage =
            (String) request.getAttribute("favoriteMessage");

    String favoriteError =
            (String) request.getAttribute("favoriteError");


    /*
     * ============================================================
     * CART COUNT
     * ============================================================
     */

    int cartCount = 0;

    Object cartObject =
            session.getAttribute("cart");

    if (cartObject instanceof Map) {

        cartCount =
                ((Map<?, ?>) cartObject).size();
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0">

    <title>Foodwala | Favorites</title>


    <style>

        * {
            box-sizing: border-box;
        }


        body {
            margin: 0;
            min-height: 100vh;

            font-family:
                Arial,
                Helvetica,
                sans-serif;

            background: #090b0f;
            color: #ffffff;
        }


        /*
         * ========================================================
         * NAVBAR
         * ========================================================
         */

        .navbar {

            position: sticky;
            top: 0;
            z-index: 1000;

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 16px 5%;

            background:
                rgba(10, 12, 16, 0.96);

            border-bottom:
                1px solid rgba(255, 255, 255, 0.08);

            backdrop-filter: blur(15px);
        }


        .logo {

            color: #ff6b35;

            text-decoration: none;

            font-size: 26px;
            font-weight: 900;
        }


        .nav-links {

            display: flex;
            align-items: center;

            gap: 20px;
        }


        .nav-links a {

            color: #eeeeee;

            text-decoration: none;

            font-size: 14px;
            font-weight: 600;

            transition:
                color 0.2s ease;
        }


        .nav-links a:hover {
            color: #ff6b35;
        }


        .cart-link {
            position: relative;
        }


        .cart-count {

            position: absolute;

            top: -10px;
            right: -12px;

            min-width: 19px;
            height: 19px;

            padding: 2px 5px;

            border-radius: 50%;

            background: #ff6b35;

            color: #ffffff;

            font-size: 11px;
            font-weight: 800;

            text-align: center;
        }


        /*
         * ========================================================
         * MAIN
         * ========================================================
         */

        .page-container {

            width: min(1200px, 92%);

            margin: 0 auto;

            padding: 45px 0 70px;
        }


        .page-header {

            margin-bottom: 30px;
        }


        .page-header h1 {

            margin: 0 0 8px;

            font-size: 34px;
            font-weight: 900;
        }


        .page-header p {

            margin: 0;

            color: #9da3ad;

            font-size: 15px;
        }


        /*
         * ========================================================
         * ALERTS
         * ========================================================
         */

        .alert {

            margin-bottom: 24px;

            padding: 14px 18px;

            border-radius: 12px;

            font-size: 14px;
            font-weight: 600;
        }


        .success {

            background:
                rgba(40, 167, 69, 0.15);

            border:
                1px solid rgba(40, 167, 69, 0.35);

            color: #7df29a;
        }


        .error {

            background:
                rgba(220, 53, 69, 0.15);

            border:
                1px solid rgba(220, 53, 69, 0.35);

            color: #ff8f9b;
        }


        /*
         * ========================================================
         * EMPTY STATE
         * ========================================================
         */

        .empty-state {

            padding: 70px 25px;

            text-align: center;

            background: #11151b;

            border:
                1px solid rgba(255, 255, 255, 0.07);

            border-radius: 20px;
        }


        .empty-icon {

            font-size: 58px;

            margin-bottom: 18px;
        }


        .empty-state h2 {

            margin: 0 0 10px;

            font-size: 24px;
        }


        .empty-state p {

            margin: 0 auto 25px;

            max-width: 500px;

            color: #9da3ad;

            line-height: 1.6;
        }


        .browse-button {

            display: inline-block;

            padding: 13px 22px;

            background: #ff6b35;

            color: #ffffff;

            border-radius: 10px;

            text-decoration: none;

            font-weight: 800;

            transition:
                background 0.2s ease,
                transform 0.2s ease;
        }


        .browse-button:hover {

            background: #ff5722;

            transform: translateY(-2px);
        }


        /*
         * ========================================================
         * FAVORITES GRID
         * ========================================================
         */

        .favorites-grid {

            display: grid;

            grid-template-columns:
                repeat(auto-fill, minmax(280px, 1fr));

            gap: 24px;
        }


        .favorite-card {

            overflow: hidden;

            background: #11151b;

            border:
                1px solid rgba(255, 255, 255, 0.08);

            border-radius: 18px;

            transition:
                transform 0.2s ease,
                border-color 0.2s ease,
                box-shadow 0.2s ease;
        }


        .favorite-card:hover {

            transform: translateY(-5px);

            border-color:
                rgba(255, 107, 53, 0.45);

            box-shadow:
                0 14px 35px
                rgba(0, 0, 0, 0.35);
        }


        /*
         * ========================================================
         * IMAGE
         * ========================================================
         */

        .image-wrapper {

            position: relative;

            height: 210px;

            overflow: hidden;
        }


        .restaurant-image {

            width: 100%;
            height: 100%;

            object-fit: cover;

            display: block;
        }


        .image-overlay {

            position: absolute;

            inset: 0;

            background:
                linear-gradient(
                    to bottom,
                    rgba(0, 0, 0, 0.05),
                    rgba(0, 0, 0, 0.70)
                );
        }


        .discount-badge {

            position: absolute;

            left: 14px;
            bottom: 14px;

            padding: 8px 12px;

            background:
                linear-gradient(
                    135deg,
                    #ff6b35,
                    #ff3d00
                );

            border-radius: 8px;

            color: #ffffff;

            font-size: 13px;
            font-weight: 900;
        }


        .saved-badge {

            position: absolute;

            top: 14px;
            left: 14px;

            padding: 7px 10px;

            background:
                rgba(0, 0, 0, 0.78);

            border-radius: 20px;

            color: #ffffff;

            font-size: 12px;
            font-weight: 700;
        }


        /*
         * ========================================================
         * CARD CONTENT
         * ========================================================
         */

        .card-content {

            padding: 18px;
        }


        .card-content h2 {

            margin: 0 0 8px;

            font-size: 20px;
            font-weight: 800;
        }


        .cuisine {

            margin-bottom: 12px;

            color: #aeb4bd;

            font-size: 13px;
        }


        .restaurant-meta {

            display: flex;

            flex-wrap: wrap;

            gap: 8px;

            margin-bottom: 13px;
        }


        .rating {

            padding: 5px 8px;

            background: #218739;

            border-radius: 6px;

            font-size: 12px;
            font-weight: 800;
        }


        .delivery {

            padding: 5px 8px;

            background: #1b2028;

            border-radius: 6px;

            color: #d7dbe0;

            font-size: 12px;
            font-weight: 600;
        }


        .address {

            margin-bottom: 18px;

            color: #969da8;

            font-size: 13px;

            line-height: 1.5;
        }


        /*
         * ========================================================
         * BUTTONS
         * ========================================================
         */

        .card-actions {

            display: flex;

            gap: 10px;
        }


        .menu-button,
        .remove-button {

            flex: 1;

            padding: 11px 12px;

            border-radius: 9px;

            text-align: center;

            text-decoration: none;

            font-size: 13px;
            font-weight: 800;

            transition:
                background 0.2s ease,
                transform 0.2s ease;
        }


        .menu-button {

            background: #ff6b35;

            color: #ffffff;
        }


        .menu-button:hover {

            background: #ff5722;

            transform: translateY(-1px);
        }


        .remove-button {

            background: #1d2229;

            color: #ff8b78;

            border:
                1px solid rgba(255, 107, 53, 0.20);
        }


        .remove-button:hover {

            background: #292f37;

            transform: translateY(-1px);
        }


        /*
         * ========================================================
         * MOBILE
         * ========================================================
         */

        @media (max-width: 700px) {

            .navbar {

                padding: 14px 4%;
            }


            .nav-links {

                gap: 12px;
            }


            .nav-links a {

                font-size: 12px;
            }


            .logo {

                font-size: 22px;
            }


            .page-container {

                width: 94%;

                padding-top: 30px;
            }


            .page-header h1 {

                font-size: 28px;
            }


            .favorites-grid {

                grid-template-columns: 1fr;
            }


            .card-actions {

                flex-direction: column;
            }


            .menu-button,
            .remove-button {

                width: 100%;
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
            class="logo">

            Foodwala

        </a>


        <div class="nav-links">

            <a
                href="<%= request.getContextPath() %>/restaurent">

                Restaurants

            </a>


            <a
                href="<%= request.getContextPath() %>/favorites">

                Favorites

            </a>


            <a
                href="<%= request.getContextPath() %>/cart"
                class="cart-link">

                Cart

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

    <main class="page-container">


        <div class="page-header">

            <h1>
                My Favorites
            </h1>

            <p>
                Your saved restaurants are all in one place.
            </p>

        </div>


        <!-- =====================================================
             SUCCESS MESSAGE
             ===================================================== -->

        <% if (favoriteMessage != null
                && !favoriteMessage.trim().isEmpty()) { %>

            <div class="alert success">

                <%= favoriteMessage %>

            </div>

        <% } %>


        <!-- =====================================================
             ERROR MESSAGE
             ===================================================== -->

        <% if (favoriteError != null
                && !favoriteError.trim().isEmpty()) { %>

            <div class="alert error">

                <%= favoriteError %>

            </div>

        <% } %>


        <!-- =====================================================
             EMPTY STATE
             ===================================================== -->

        <% if (favorites == null
                || favorites.isEmpty()) { %>


            <div class="empty-state">

                <div class="empty-icon">
                    &#9825;
                </div>


                <h2>
                    No favorites yet
                </h2>


                <p>
                    Tap the heart on any restaurant to save it
                    here for quick access later.
                </p>


                <a
                    href="<%= request.getContextPath() %>/restaurent"
                    class="browse-button">

                    Browse Restaurants

                </a>

            </div>


        <% } else { %>


            <!-- =================================================
                 FAVORITES GRID
                 ================================================= -->

            <div class="favorites-grid">


                <% for (Favorite favorite : favorites) {

                    String imagePath =
                            favorite.getImagePath();

                    if (imagePath == null
                            || imagePath.trim().isEmpty()) {

                        imagePath =
                                "https://images.unsplash.com/"
                                + "photo-1517248135467-4c7edcad34c4"
                                + "?auto=format&fit=crop&w=900&q=80";
                    }

                    double discount =
                            favorite.getDiscountPercent();
                %>


                <!-- =================================================
                     FAVORITE CARD
                     ================================================= -->

                <article class="favorite-card">


                    <div class="image-wrapper">


                        <img
                            src="<%= imagePath %>"
                            alt="<%= favorite.getRestaurentName() %>"
                            class="restaurant-image"
                            loading="lazy"
                            onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80';">


                        <div class="image-overlay"></div>


                        <div class="saved-badge">

                            &#9829; Saved

                        </div>


                        <% if (discount > 0) { %>

                            <div class="discount-badge">

                                <%= String.format(
                                        "%.0f",
                                        discount
                                   ) %>% OFF

                            </div>

                        <% } %>


                    </div>


                    <!-- =================================================
                         CARD CONTENT
                         ================================================= -->

                    <div class="card-content">


                        <h2>

                            <%= favorite.getRestaurentName() %>

                        </h2>


                        <div class="cuisine">

                            <%= favorite.getCuisineType() %>

                        </div>


                        <div class="restaurant-meta">


                            <span class="rating">

                                &#9733;

                                <%= String.format(
                                        "%.1f",
                                        favorite.getRating()
                                   ) %>

                            </span>


                            <span class="delivery">

                                <%= favorite.getDeliveryTime() %>

                            </span>


                        </div>


                        <div class="address">

                            <%= favorite.getAddress() %>

                        </div>


                        <!-- =================================================
                             ACTIONS
                             ================================================= -->

                        <div class="card-actions">


                            <a
                                href="<%= request.getContextPath() %>/menu?restaurentId=<%= favorite.getRestaurentId() %>"
                                class="menu-button">

                                View Menu

                            </a>


                            <a
                                href="<%= request.getContextPath() %>/favorites?action=remove&restaurentId=<%= favorite.getRestaurentId() %>"
                                class="remove-button">

                                Remove

                            </a>


                        </div>


                    </div>


                </article>


                <% } %>


            </div>


        <% } %>


    </main>


</body>

</html>