<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String contextPath = request.getContextPath();

    jakarta.servlet.http.HttpSession currentSession = request.getSession(false);

    boolean loggedIn = false;
    String username = null;
    int cartCount = 0;

    if (currentSession != null) {

        Object userIdObject = currentSession.getAttribute("userId");

        if (userIdObject != null) {
            loggedIn = true;
        }

        Object usernameObject = currentSession.getAttribute("username");

        if (usernameObject != null) {
            username = usernameObject.toString();
        }

        Object cartObject = currentSession.getAttribute("cart");

        if (cartObject instanceof java.util.List<?>) {
            cartCount = ((java.util.List<?>) cartObject).size();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <meta name="description"
          content="Foodwala - Discover restaurants, explore menus and order your favourite food online.">

    <title>Foodwala | Order Food Online</title>

    <link rel="preconnect"
          href="https://fonts.googleapis.com">

    <link rel="preconnect"
          href="https://fonts.gstatic.com"
          crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Poppins:wght@500;600;700;800&display=swap"
          rel="stylesheet">

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
            font-family: "Inter", sans-serif;
            background: #0B0B0D;
            color: #F8F8F8;
            min-height: 100vh;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        button,
        input {
            font-family: inherit;
        }

        /* =========================================
           NAVBAR
           ========================================= */

        .navbar {
            width: 100%;
            height: 76px;
            background: rgba(11, 11, 13, 0.96);
            border-bottom: 1px solid #29292E;
            display: flex;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 1000;
            backdrop-filter: blur(14px);
        }

        .nav-container {
            width: min(1200px, 92%);
            margin: auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 30px;
        }

        .logo {
            font-family: "Poppins", sans-serif;
            font-size: 27px;
            font-weight: 800;
            letter-spacing: -1px;
            white-space: nowrap;
        }

        .logo span {
            color: #FF6B35;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 28px;
        }

        .nav-links a {
            color: #D4D4D8;
            font-size: 14px;
            font-weight: 600;
            transition: 0.25s ease;
        }

        .nav-links a:hover {
            color: #FF6B35;
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .nav-button {
            min-height: 40px;
            padding: 0 16px;
            border-radius: 9px;
            border: 1px solid #303036;
            background: #151518;
            color: #F8F8F8;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: 0.25s ease;
        }

        .nav-button:hover {
            border-color: #FF6B35;
            color: #FF6B35;
        }

        .nav-button.primary {
            background: #FF6B35;
            border-color: #FF6B35;
            color: #FFFFFF;
        }

        .nav-button.primary:hover {
            background: #ff7b4b;
            color: #FFFFFF;
        }

        .cart-button {
            position: relative;
        }

        .cart-count {
            position: absolute;
            top: -7px;
            right: -7px;
            min-width: 20px;
            height: 20px;
            padding: 0 5px;
            border-radius: 20px;
            background: #FF6B35;
            color: #FFFFFF;
            font-size: 10px;
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* =========================================
           HERO
           ========================================= */

        .hero {
            min-height: 610px;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background:
                radial-gradient(
                    circle at 75% 45%,
                    rgba(255, 107, 53, 0.16),
                    transparent 34%
                ),
                radial-gradient(
                    circle at 15% 20%,
                    rgba(255, 180, 92, 0.06),
                    transparent 30%
                ),
                #0B0B0D;
        }

        .hero::before {
            content: "";
            position: absolute;
            width: 430px;
            height: 430px;
            border-radius: 50%;
            right: -150px;
            top: 100px;
            border: 1px solid rgba(255, 107, 53, 0.12);
        }

        .hero::after {
            content: "";
            position: absolute;
            width: 280px;
            height: 280px;
            border-radius: 50%;
            right: 70px;
            top: 170px;
            border: 1px solid rgba(255, 180, 92, 0.08);
        }

        .hero-container {
            width: min(1200px, 92%);
            margin: auto;
            position: relative;
            z-index: 2;
        }

        .hero-content {
            max-width: 760px;
        }

        .hero-label {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 13px;
            border: 1px solid rgba(255, 107, 53, 0.3);
            background: rgba(255, 107, 53, 0.07);
            border-radius: 30px;
            color: #FFB45C;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.3px;
            margin-bottom: 22px;
        }

        .hero-label-line {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #FF6B35;
        }

        .hero h1 {
            font-family: "Poppins", sans-serif;
            font-size: clamp(42px, 6vw, 72px);
            line-height: 1.04;
            letter-spacing: -2.5px;
            font-weight: 800;
            margin-bottom: 22px;
        }

        .hero h1 span {
            color: #FF6B35;
        }

        .hero-description {
            max-width: 650px;
            color: #A1A1AA;
            font-size: 17px;
            line-height: 1.75;
            margin-bottom: 32px;
        }

        /* =========================================
           SEARCH
           ========================================= */

        .search-box {
            width: min(680px, 100%);
            min-height: 62px;
            background: #18181B;
            border: 1px solid #34343A;
            border-radius: 12px;
            display: flex;
            align-items: center;
            padding: 6px;
            box-shadow: 0 18px 50px rgba(0, 0, 0, 0.28);
        }

        .search-icon {
            width: 46px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #A1A1AA;
            font-size: 20px;
            flex-shrink: 0;
        }

        .search-box input {
            flex: 1;
            min-width: 0;
            height: 50px;
            background: transparent;
            border: none;
            outline: none;
            color: #FFFFFF;
            font-size: 14px;
        }

        .search-box input::placeholder {
            color: #71717A;
        }

        .search-box button {
            height: 50px;
            padding: 0 24px;
            border: none;
            border-radius: 8px;
            background: #FF6B35;
            color: #FFFFFF;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: 0.25s ease;
        }

        .search-box button:hover {
            background: #ff7b4b;
        }

        .hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 18px;
        }

        .hero-button {
            min-height: 46px;
            padding: 0 21px;
            border-radius: 9px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 700;
            transition: 0.25s ease;
        }

        .hero-button.primary {
            background: #FF6B35;
            color: #FFFFFF;
        }

        .hero-button.primary:hover {
            background: #ff7b4b;
        }

        .hero-button.secondary {
            background: #18181B;
            border: 1px solid #303036;
            color: #E4E4E7;
        }

        .hero-button.secondary:hover {
            border-color: #FF6B35;
            color: #FF6B35;
        }

        /* =========================================
           TRUST BAR
           ========================================= */

        .trust-bar {
            border-top: 1px solid #252529;
            border-bottom: 1px solid #252529;
            background: #101012;
        }

        .trust-container {
            width: min(1200px, 92%);
            margin: auto;
            min-height: 90px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            align-items: center;
            gap: 20px;
        }

        .trust-item {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            color: #A1A1AA;
            font-size: 13px;
            font-weight: 600;
            text-align: center;
        }

        .trust-number {
            font-family: "Poppins", sans-serif;
            color: #FFB45C;
            font-size: 20px;
            font-weight: 800;
        }

        /* =========================================
           SECTION
           ========================================= */

        .section {
            width: min(1200px, 92%);
            margin: auto;
            padding: 85px 0;
        }

        .section-heading {
            margin-bottom: 34px;
        }

        .section-kicker {
            color: #FF6B35;
            text-transform: uppercase;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.7px;
            margin-bottom: 10px;
        }

        .section-heading h2 {
            font-family: "Poppins", sans-serif;
            font-size: 32px;
            letter-spacing: -1px;
            margin-bottom: 10px;
        }

        .section-heading p {
            color: #8F8F98;
            font-size: 14px;
            line-height: 1.7;
            max-width: 620px;
        }

        /* =========================================
           CATEGORY CARDS
           ========================================= */

        .category-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 14px;
        }

        .category-card {
            min-height: 130px;
            padding: 20px 15px;
            border-radius: 12px;
            background: #151518;
            border: 1px solid #29292E;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            transition: 0.25s ease;
        }

        .category-card:hover {
            transform: translateY(-5px);
            border-color: rgba(255, 107, 53, 0.55);
            background: #1A1A1E;
        }

        .category-symbol {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: rgba(255, 107, 53, 0.09);
            border: 1px solid rgba(255, 107, 53, 0.18);
            color: #FFB45C;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: "Poppins", sans-serif;
            font-size: 13px;
            font-weight: 800;
            margin-bottom: 13px;
        }

        .category-card h3 {
            font-size: 13px;
            font-weight: 700;
            color: #E4E4E7;
        }

        /* =========================================
           FEATURE CARDS
           ========================================= */

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
        }

        .feature-card {
            padding: 28px;
            border-radius: 14px;
            background: #151518;
            border: 1px solid #29292E;
            transition: 0.25s ease;
        }

        .feature-card:hover {
            transform: translateY(-4px);
            border-color: #3A3A41;
        }

        .feature-number {
            color: #FF6B35;
            font-family: "Poppins", sans-serif;
            font-size: 12px;
            font-weight: 800;
            margin-bottom: 20px;
        }

        .feature-card h3 {
            font-family: "Poppins", sans-serif;
            font-size: 18px;
            margin-bottom: 11px;
        }

        .feature-card p {
            color: #92929B;
            font-size: 13px;
            line-height: 1.75;
        }

        /* =========================================
           CTA
           ========================================= */

        .cta-section {
            width: min(1200px, 92%);
            margin: 0 auto 85px;
        }

        .cta-card {
            min-height: 260px;
            padding: 50px;
            border-radius: 18px;
            border: 1px solid rgba(255, 107, 53, 0.25);
            background:
                linear-gradient(
                    120deg,
                    rgba(255, 107, 53, 0.12),
                    rgba(255, 107, 53, 0.025)
                ),
                #141416;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 40px;
            overflow: hidden;
        }

        .cta-content {
            max-width: 650px;
        }

        .cta-content h2 {
            font-family: "Poppins", sans-serif;
            font-size: 31px;
            line-height: 1.2;
            margin-bottom: 13px;
        }

        .cta-content p {
            color: #A1A1AA;
            font-size: 14px;
            line-height: 1.7;
        }

        .cta-button {
            min-width: 150px;
            height: 48px;
            padding: 0 22px;
            border-radius: 9px;
            background: #FF6B35;
            color: #FFFFFF;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 700;
            flex-shrink: 0;
            transition: 0.25s ease;
        }

        .cta-button:hover {
            background: #ff7b4b;
        }

        /* =========================================
           FOOTER
           ========================================= */

        .footer {
            border-top: 1px solid #29292E;
            background: #080809;
        }

        .footer-container {
            width: min(1200px, 92%);
            margin: auto;
            padding: 55px 0 25px;
        }

        .footer-top {
            display: grid;
            grid-template-columns: 1.5fr 1fr 1fr 1fr;
            gap: 40px;
            padding-bottom: 45px;
        }

        .footer-brand p {
            max-width: 340px;
            color: #71717A;
            font-size: 13px;
            line-height: 1.75;
            margin-top: 15px;
        }

        .footer-column h4 {
            font-size: 13px;
            color: #E4E4E7;
            margin-bottom: 16px;
        }

        .footer-column a {
            display: block;
            color: #71717A;
            font-size: 12px;
            margin-bottom: 11px;
            transition: 0.2s ease;
        }

        .footer-column a:hover {
            color: #FF6B35;
        }

        .footer-bottom {
            border-top: 1px solid #222226;
            padding-top: 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            color: #5F5F66;
            font-size: 11px;
        }

        /* =========================================
           RESPONSIVE
           ========================================= */

        @media (max-width: 1000px) {

            .nav-links {
                display: none;
            }

            .category-grid {
                grid-template-columns: repeat(3, 1fr);
            }

            .feature-grid {
                grid-template-columns: 1fr;
            }

            .footer-top {
                grid-template-columns: repeat(2, 1fr);
            }

        }

        @media (max-width: 700px) {

            .navbar {
                height: 68px;
            }

            .nav-container {
                width: 94%;
            }

            .logo {
                font-size: 23px;
            }

            .nav-button {
                padding: 0 11px;
                font-size: 11px;
            }

            .hero {
                min-height: 580px;
            }

            .hero-container {
                width: 94%;
            }

            .hero h1 {
                font-size: 43px;
                letter-spacing: -1.5px;
            }

            .hero-description {
                font-size: 14px;
            }

            .search-box {
                min-height: 56px;
            }

            .search-box button {
                padding: 0 15px;
            }

            .hero-actions {
                flex-wrap: wrap;
            }

            .trust-container {
                grid-template-columns: 1fr;
                padding: 22px 0;
                gap: 18px;
            }

            .section {
                width: 94%;
                padding: 60px 0;
            }

            .section-heading h2 {
                font-size: 26px;
            }

            .category-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .cta-section {
                width: 94%;
            }

            .cta-card {
                padding: 32px 25px;
                flex-direction: column;
                align-items: flex-start;
            }

            .footer-container {
                width: 94%;
            }

            .footer-top {
                grid-template-columns: 1fr;
                gap: 30px;
            }

            .footer-bottom {
                flex-direction: column;
                align-items: flex-start;
            }

        }

        @media (max-width: 420px) {

            .nav-actions .nav-button:first-child {
                display: none;
            }

            .hero h1 {
                font-size: 37px;
            }

            .search-box {
                flex-wrap: wrap;
                padding: 6px;
            }

            .search-icon {
                width: 40px;
            }

            .search-box input {
                width: calc(100% - 40px);
            }

            .search-box button {
                width: 100%;
                margin-top: 5px;
            }

        }

    </style>

</head>

<body>

    <!-- =========================================
         NAVIGATION
         ========================================= -->

    <header class="navbar">

        <div class="nav-container">

            <a href="<%= contextPath %>/Home.jsp"
               class="logo">
                Food<span>wala</span>
            </a>

            <nav class="nav-links">

                <a href="<%= contextPath %>/restaurent">
                    Restaurants
                </a>

                <a href="#categories">
                    Categories
                </a>

                <a href="#how-it-works">
                    How It Works
                </a>

            </nav>

            <div class="nav-actions">

                <a href="<%= contextPath %>/cart.jsp"
                   class="nav-button cart-button">

                    Cart

                    <% if (cartCount > 0) { %>
                        <span class="cart-count">
                            <%= cartCount %>
                        </span>
                    <% } %>

                </a>

                <% if (loggedIn) { %>

                    <a href="<%= contextPath %>/Favorites.jsp"
                       class="nav-button">
                        Favorites
                    </a>

                    <a href="<%= contextPath %>/Profile.jsp"
                       class="nav-button primary">
                        <%= username != null ? username : "Account" %>
                    </a>

                <% } else { %>

                    <a href="<%= contextPath %>/Login.jsp"
                       class="nav-button">
                        Login
                    </a>

                    <a href="<%= contextPath %>/Register.jsp"
                       class="nav-button primary">
                        Register
                    </a>

                <% } %>

            </div>

        </div>

    </header>


    <!-- =========================================
         HERO
         ========================================= -->

    <main>

        <section class="hero">

            <div class="hero-container">

                <div class="hero-content">

                    <div class="hero-label">
                        <span class="hero-label-line"></span>
                        Food discovery made simple
                    </div>

                    <h1>
                        Discover great food.
                        <br>
                        <span>Order what you love.</span>
                    </h1>

                    <p class="hero-description">
                        Explore restaurants, discover delicious dishes,
                        compare menus and order your favourite food from
                        the comfort of your home.
                    </p>


                    <!-- SEARCH -->

                    <form class="search-box"
                          method="get"
                          action="<%= contextPath %>/restaurent">

                        <div class="search-icon">
                            &#9906;
                        </div>

                        <input
                            type="text"
                            name="search"
                            placeholder="Search for restaurants, cuisines or food..."
                            autocomplete="off">

                        <button type="submit">
                            Search
                        </button>

                    </form>


                    <div class="hero-actions">

                        <a href="<%= contextPath %>/restaurent"
                           class="hero-button primary">
                            Explore Restaurants
                        </a>

                        <a href="#categories"
                           class="hero-button secondary">
                            Browse Categories
                        </a>

                    </div>

                </div>

            </div>

        </section>


        <!-- =========================================
             TRUST BAR
             ========================================= -->

        <section class="trust-bar">

            <div class="trust-container">

                <div class="trust-item">

                    <span class="trust-number">
                        40+
                    </span>

                    Restaurants to explore

                </div>

                <div class="trust-item">

                    <span class="trust-number">
                        1000+
                    </span>

                    Food items available

                </div>

                <div class="trust-item">

                    <span class="trust-number">
                        24/7
                    </span>

                    Easy online ordering

                </div>

            </div>

        </section>


        <!-- =========================================
             CATEGORIES
             ========================================= -->

        <section class="section"
                 id="categories">

            <div class="section-heading">

                <div class="section-kicker">
                    Explore
                </div>

                <h2>
                    What are you craving?
                </h2>

                <p>
                    Start with a cuisine or food category and discover
                    restaurants serving your favourite dishes.
                </p>

            </div>


            <div class="category-grid">

                <a href="<%= contextPath %>/restaurent?search=Biryani"
                   class="category-card">

                    <div class="category-symbol">
                        B
                    </div>

                    <h3>
                        Biryani
                    </h3>

                </a>


                <a href="<%= contextPath %>/restaurent?search=South Indian"
                   class="category-card">

                    <div class="category-symbol">
                        SI
                    </div>

                    <h3>
                        South Indian
                    </h3>

                </a>


                <a href="<%= contextPath %>/restaurent?search=North Indian"
                   class="category-card">

                    <div class="category-symbol">
                        NI
                    </div>

                    <h3>
                        North Indian
                    </h3>

                </a>


                <a href="<%= contextPath %>/restaurent?search=Chinese"
                   class="category-card">

                    <div class="category-symbol">
                        C
                    </div>

                    <h3>
                        Chinese
                    </h3>

                </a>


                <a href="<%= contextPath %>/restaurent?search=Andhra"
                   class="category-card">

                    <div class="category-symbol">
                        A
                    </div>

                    <h3>
                        Andhra
                    </h3>

                </a>


                <a href="<%= contextPath %>/restaurent?search=Fast Food"
                   class="category-card">

                    <div class="category-symbol">
                        FF
                    </div>

                    <h3>
                        Fast Food
                    </h3>

                </a>

            </div>

        </section>


        <!-- =========================================
             HOW IT WORKS
             ========================================= -->

        <section class="section"
                 id="how-it-works">

            <div class="section-heading">

                <div class="section-kicker">
                    Simple ordering
                </div>

                <h2>
                    Everything starts with discovery
                </h2>

                <p>
                    Browse freely as a guest. You only need to sign in
                    when you are ready to complete your order.
                </p>

            </div>


            <div class="feature-grid">

                <div class="feature-card">

                    <div class="feature-number">
                        01 / DISCOVER
                    </div>

                    <h3>
                        Find restaurants
                    </h3>

                    <p>
                        Search restaurants, cuisines and food categories
                        without creating an account. Explore menus freely
                        before deciding what you want.
                    </p>

                </div>


                <div class="feature-card">

                    <div class="feature-number">
                        02 / CHOOSE
                    </div>

                    <h3>
                        Build your order
                    </h3>

                    <p>
                        Open a restaurant, explore its menu and add dishes
                        to your cart. Review quantities and prices before
                        proceeding.
                    </p>

                </div>


                <div class="feature-card">

                    <div class="feature-number">
                        03 / ORDER
                    </div>

                    <h3>
                        Checkout when ready
                    </h3>

                    <p>
                        Continue as a guest until checkout. If you are not
                        logged in, Foodwala will ask you to sign in before
                        placing the order.
                    </p>

                </div>

            </div>

        </section>


        <!-- =========================================
             CTA
             ========================================= -->

        <section class="cta-section">

            <div class="cta-card">

                <div class="cta-content">

                    <h2>
                        Hungry already?
                        Start exploring.
                    </h2>

                    <p>
                        Browse restaurants and menus without signing in.
                        Login is required only when you are ready to
                        complete your order.
                    </p>

                </div>

                <a href="<%= contextPath %>/restaurent"
                   class="cta-button">
                    Explore Food
                </a>

            </div>

        </section>

    </main>


    <!-- =========================================
         FOOTER
         ========================================= -->

    <footer class="footer">

        <div class="footer-container">

            <div class="footer-top">

                <div class="footer-brand">

                    <a href="<%= contextPath %>/Home.jsp"
                       class="logo">
                        Food<span>wala</span>
                    </a>

                    <p>
                        A modern food discovery and ordering platform
                        designed to help you find restaurants, explore
                        menus and order your favourite meals easily.
                    </p>

                </div>


                <div class="footer-column">

                    <h4>
                        Discover
                    </h4>

                    <a href="<%= contextPath %>/restaurent">
                        Restaurants
                    </a>

                    <a href="#categories">
                        Categories
                    </a>

                    <a href="<%= contextPath %>/restaurent?search=Biryani">
                        Biryani
                    </a>

                    <a href="<%= contextPath %>/restaurent?search=South Indian">
                        South Indian
                    </a>

                </div>


                <div class="footer-column">

                    <h4>
                        Account
                    </h4>

                    <% if (loggedIn) { %>

                        <a href="<%= contextPath %>/Favorites.jsp">
                            Favorites
                        </a>

                        <a href="<%= contextPath %>/cart.jsp">
                            Cart
                        </a>

                        <a href="<%= contextPath %>/Profile.jsp">
                            Profile
                        </a>

                    <% } else { %>

                        <a href="<%= contextPath %>/Login.jsp">
                            Login
                        </a>

                        <a href="<%= contextPath %>/Register.jsp">
                            Register
                        </a>

                        <a href="<%= contextPath %>/cart.jsp">
                            Cart
                        </a>

                    <% } %>

                </div>


                <div class="footer-column">

                    <h4>
                        Foodwala
                    </h4>

                    <a href="<%= contextPath %>/restaurent">
                        Browse Food
                    </a>

                    <a href="#how-it-works">
                        How It Works
                    </a>

                    <a href="<%= contextPath %>/Home.jsp">
                        Home
                    </a>

                </div>

            </div>


            <div class="footer-bottom">

                <span>
                    &copy; <%= java.time.Year.now().getValue() %>
                    Foodwala. All rights reserved.
                </span>

                <span>
                    Food discovery. Simple ordering.
                </span>

            </div>

        </div>

    </footer>

</body>

</html>