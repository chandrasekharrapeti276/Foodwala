<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    /* =========================================================
       LOGIN ERROR
       ========================================================= */

    Object errorObject = request.getAttribute("error");

    String errorMessage = null;

    if (errorObject != null) {
        errorMessage = String.valueOf(errorObject);
    }


    /* =========================================================
       REGISTRATION SUCCESS
       ========================================================= */

    String registered = request.getParameter("registered");

    boolean registrationSuccess =
            "success".equalsIgnoreCase(registered);


    /* =========================================================
       REDIRECT AFTER LOGIN
       =========================================================

       CheckoutController stores:
       redirectAfterLogin = /checkout

       LoginController uses this value after successful login.
       ========================================================= */

    Object redirectObject =
            session.getAttribute("redirectAfterLogin");

    String redirectAfterLogin = null;

    if (redirectObject != null) {
        redirectAfterLogin =
                String.valueOf(redirectObject);
    }

    boolean checkoutLogin =
            redirectAfterLogin != null
            && redirectAfterLogin.endsWith("/checkout");
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0">

    <meta
        name="description"
        content="Login to your Foodwala account">

    <title>Foodwala | Login</title>


    <link
        rel="stylesheet"
        href="<%= contextPath %>/foodwala.css">


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
                Inter,
                "Segoe UI",
                Arial,
                Helvetica,
                sans-serif;

            color: #ffffff;

            background:
                radial-gradient(
                    circle at 10% 0%,
                    rgba(255, 106, 0, 0.13),
                    transparent 28%
                ),
                radial-gradient(
                    circle at 90% 20%,
                    rgba(255, 159, 67, 0.06),
                    transparent 25%
                ),
                #08080a;

            display: flex;
            flex-direction: column;
        }

        a {
            text-decoration: none;
        }


        /* =====================================================
           NAVBAR
           ===================================================== */

        .login-navbar {
            position: sticky;

            top: 0;

            z-index: 1000;

            width: 100%;

            min-height: 72px;

            background:
                rgba(10, 10, 12, 0.94);

            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);

            border-bottom:
                1px solid rgba(255, 255, 255, 0.07);

            box-shadow:
                0 8px 30px rgba(0, 0, 0, 0.28);
        }

        .nav-inner {
            width: min(92%, 1180px);

            min-height: 72px;

            margin: 0 auto;

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 20px;
        }

        .logo {
            color: #ff6a00;

            font-size: 28px;

            font-weight: 900;

            letter-spacing: -1px;
        }

        .logo span {
            color: #ffffff;
        }

        .nav-links {
            display: flex;

            align-items: center;

            gap: 8px;
        }

        .nav-link {
            min-height: 40px;

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 0 14px;

            color: #b9b9bf;

            border-radius: 10px;

            font-size: 13px;

            font-weight: 750;

            transition:
                color 0.2s ease,
                background 0.2s ease,
                transform 0.2s ease;
        }

        .nav-link:hover {
            color: #ffffff;

            background:
                rgba(255, 255, 255, 0.06);

            transform: translateY(-1px);
        }

        .cart-link {
            color: #ffffff;

            background:
                rgba(255, 106, 0, 0.08);

            border:
                1px solid rgba(255, 106, 0, 0.28);
        }

        .cart-link:hover {
            background:
                rgba(255, 106, 0, 0.15);

            border-color:
                rgba(255, 106, 0, 0.45);
        }


        /* =====================================================
           MAIN LOGIN AREA
           ===================================================== */

        .login-wrap {
            flex: 1;

            width: 100%;

            display: flex;

            align-items: center;

            justify-content: center;

            padding:
                55px 18px 70px;
        }


        /* =====================================================
           LOGIN CARD
           ===================================================== */

        .login-card {
            position: relative;

            width: 100%;

            max-width: 460px;

            padding:
                38px 34px;

            border-radius: 22px;

            background:
                linear-gradient(
                    145deg,
                    rgba(25, 25, 29, 0.98),
                    rgba(14, 14, 17, 0.98)
                );

            border:
                1px solid rgba(255, 255, 255, 0.075);

            box-shadow:
                0 25px 70px rgba(0, 0, 0, 0.42);

            overflow: hidden;
        }

        .login-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;
            right: 0;

            height: 2px;

            background:
                linear-gradient(
                    90deg,
                    transparent,
                    #ff6a00,
                    transparent
                );

            opacity: 0.9;
        }


        /* =====================================================
           LOGIN ICON
           ===================================================== */

        .login-icon {
            width: 64px;
            height: 64px;

            margin:
                0 auto 20px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 18px;

            background:
                linear-gradient(
                    135deg,
                    rgba(255, 106, 0, 0.18),
                    rgba(255, 106, 0, 0.06)
                );

            border:
                1px solid rgba(255, 106, 0, 0.25);

            color: #ff7b22;

            font-size: 28px;

            box-shadow:
                0 10px 30px rgba(255, 106, 0, 0.12);
        }


        /* =====================================================
           HEADER
           ===================================================== */

        .login-card h1 {
            margin:
                0 0 9px;

            text-align: center;

            color: #ffffff;

            font-size: 30px;

            font-weight: 900;

            letter-spacing: -0.7px;

            line-height: 1.2;
        }

        .login-title-highlight {
            color: #ff6a00;
        }

        .description {
            max-width: 350px;

            margin:
                0 auto 26px;

            text-align: center;

            color: #85858c;

            font-size: 13px;

            line-height: 1.6;
        }


        /* =====================================================
           CHECKOUT NOTICE
           ===================================================== */

        .checkout-notice {
            display: flex;

            align-items: flex-start;

            gap: 10px;

            margin-bottom: 18px;

            padding:
                13px 14px;

            border-radius: 12px;

            background:
                rgba(255, 106, 0, 0.06);

            border:
                1px solid rgba(255, 106, 0, 0.20);

            color: #e9a77a;

            font-size: 12px;

            line-height: 1.55;
        }

        .checkout-icon {
            flex-shrink: 0;

            width: 24px;
            height: 24px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 7px;

            background:
                rgba(255, 106, 0, 0.12);

            color: #ff7b22;
        }


        /* =====================================================
           ALERTS
           ===================================================== */

        .alert {
            padding:
                12px 14px;

            margin-bottom: 18px;

            border-radius: 11px;

            font-size: 12px;

            line-height: 1.5;
        }

        .alert-error {
            color: #ff8a83;

            background:
                rgba(231, 76, 60, 0.07);

            border:
                1px solid rgba(231, 76, 60, 0.22);
        }

        .alert-success {
            color: #62dc92;

            background:
                rgba(37, 199, 111, 0.07);

            border:
                1px solid rgba(37, 199, 111, 0.22);
        }

        .alert-icon {
            margin-right: 5px;

            font-weight: 900;
        }


        /* =====================================================
           FORM
           ===================================================== */

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;

            margin-bottom: 8px;

            color: #dedee2;

            font-size: 12px;

            font-weight: 800;

            letter-spacing: 0.2px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;

            left: 14px;

            top: 50%;

            transform: translateY(-50%);

            color: #66666d;

            font-size: 15px;

            pointer-events: none;
        }

        .form-control {
            width: 100%;

            min-height: 48px;

            padding:
                11px 13px 11px 42px;

            border:
                1px solid rgba(255, 255, 255, 0.09);

            border-radius: 11px;

            outline: none;

            background:
                rgba(255, 255, 255, 0.035);

            color: #ffffff;

            font-size: 14px;

            transition:
                border-color 0.2s ease,
                background 0.2s ease,
                box-shadow 0.2s ease;
        }

        .form-control:hover {
            border-color:
                rgba(255, 255, 255, 0.14);
        }

        .form-control:focus {
            border-color: #ff6a00;

            background:
                rgba(255, 106, 0, 0.035);

            box-shadow:
                0 0 0 3px
                rgba(255, 106, 0, 0.10);
        }

        .form-control::placeholder {
            color: #5f5f66;
        }

        .form-control:-webkit-autofill,
        .form-control:-webkit-autofill:hover,
        .form-control:-webkit-autofill:focus {
            -webkit-text-fill-color: #ffffff;

            box-shadow:
                0 0 0 1000px #151519 inset;

            transition:
                background-color 5000s ease-in-out 0s;
        }


        /* =====================================================
           LOGIN BUTTON
           ===================================================== */

        .login-button {
            width: 100%;

            min-height: 50px;

            margin-top: 5px;

            border: 0;

            border-radius: 11px;

            background:
                linear-gradient(
                    135deg,
                    #ff7820,
                    #ed5700
                );

            color: #ffffff;

            font-size: 14px;

            font-weight: 850;

            cursor: pointer;

            box-shadow:
                0 9px 24px
                rgba(255, 106, 0, 0.18);

            transition:
                transform 0.2s ease,
                box-shadow 0.2s ease,
                filter 0.2s ease;
        }

        .login-button:hover {
            transform: translateY(-2px);

            box-shadow:
                0 13px 30px
                rgba(255, 106, 0, 0.28);

            filter: brightness(1.05);
        }

        .login-button:active {
            transform: translateY(0);
        }


        /* =====================================================
           REGISTER
           ===================================================== */

        .register-section {
            margin-top: 24px;

            padding-top: 21px;

            border-top:
                1px solid rgba(255, 255, 255, 0.07);

            text-align: center;
        }

        .register-text {
            color: #77777e;

            font-size: 12px;

            line-height: 1.5;
        }

        .register-link {
            color: #ff8b4c;

            font-weight: 800;

            transition:
                color 0.2s ease;
        }

        .register-link:hover {
            color: #ffb07b;

            text-decoration: underline;
        }


        /* =====================================================
           CONTINUE BROWSING
           ===================================================== */

        .browse-link {
            display: block;

            margin-top: 18px;

            text-align: center;

            color: #66666d;

            font-size: 11px;

            font-weight: 700;

            transition:
                color 0.2s ease;
        }

        .browse-link:hover {
            color: #ff8b4c;

            text-decoration: underline;
        }


        /* =====================================================
           SECURITY NOTE
           ===================================================== */

        .security-note {
            display: flex;

            align-items: center;

            justify-content: center;

            gap: 7px;

            margin-top: 20px;

            color: #55555c;

            font-size: 10px;
        }

        .security-note span {
            color: #25c76f;
        }


        /* =====================================================
           FOOTER
           ===================================================== */

        .footer {
            padding:
                21px 15px;

            color: #65656c;

            background:
                #08080a;

            border-top:
                1px solid rgba(255, 255, 255, 0.05);

            text-align: center;

            font-size: 11px;
        }


        /* =====================================================
           MOBILE
           ===================================================== */

        @media (max-width: 600px) {

            .login-navbar {
                min-height: 66px;
            }

            .nav-inner {
                width: 94%;

                min-height: 66px;
            }

            .logo {
                font-size: 24px;
            }

            .nav-link {
                min-height: 36px;

                padding:
                    0 9px;

                font-size: 11px;
            }

            .login-wrap {
                align-items: flex-start;

                padding:
                    30px 14px 50px;
            }

            .login-card {
                max-width: 100%;

                padding:
                    29px 21px;

                border-radius: 18px;
            }

            .login-icon {
                width: 58px;
                height: 58px;

                font-size: 25px;
            }

            .login-card h1 {
                font-size: 26px;
            }

            .description {
                font-size: 12px;
            }
        }


        @media (max-width: 390px) {

            .nav-links {
                gap: 3px;
            }

            .nav-link {
                padding:
                    0 7px;

                font-size: 10px;
            }

            .login-card {
                padding:
                    26px 17px;
            }

            .login-card h1 {
                font-size: 24px;
            }

            .form-control {
                min-height: 47px;
            }
        }

    </style>

