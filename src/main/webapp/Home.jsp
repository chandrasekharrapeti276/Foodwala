<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String contextPath = request.getContextPath();

    jakarta.servlet.http.HttpSession currentSession =
            request.getSession(false);

    boolean loggedIn = false;
    String username = "Food Lover";
    int cartCount = 0;

    if (currentSession != null) {

        Object userIdObject =
                currentSession.getAttribute("userId");

        if (userIdObject != null) {
            loggedIn = true;
        }

        Object usernameObject =
                currentSession.getAttribute("username");

        if (usernameObject != null) {

            String sessionUsername =
                    String.valueOf(usernameObject).trim();

            if (!sessionUsername.isEmpty()) {
                username = sessionUsername;
            }
        }

        Object cartObject =
                currentSession.getAttribute("cart");

        if (cartObject instanceof java.util.List<?>) {

            java.util.List<?> cart =
                    (java.util.List<?>) cartObject;

            for (Object item : cart) {

                try {

                    java.lang.reflect.Method method =
                            item.getClass()
                                .getMethod("getQuantity");

                    Object quantity =
                            method.invoke(item);

                    if (quantity instanceof Number) {

                        cartCount +=
                                ((Number) quantity).intValue();
                    }

                } catch (Exception ignored) {
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

    <meta name="description"
          content="Foodwala - Discover restaurants, explore menus and order delicious food online.">

    <title>Foodwala | Delicious food, delivered</title>

    <link rel="preconnect"
          href="https://fonts.googleapis.com">

    <link rel="preconnect"
          href="https://fonts.gstatic.com"
          crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@500;600;700;800&display=swap"
          rel="stylesheet">

    <style>

        :root {
            --bg: #09090B;
            --surface: #111113;
            --surface-2: #18181B;
            --surface-3: #202023;

            --orange: #FF6B35;
            --orange-dark: #E95725;
            --gold: #FFB45C;

            --white: #FAFAFA;
            --text: #F4F4F5;
            --muted: #A1A1AA;
            --muted-2: #71717A;

            --border: #27272A;

            --success: #35C98A;

            --max-width: 1240px;

            --radius-sm: 10px;
            --radius-md: 18px;
            --radius-lg: 26px;
            --radius-xl: 34px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            background:
                radial-gradient(
                    circle at 80% 0%,
                    rgba(255, 107, 53, 0.08),
                    transparent 30%
                ),
                var(--bg);

            color: var(--text);

            font-family:
                "DM Sans",
                Arial,
                sans-serif;

            min-height: 100vh;
            line-height: 1.5;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button,
        input {
            font: inherit;
        }

        .page {
            width: 100%;
            overflow: hidden;
        }

        .container {
            width: min(
                calc(100% - 48px),
                var(--max-width)
            );

            margin: 0 auto;
        }

        /* =========================
           NAVIGATION
           ========================= */

        .navbar {
            position: sticky;
            top: 0;
            z-index: 1000;

            height: 76px;

            background:
                rgba(9, 9, 11, 0.88);

            backdrop-filter:
                blur(20px);

            border-bottom:
                1px solid rgba(255,255,255,0.06);
        }

        .nav-inner {
            height: 100%;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 24px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 11px;

            flex-shrink: 0;
        }

        .brand-mark {
            width: 40px;
            height: 40px;

            display: grid;
            place-items: center;

            border-radius: 13px;

            background:
                linear-gradient(
                    135deg,
                    var(--orange),
                    #FF8A55
                );

            color: #fff;

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-weight: 800;

            box-shadow:
                0 10px 30px
                rgba(255,107,53,0.20);
        }

        .brand-name {
            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size: 20px;
            font-weight: 800;

            letter-spacing: -0.5px;
        }

        .brand-name span {
            color: var(--orange);
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 30px;

            color: var(--muted);

            font-size: 14px;
            font-weight: 600;
        }

        .nav-links a {
            transition:
                color 0.2s ease;
        }

        .nav-links a:hover {
            color: var(--white);
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .nav-link-button {
            min-height: 42px;

            padding: 0 15px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            border: 1px solid transparent;
            border-radius: 12px;

            color: var(--muted);

            font-size: 14px;
            font-weight: 700;

            transition:
                background 0.2s ease,
                color 0.2s ease,
                border-color 0.2s ease;
        }

        .nav-link-button:hover {
            color: var(--white);
            background: var(--surface-2);
            border-color: var(--border);
        }

        .login-button {
            color: var(--white);
            border-color: var(--border);
            background: var(--surface-2);
        }

        .login-button:hover {
            border-color: #3F3F46;
        }

        .cart-button {
            position: relative;

            min-height: 44px;
            min-width: 48px;

            padding: 0 13px;

            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;

            border-radius: 13px;

            background: var(--orange);
            color: #fff;

            font-weight: 800;

            box-shadow:
                0 8px 25px
                rgba(255,107,53,0.18);

            transition:
                transform 0.2s ease,
                background 0.2s ease;
        }

        .cart-button:hover {
            transform: translateY(-2px);
            background: var(--orange-dark);
        }

        .cart-count {
            min-width: 21px;
            height: 21px;

            padding: 0 5px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            border-radius: 99px;

            background: #fff;
            color: var(--orange);

            font-size: 11px;
            font-weight: 800;
        }

        /* =========================
           HERO
           ========================= */

        .hero {
            position: relative;

            min-height: 650px;

            display: flex;
            align-items: center;

            padding:
                90px 0
                100px;
        }

        .hero::before {
            content: "";

            position: absolute;

            width: 600px;
            height: 600px;

            right: -250px;
            top: -150px;

            border-radius: 50%;

            background:
                radial-gradient(
                    circle,
                    rgba(255,107,53,0.15),
                    transparent 68%
                );

            pointer-events: none;
        }

        .hero-grid {
            position: relative;
            z-index: 1;

            display: grid;

            grid-template-columns:
                minmax(0, 1.05fr)
                minmax(420px, 0.95fr);

            align-items: center;

            gap: 70px;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 9px;

            padding: 8px 12px;

            border:
                1px solid
                rgba(255,107,53,0.25);

            border-radius: 99px;

            background:
                rgba(255,107,53,0.08);

            color: var(--gold);

            font-size: 12px;
            font-weight: 800;

            letter-spacing: 0.5px;

            text-transform: uppercase;
        }

        .eyebrow-dot {
            width: 7px;
            height: 7px;

            border-radius: 50%;

            background: var(--orange);

            box-shadow:
                0 0 0 5px
                rgba(255,107,53,0.10);
        }

        .hero-title {
            margin-top: 24px;

            max-width: 720px;

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size:
                clamp(48px, 6vw, 78px);

            line-height: 0.98;

            letter-spacing: -3.5px;

            font-weight: 800;
        }

        .hero-title .accent {
            color: var(--orange);
        }

        .hero-description {
            max-width: 580px;

            margin-top: 25px;

            color: var(--muted);

            font-size: 17px;
            line-height: 1.75;
        }

        /* =========================
           SEARCH
           ========================= */

        .search-box {
            max-width: 610px;

            margin-top: 32px;

            padding: 7px;

            display: flex;
            align-items: center;

            background: #141416;

            border:
                1px solid
                var(--border);

            border-radius: 17px;

            box-shadow:
                0 25px 60px
                rgba(0,0,0,0.28);
        }

        .search-icon {
            width: 46px;

            display: grid;
            place-items: center;

            color: var(--muted-2);

            font-size: 19px;
        }

        .search-input {
            flex: 1;

            min-width: 0;

            height: 50px;

            border: 0;
            outline: 0;

            background: transparent;

            color: var(--white);

            font-size: 15px;
        }

        .search-input::placeholder {
            color: #71717A;
        }

        .search-submit {
            height: 50px;

            padding: 0 23px;

            border: 0;
            border-radius: 13px;

            background: var(--orange);
            color: #fff;

            font-weight: 800;

            cursor: pointer;

            transition:
                background 0.2s ease,
                transform 0.2s ease;
        }

        .search-submit:hover {
            background: var(--orange-dark);
            transform: translateY(-1px);
        }

        .hero-actions {
            margin-top: 24px;

            display: flex;
            align-items: center;
            gap: 12px;
        }

        .primary-button,
        .secondary-button {
            min-height: 50px;

            padding: 0 21px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            border-radius: 13px;

            font-size: 14px;
            font-weight: 800;

            transition:
                transform 0.2s ease,
                background 0.2s ease,
                border-color 0.2s ease;
        }

        .primary-button {
            background: var(--orange);
            color: #fff;
        }

        .primary-button:hover {
            background: var(--orange-dark);
            transform: translateY(-2px);
        }

        .secondary-button {
            background: var(--surface-2);
            border: 1px solid var(--border);
            color: var(--white);
        }

        .secondary-button:hover {
            border-color: #3F3F46;
            transform: translateY(-2px);
        }

        /* =========================
           HERO VISUAL
           ========================= */

        .hero-visual {
            position: relative;

            min-height: 510px;

            display: flex;
            align-items: center;
            justify-content: center;
        }

        .visual-glow {
            position: absolute;

            width: 390px;
            height: 390px;

            border-radius: 50%;

            background:
                radial-gradient(
                    circle,
                    rgba(255,107,53,0.20),
                    transparent 67%
                );
        }

        .food-card {
            position: relative;
            z-index: 2;

            width: min(100%, 470px);

            padding: 14px;

            background:
                linear-gradient(
                    145deg,
                    #202023,
                    #121214
                );

            border:
                1px solid
                rgba(255,255,255,0.08);

            border-radius: 30px;

            box-shadow:
                0 40px 100px
                rgba(0,0,0,0.55);

            transform:
                rotate(2deg);
        }

        .food-image {
            position: relative;

            height: 350px;

            overflow: hidden;

            border-radius: 21px;

            background:
                linear-gradient(
                    135deg,
                    #252525,
                    #111
                );
        }

        .food-image img {
            width: 100%;
            height: 100%;

            display: block;

            object-fit: cover;

            transition:
                transform 0.5s ease;
        }

        .food-card:hover .food-image img {
            transform: scale(1.04);
        }

        .food-overlay {
            position: absolute;

            inset: auto 0 0 0;

            padding: 65px 22px 20px;

            background:
                linear-gradient(
                    transparent,
                    rgba(0,0,0,0.85)
                );
        }

        .food-tag {
            display: inline-block;

            padding: 6px 9px;

            border-radius: 8px;

            background: var(--orange);
            color: #fff;

            font-size: 11px;
            font-weight: 800;

            text-transform: uppercase;
        }

        .food-title {
            margin-top: 8px;

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size: 25px;
            font-weight: 800;
        }

        .food-meta {
            margin-top: 5px;

            color: #D4D4D8;

            font-size: 13px;
        }

        .floating-card {
            position: absolute;
            z-index: 3;

            padding: 15px 17px;

            background:
                rgba(24,24,27,0.94);

            backdrop-filter:
                blur(15px);

            border:
                1px solid
                rgba(255,255,255,0.10);

            border-radius: 16px;

            box-shadow:
                0 20px 50px
                rgba(0,0,0,0.4);
        }

        .floating-top {
            top: 52px;
            right: -10px;
        }

        .floating-bottom {
            left: -25px;
            bottom: 55px;
        }

        .float-label {
            color: var(--muted-2);

            font-size: 11px;
            font-weight: 700;
        }

        .float-value {
            margin-top: 3px;

            color: var(--white);

            font-size: 14px;
            font-weight: 800;
        }

        .rating {
            color: var(--gold);
        }

        /* =========================
           TRUST STRIP
           ========================= */

        .trust-strip {
            padding: 24px 0;

            border-top:
                1px solid
                rgba(255,255,255,0.06);

            border-bottom:
                1px solid
                rgba(255,255,255,0.06);

            background:
                rgba(255,255,255,0.015);
        }

        .trust-grid {
            display: grid;

            grid-template-columns:
                repeat(3, 1fr);

            gap: 20px;
        }

        .trust-item {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 13px;

            color: var(--muted);

            font-size: 13px;
            font-weight: 600;
        }

        .trust-number {
            color: var(--white);

            font-size: 18px;
            font-weight: 800;
        }

        /* =========================
           CATEGORIES
           ========================= */

        .section {
            padding: 105px 0;
        }

        .section-heading {
            display: flex;
            align-items: end;
            justify-content: space-between;

            gap: 30px;

            margin-bottom: 35px;
        }

        .section-kicker {
            color: var(--orange);

            font-size: 12px;
            font-weight: 800;

            text-transform: uppercase;

            letter-spacing: 1.3px;
        }

        .section-title {
            margin-top: 8px;

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size:
                clamp(30px, 4vw, 44px);

            line-height: 1.1;

            letter-spacing: -1.8px;

            font-weight: 800;
        }

        .section-description {
            max-width: 470px;

            color: var(--muted);

            font-size: 14px;
            line-height: 1.7;
        }

        .category-grid {
            display: grid;

            grid-template-columns:
                repeat(6, 1fr);

            gap: 14px;
        }

        .category-card {
            min-height: 150px;

            padding: 22px 16px;

            display: flex;
            flex-direction: column;
            justify-content: space-between;

            border:
                1px solid
                var(--border);

            border-radius: var(--radius-md);

            background:
                linear-gradient(
                    145deg,
                    var(--surface-2),
                    var(--surface)
                );

            transition:
                transform 0.25s ease,
                border-color 0.25s ease,
                background 0.25s ease;
        }

        .category-card:hover {
            transform: translateY(-5px);

            border-color:
                rgba(255,107,53,0.35);

            background:
                linear-gradient(
                    145deg,
                    #211815,
                    var(--surface)
                );
        }

        .category-icon {
            width: 50px;
            height: 50px;

            display: grid;
            place-items: center;

            border-radius: 15px;

            background:
                rgba(255,107,53,0.10);

            color: var(--orange);

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size: 13px;
            font-weight: 800;
        }

        .category-name {
            margin-top: 20px;

            color: var(--white);

            font-size: 14px;
            font-weight: 800;
        }

        .category-sub {
            margin-top: 3px;

            color: var(--muted-2);

            font-size: 11px;
        }

        /* =========================
           EXPERIENCE
           ========================= */

        .experience {
            padding-bottom: 110px;
        }

        .experience-grid {
            display: grid;

            grid-template-columns:
                repeat(3, 1fr);

            gap: 16px;
        }

        .experience-card {
            position: relative;

            min-height: 250px;

            padding: 28px;

            overflow: hidden;

            border:
                1px solid
                var(--border);

            border-radius: var(--radius-lg);

            background:
                linear-gradient(
                    145deg,
                    #171719,
                    #0F0F11
                );
        }

        .experience-card::after {
            content: "";

            position: absolute;

            width: 170px;
            height: 170px;

            right: -55px;
            bottom: -65px;

            border-radius: 50%;

            background:
                rgba(255,107,53,0.08);
        }

        .experience-index {
            color: var(--orange);

            font-size: 12px;
            font-weight: 800;
        }

        .experience-title {
            margin-top: 50px;

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size: 23px;
            font-weight: 800;

            letter-spacing: -0.8px;
        }

        .experience-text {
            max-width: 300px;

            margin-top: 10px;

            color: var(--muted);

            font-size: 13px;
            line-height: 1.7;
        }

        /* =========================
           CTA
           ========================= */

        .cta {
            padding: 0 0 100px;
        }

        .cta-card {
            position: relative;

            overflow: hidden;

            padding:
                55px
                60px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 40px;

            border:
                1px solid
                rgba(255,107,53,0.25);

            border-radius: var(--radius-xl);

            background:
                radial-gradient(
                    circle at 90% 50%,
                    rgba(255,107,53,0.24),
                    transparent 35%
                ),
                linear-gradient(
                    135deg,
                    #21130E,
                    #121214
                );
        }

        .cta-title {
            max-width: 650px;

            font-family:
                "Plus Jakarta Sans",
                sans-serif;

            font-size:
                clamp(28px, 4vw, 44px);

            line-height: 1.1;

            letter-spacing: -1.8px;

            font-weight: 800;
        }

        .cta-text {
            max-width: 600px;

            margin-top: 12px;

            color: var(--muted);

            font-size: 14px;
        }

        /* =========================
           FOOTER
           ========================= */

        footer {
            padding:
                55px 0
                30px;

            border-top:
                1px solid
                rgba(255,255,255,0.06);
        }

        .footer-grid {
            display: grid;

            grid-template-columns:
                1.5fr
                repeat(3, 1fr);

            gap: 50px;
        }

        .footer-brand-text {
            max-width: 300px;

            margin-top: 15px;

            color: var(--muted);

            font-size: 13px;
            line-height: 1.7;
        }

        .footer-heading {
            margin-bottom: 15px;

            color: var(--white);

            font-size: 13px;
            font-weight: 800;
        }

        .footer-links {
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .footer-links a {
            color: var(--muted-2);

            font-size: 13px;

            transition:
                color 0.2s ease;
        }

        .footer-links a:hover {
            color: var(--white);
        }

        .footer-bottom {
            margin-top: 45px;
            padding-top: 20px;

            border-top:
                1px solid
                rgba(255,255,255,0.06);

            display: flex;
            align-items: center;
            justify-content: space-between;

            color: var(--muted-2);

            font-size: 11px;
        }

        /* =========================
           RESPONSIVE
           ========================= */

        @media (max-width: 1050px) {

            .nav-links {
                display: none;
            }

            .hero-grid {
                grid-template-columns: 1fr;
                gap: 35px;
            }

            .hero-content {
                text-align: center;
            }

            .hero-description,
            .search-box {
                margin-left: auto;
                margin-right: auto;
            }

            .hero-actions {
                justify-content: center;
            }

            .hero-visual {
                min-height: 460px;
            }

            .category-grid {
                grid-template-columns:
                    repeat(3, 1fr);
            }
        }

        @media (max-width: 760px) {

            .container {
                width: min(
                    calc(100% - 28px),
                    var(--max-width)
                );
            }

            .navbar {
                height: 68px;
            }

            .brand-name {
                font-size: 18px;
            }

            .brand-mark {
                width: 36px;
                height: 36px;
            }

            .nav-actions .login-button {
                display: none;
            }

            .hero {
                padding:
                    65px 0
                    70px;
            }

            .hero-title {
                font-size: 48px;
                letter-spacing: -2.5px;
            }

            .hero-description {
                font-size: 15px;
            }

            .search-box {
                padding: 6px;
            }

            .search-submit {
                padding: 0 15px;
            }

            .hero-visual {
                min-height: 390px;
            }

            .food-card {
                width: 94%;
            }

            .food-image {
                height: 280px;
            }

            .floating-top {
                right: -4px;
                top: 20px;
            }

            .floating-bottom {
                left: -4px;
                bottom: 20px;
            }

            .trust-grid {
                grid-template-columns: 1fr;
                gap: 13px;
            }

            .section {
                padding: 75px 0;
            }

            .section-heading {
                flex-direction: column;
                align-items: flex-start;
            }

            .category-grid {
                grid-template-columns:
                    repeat(2, 1fr);
            }

            .experience-grid {
                grid-template-columns: 1fr;
            }

            .cta-card {
                padding: 35px 28px;

                flex-direction: column;
                align-items: flex-start;
            }

            .footer-grid {
                grid-template-columns:
                    repeat(2, 1fr);
            }

            .footer-brand {
                grid-column: 1 / -1;
            }

            .footer-bottom {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }
        }

        @media (max-width: 480px) {

            .hero-title {
                font-size: 41px;
            }

            .search-box {
                flex-wrap: wrap;
            }

            .search-icon {
                width: 38px;
            }

            .search-input {
                width: calc(100% - 38px);
            }

            .search-submit {
                width: 100%;
                margin-top: 5px;
            }

            .hero-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .primary-button,
            .secondary-button {
                width: 100%;
            }

            .category-grid {
                grid-template-columns:
                    repeat(2, 1fr);

                gap: 10px;
            }

            .category-card {
                min-height: 135px;
                padding: 17px 14px;
            }

            .category-icon {
                width: 43px;
                height: 43px;
            }

            .footer-grid {
                grid-template-columns: 1fr;
            }
        }

    </style>

</head>

<body>

<div class="page">

    <!-- =========================
         NAVIGATION
         ========================= -->

    <header class="navbar">

        <div class="container nav-inner">

            <a href="<%= contextPath %>/Home.jsp"
               class="brand">

                <div class="brand-mark">
                    F
                </div>

                <div class="brand-name">
                    Food<span>wala</span>
                </div>

            </a>

            <nav class="nav-links">

                <a href="<%= contextPath %>/Home.jsp">
                    Home
                </a>

                <a href="<%= contextPath %>/restaurent">
                    Restaurants
                </a>

                <a href="<%= contextPath %>/restaurent?search=Offers">
                    Offers
                </a>

            </nav>

            <div class="nav-actions">

                <% if (loggedIn) { %>

                    <a href="<%= contextPath %>/favorites"
                       class="nav-link-button">
                        Favorites
                    </a>

                    <a href="<%= contextPath %>/orderHistory"
                       class="nav-link-button">
                        Orders
                    </a>

                <% } else { %>

                    <a href="<%= contextPath %>/Login.jsp"
                       class="nav-link-button login-button">
                        Sign in
                    </a>

                <% } %>

                <a href="<%= contextPath %>/Cart.jsp"
                   class="cart-button"
                   aria-label="Shopping cart">

                    Cart

                    <% if (cartCount > 0) { %>
                        <span class="cart-count">
                            <%= cartCount %>
                        </span>
                    <% } %>

                </a>

            </div>

        </div>

    </header>


    <!-- =========================
         HERO
         ========================= -->

    <main>

        <section class="hero">

            <div class="container hero-grid">

                <div class="hero-content">

                    <div class="eyebrow">
                        <span class="eyebrow-dot"></span>
                        Bengaluru's food, your way
                    </div>

                    <h1 class="hero-title">
                        Great food.
                        <br>
                        <span class="accent">
                            Right to you.
                        </span>
                    </h1>

                    <p class="hero-description">
                        Discover local restaurants, explore dishes
                        you love and build your perfect order with
                        Foodwala.
                    </p>

                    <form class="search-box"
                          action="<%= contextPath %>/restaurent"
                          method="get">

                        <div class="search-icon">
                            &#9906;
                        </div>

                        <input
                            type="text"
                            name="search"
                            class="search-input"
                            placeholder="Search restaurants, cuisines or dishes..."
                            autocomplete="off">

                        <button
                            type="submit"
                            class="search-submit">
                            Search
                        </button>

                    </form>

                    <div class="hero-actions">

                        <a href="<%= contextPath %>/restaurent"
                           class="primary-button">
                            Explore restaurants
                        </a>

                        <a href="#categories"
                           class="secondary-button">
                            Browse cuisines
                        </a>

                    </div>

                </div>


                <div class="hero-visual">

                    <div class="visual-glow"></div>

                    <div class="food-card">

                        <div class="food-image">

                            <img
                                src="https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=1000&q=85"
                                alt="Fresh Indian food"
                                onerror="this.style.display='none';">

                            <div class="food-overlay">

                                <span class="food-tag">
                                    Popular today
                                </span>

                                <div class="food-title">
                                    Masala Dosa
                                </div>

                                <div class="food-meta">
                                    South Indian · Crispy · Fresh
                                </div>

                            </div>

                        </div>

                    </div>

                    <div class="floating-card floating-top">

                        <div class="float-label">
                            Customer rating
                        </div>

                        <div class="float-value rating">
                            4.8 / 5
                        </div>

                    </div>

                    <div class="floating-card floating-bottom">

                        <div class="float-label">
                            Foodwala promise
                        </div>

                        <div class="float-value">
                            Fresh. Fast. Reliable.
                        </div>

                    </div>

                </div>

            </div>

        </section>


        <!-- =========================
             TRUST
             ========================= -->

        <section class="trust-strip">

            <div class="container trust-grid">

                <div class="trust-item">
                    <span class="trust-number">40+</span>
                    restaurants to discover
                </div>

                <div class="trust-item">
                    <span class="trust-number">1000+</span>
                    dishes available
                </div>

                <div class="trust-item">
                    <span class="trust-number">1</span>
                    simple ordering experience
                </div>

            </div>

        </section>


        <!-- =========================
             CATEGORIES
             ========================= -->

        <section class="section"
                 id="categories">

            <div class="container">

                <div class="section-heading">

                    <div>

                        <div class="section-kicker">
                            Explore by craving
                        </div>

                        <h2 class="section-title">
                            What are you hungry for?
                        </h2>

                    </div>

                    <p class="section-description">
                        Jump directly into a cuisine and discover
                        restaurants serving the flavours you're
                        looking for.
                    </p>

                </div>


                <div class="category-grid">

                    <a class="category-card"
                       href="<%= contextPath %>/restaurent?search=Biryani">

                        <div class="category-icon">
                            BIR
                        </div>

                        <div>
                            <div class="category-name">
                                Biryani
                            </div>

                            <div class="category-sub">
                                Aromatic favourites
                            </div>
                        </div>

                    </a>


                    <a class="category-card"
                       href="<%= contextPath %>/restaurent?search=South%20Indian">

                        <div class="category-icon">
                            SOUTH
                        </div>

                        <div>
                            <div class="category-name">
                                South Indian
                            </div>

                            <div class="category-sub">
                                Dosa, idli & more
                            </div>
                        </div>

                    </a>


                    <a class="category-card"
                       href="<%= contextPath %>/restaurent?search=North%20Indian">

                        <div class="category-icon">
                            NORTH
                        </div>

                        <div>
                            <div class="category-name">
                                North Indian
                            </div>

                            <div class="category-sub">
                                Rich & comforting
                            </div>
                        </div>

                    </a>


                    <a class="category-card"
                       href="<%= contextPath %>/restaurent?search=Chinese">

                        <div class="category-icon">
                            CHN
                        </div>

                        <div>
                            <div class="category-name">
                                Chinese
                            </div>

                            <div class="category-sub">
                                Wok favourites
                            </div>
                        </div>

                    </a>


                    <a class="category-card"
                       href="<%= contextPath %>/restaurent?search=Andhra">

                        <div class="category-icon">
                            AND
                        </div>

                        <div>
                            <div class="category-name">
                                Andhra
                            </div>

                            <div class="category-sub">
                                Bold & spicy
                            </div>
                        </div>

                    </a>


                    <a class="category-card"
                       href="<%= contextPath %>/restaurent?search=Fast%20Food">

                        <div class="category-icon">
                            FAST
                        </div>

                        <div>
                            <div class="category-name">
                                Fast Food
                            </div>

                            <div class="category-sub">
                                Quick comfort
                            </div>
                        </div>

                    </a>

                </div>

            </div>

        </section>


        <!-- =========================
             HOW IT WORKS
             ========================= -->

        <section class="experience">

            <div class="container">

                <div class="section-heading">

                    <div>

                        <div class="section-kicker">
                            Simple by design
                        </div>

                        <h2 class="section-title">
                            From craving to doorstep.
                        </h2>

                    </div>

                    <p class="section-description">
                        Foodwala keeps the ordering journey clear,
                        fast and predictable from discovery to
                        confirmation.
                    </p>

                </div>


                <div class="experience-grid">

                    <div class="experience-card">

                        <div class="experience-index">
                            01 / DISCOVER
                        </div>

                        <h3 class="experience-title">
                            Find your next favourite.
                        </h3>

                        <p class="experience-text">
                            Search restaurants, cuisines and dishes,
                            then explore menus before deciding what
                            you want.
                        </p>

                    </div>


                    <div class="experience-card">

                        <div class="experience-index">
                            02 / BUILD
                        </div>

                        <h3 class="experience-title">
                            Build your order.
                        </h3>

                        <p class="experience-text">
                            Add dishes to your cart, adjust quantities,
                            review pricing and apply available offers.
                        </p>

                    </div>


                    <div class="experience-card">

                        <div class="experience-index">
                            03 / ENJOY
                        </div>

                        <h3 class="experience-title">
                            Confirm and relax.
                        </h3>

                        <p class="experience-text">
                            Sign in when you're ready to order, add
                            your delivery details, choose payment and
                            place your order.
                        </p>

                    </div>

                </div>

            </div>

        </section>


        <!-- =========================
             CTA
             ========================= -->

        <section class="cta">

            <div class="container">

                <div class="cta-card">

                    <div>

                        <h2 class="cta-title">
                            Your next great meal is
                            probably closer than you think.
                        </h2>

                        <p class="cta-text">
                            Explore Foodwala restaurants and discover
                            something worth ordering tonight.
                        </p>

                    </div>

                    <a href="<%= contextPath %>/restaurent"
                       class="primary-button">
                        Start exploring
                    </a>

                </div>

            </div>

        </section>

    </main>


    <!-- =========================
         FOOTER
         ========================= -->

    <footer>

        <div class="container">

            <div class="footer-grid">

                <div class="footer-brand">

                    <a href="<%= contextPath %>/Home.jsp"
                       class="brand">

                        <div class="brand-mark">
                            F
                        </div>

                        <div class="brand-name">
                            Food<span>wala</span>
                        </div>

                    </a>

                    <p class="footer-brand-text">
                        A modern food ordering experience built
                        around discovery, simplicity and great food.
                    </p>

                </div>


                <div>

                    <div class="footer-heading">
                        Discover
                    </div>

                    <div class="footer-links">

                        <a href="<%= contextPath %>/restaurent">
                            Restaurants
                        </a>

                        <a href="<%= contextPath %>/restaurent?search=Biryani">
                            Biryani
                        </a>

                        <a href="<%= contextPath %>/restaurent?search=South%20Indian">
                            South Indian
                        </a>

                    </div>

                </div>


                <div>

                    <div class="footer-heading">
                        Your Foodwala
                    </div>

                    <div class="footer-links">

                        <a href="<%= contextPath %>/Cart.jsp">
                            Cart
                        </a>

                        <a href="<%= contextPath %>/orderHistory">
                            Orders
                        </a>

                        <a href="<%= contextPath %>/favorites">
                            Favorites
                        </a>

                    </div>

                </div>


                <div>

                    <div class="footer-heading">
                        Account
                    </div>

                    <div class="footer-links">

                        <% if (loggedIn) { %>

                            <a href="<%= contextPath %>/logout">
                                Sign out
                            </a>

                        <% } else { %>

                            <a href="<%= contextPath %>/Login.jsp">
                                Sign in
                            </a>

                            <a href="<%= contextPath %>/Register.jsp">
                                Create account
                            </a>

                        <% } %>

                    </div>

                </div>

            </div>


            <div class="footer-bottom">

                <span>
                    © 2026 Foodwala. All rights reserved.
                </span>

                <span>
                    Built for a better food-ordering experience.
                </span>

            </div>

        </div>

    </footer>

</div>

</body>

</html>