</head>


<body>


    <!-- =====================================================
         NAVBAR
         ===================================================== -->

    <header class="login-navbar">

        <div class="nav-inner">


            <a
                class="logo"
                href="<%= contextPath %>/restaurent">

                Food<span>wala</span>

            </a>


            <nav class="nav-links">

                <a
                    class="nav-link"
                    href="<%= contextPath %>/restaurent">

                    Restaurants

                </a>


                <a
                    class="nav-link cart-link"
                    href="<%= contextPath %>/cart">

                    🛒 Cart

                </a>

            </nav>

        </div>

    </header>


    <!-- =====================================================
         LOGIN AREA
         ===================================================== -->

    <main class="login-wrap">

        <section class="login-card">


            <!-- LOGIN ICON -->

            <div class="login-icon">
                🔐
            </div>


            <!-- TITLE -->

            <h1>

                Welcome to

                <span class="login-title-highlight">
                    Foodwala
                </span>

            </h1>


            <p class="description">

                Login to your account and continue
                your delicious food journey.

            </p>


            <!-- =================================================
                 CHECKOUT NOTICE
                 ================================================= -->

            <% if (checkoutLogin) { %>

                <div class="checkout-notice">

                    <div class="checkout-icon">
                        🛒
                    </div>

                    <div>

                        Please login to continue to checkout.
                        Your cart will remain saved and you will
                        return to checkout after successful login.

                    </div>

                </div>

            <% } %>


            <!-- =================================================
                 REGISTRATION SUCCESS
                 ================================================= -->

            <% if (registrationSuccess) { %>

                <div class="alert alert-success">

                    <span class="alert-icon">
                        ✓
                    </span>

                    Registration successful.
                    Please login with your new account.

                </div>

            <% } %>


            <!-- =================================================
                 LOGIN ERROR
                 ================================================= -->

            <% if (
                    errorMessage != null &&
                    !errorMessage.trim().isEmpty()
            ) { %>

                <div class="alert alert-error">

                    <span class="alert-icon">
                        !
                    </span>

                    <%= errorMessage %>

                </div>

            <% } %>


            <!-- =================================================
                 LOGIN FORM
                 ================================================= -->

            <form
                action="<%= contextPath %>/login"
                method="post">


                <!-- USERNAME -->

                <div class="form-group">

                    <label for="username">
                        Username
                    </label>


                    <div class="input-wrapper">

                        <span class="input-icon">
                            👤
                        </span>


                        <input
                            class="form-control"
                            id="username"
                            name="username"
                            type="text"
                            autocomplete="username"
                            placeholder="Enter your username"
                            maxlength="100"
                            required>

                    </div>

                </div>


                <!-- PASSWORD -->

                <div class="form-group">

                    <label for="password">
                        Password
                    </label>


                    <div class="input-wrapper">

                        <span class="input-icon">
                            🔒
                        </span>


                        <input
                            class="form-control"
                            id="password"
                            name="password"
                            type="password"
                            autocomplete="current-password"
                            placeholder="Enter your password"
                            maxlength="255"
                            required>

                    </div>

                </div>


                <!-- LOGIN -->

                <button
                    class="login-button"
                    type="submit">

                    Login to Foodwala

                </button>

            </form>


            <!-- =================================================
                 REGISTER
                 ================================================= -->

            <div class="register-section">

                <div class="register-text">

                    Don't have an account?

                    <a
                        class="register-link"
                        href="<%= contextPath %>/register">

                        Create an account

                    </a>

                </div>

            </div>


            <!-- =================================================
                 BROWSE WITHOUT LOGIN
                 ================================================= -->

            <a
                class="browse-link"
                href="<%= contextPath %>/restaurent">

                ← Continue browsing restaurants

            </a>


            <!-- SECURITY -->

            <div class="security-note">

                <span>●</span>

                Your account information is securely handled.

            </div>


        </section>

    </main>


    <!-- =====================================================
         FOOTER
         ===================================================== -->

    <footer class="footer">

        Foodwala · Fresh food. Simple ordering.

    </footer>


</body>

</html>