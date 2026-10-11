<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    String error = request.getParameter("error");

    Object controllerError = request.getAttribute("error");

    String errorMessage = null;

    if (controllerError != null) {
        errorMessage = String.valueOf(controllerError);
    } else if ("exists".equalsIgnoreCase(error)) {
        errorMessage = "Username or email already exists.";
    } else if ("failed".equalsIgnoreCase(error)) {
        errorMessage = "Unable to create your account. Please try again.";
    } else if ("invalid".equalsIgnoreCase(error)) {
        errorMessage = "Please enter valid registration details.";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <meta name="description"
          content="Create your Foodwala account">

    <title>Foodwala | Create Account</title>

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
                Arial,
                Helvetica,
                sans-serif;

            color: #f5f5f5;

            background:
                radial-gradient(
                    circle at 15% 10%,
                    rgba(255, 107, 53, 0.10),
                    transparent 28%
                ),
                radial-gradient(
                    circle at 85% 20%,
                    rgba(255, 174, 0, 0.07),
                    transparent 25%
                ),
                linear-gradient(
                    135deg,
                    #0b0b0d 0%,
                    #111113 50%,
                    #0a0a0c 100%
                );

            display: flex;
            flex-direction: column;
        }

        a {
            text-decoration: none;
        }


        /* =====================================================
           NAVBAR
           ===================================================== */

        .navbar {

            position: sticky;
            top: 0;
            z-index: 1000;

            background:
                rgba(13, 13, 15, 0.94);

            border-bottom:
                1px solid rgba(255, 255, 255, 0.07);

            backdrop-filter: blur(14px);

            box-shadow:
                0 8px 30px rgba(0, 0, 0, 0.35);

            padding: 13px 20px;
        }

        .nav-inner {

            width: 100%;
            max-width: 1180px;

            min-height: 52px;

            margin: 0 auto;

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 20px;
        }

        .logo {

            color: #ffffff;

            font-size: 27px;

            font-weight: 900;

            letter-spacing: -0.8px;
        }

        .logo::after {

            content: ".";

            color: #ff6b35;
        }

        .nav-links {

            display: flex;

            align-items: center;

            gap: 7px;

            flex-wrap: wrap;
        }

        .nav-links a {

            color: #d7d7d7;

            padding:
                9px 13px;

            border:
                1px solid transparent;

            border-radius: 10px;

            font-size: 13px;

            font-weight: 700;

            transition:
                background 0.2s ease,
                color 0.2s ease,
                border-color 0.2s ease;
        }

        .nav-links a:hover {

            color: #ffffff;

            background:
                rgba(255, 107, 53, 0.10);

            border-color:
                rgba(255, 107, 53, 0.20);
        }


        /* =====================================================
           MAIN
           ===================================================== */

        .register-wrap {

            flex: 1;

            width: 100%;

            display: flex;

            justify-content: center;

            align-items: flex-start;

            padding:
                55px 20px 70px;
        }


        /* =====================================================
           REGISTER CARD
           ===================================================== */

        .register-card {

            position: relative;

            width: 100%;

            max-width: 520px;

            padding:
                38px 36px 34px;

            background:
                linear-gradient(
                    145deg,
                    #18181b 0%,
                    #121214 100%
                );

            border:
                1px solid rgba(255, 255, 255, 0.08);

            border-radius: 24px;

            box-shadow:
                0 25px 70px rgba(0, 0, 0, 0.48),
                0 0 0 1px rgba(255, 107, 53, 0.025);

            overflow: hidden;
        }

        .register-card::before {

            content: "";

            position: absolute;

            top: -100px;
            right: -100px;

            width: 230px;
            height: 230px;

            border-radius: 50%;

            background:
                radial-gradient(
                    circle,
                    rgba(255, 107, 53, 0.13),
                    transparent 68%
                );

            pointer-events: none;
        }

        .register-card::after {

            content: "";

            position: absolute;

            bottom: -120px;
            left: -100px;

            width: 250px;
            height: 250px;

            border-radius: 50%;

            background:
                radial-gradient(
                    circle,
                    rgba(255, 174, 0, 0.06),
                    transparent 70%
                );

            pointer-events: none;
        }


        /* =====================================================
           BRAND ICON
           ===================================================== */

        .register-icon {

            position: relative;
            z-index: 1;

            width: 64px;
            height: 64px;

            margin:
                0 auto 19px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 18px;

            background:
                linear-gradient(
                    135deg,
                    #ff7a3d,
                    #f4511e
                );

            border:
                1px solid rgba(255, 255, 255, 0.10);

            color: #ffffff;

            font-size: 30px;

            font-weight: 900;

            box-shadow:
                0 12px 30px
                rgba(255, 107, 53, 0.25);
        }


        /* =====================================================
           HEADING
           ===================================================== */

        .register-card h1 {

            position: relative;
            z-index: 1;

            margin:
                0 0 9px;

            text-align: center;

            color: #ffffff;

            font-size: 30px;

            line-height: 1.2;

            letter-spacing: -0.5px;
        }

        .subtitle {

            position: relative;
            z-index: 1;

            max-width: 390px;

            margin:
                0 auto 28px;

            text-align: center;

            color: #99999f;

            font-size: 14px;

            line-height: 1.65;
        }


        /* =====================================================
           ERROR MESSAGE
           ===================================================== */

        .error-message {

            position: relative;
            z-index: 1;

            margin-bottom: 20px;

            padding:
                13px 15px;

            border:
                1px solid rgba(255, 80, 80, 0.25);

            border-radius: 11px;

            background:
                rgba(180, 35, 24, 0.13);

            color: #ff9b9b;

            font-size: 13px;

            line-height: 1.5;

            text-align: center;
        }


        /* =====================================================
           FORM
           ===================================================== */

        form {

            position: relative;
            z-index: 1;
        }

        .form-group {

            margin-bottom: 18px;
        }

        .form-group label {

            display: block;

            margin-bottom: 8px;

            color: #eeeeef;

            font-size: 13px;

            font-weight: 800;
        }

        .form-control {

            width: 100%;

            min-height: 49px;

            padding:
                12px 14px;

            border:
                1px solid rgba(255, 255, 255, 0.10);

            border-radius: 11px;

            outline: none;

            background:
                #0d0d0f;

            color: #ffffff;

            font-size: 14px;

            transition:
                border-color 0.2s ease,
                box-shadow 0.2s ease,
                background 0.2s ease;
        }

        .form-control:hover {

            border-color:
                rgba(255, 255, 255, 0.16);
        }

        .form-control:focus {

            border-color:
                #ff6b35;

            background:
                #101012;

            box-shadow:
                0 0 0 3px
                rgba(255, 107, 53, 0.12);
        }

        .form-control::placeholder {

            color: #66666c;
        }


        /* =====================================================
           PASSWORD HINT
           ===================================================== */

        .field-hint {

            display: block;

            margin-top: 6px;

            color: #68686e;

            font-size: 11px;

            line-height: 1.4;
        }


        /* =====================================================
           CREATE ACCOUNT BUTTON
           ===================================================== */

        .create-button {

            width: 100%;

            min-height: 51px;

            margin-top: 4px;

            border: 0;

            border-radius: 11px;

            background:
                linear-gradient(
                    135deg,
                    #ff7a3d,
                    #ff5a1f
                );

            color: #ffffff;

            font-size: 15px;

            font-weight: 900;

            letter-spacing: 0.1px;

            cursor: pointer;

            box-shadow:
                0 10px 28px
                rgba(255, 107, 53, 0.20);

            transition:
                transform 0.2s ease,
                box-shadow 0.2s ease,
                filter 0.2s ease;
        }

        .create-button:hover {

            transform:
                translateY(-1px);

            filter:
                brightness(1.05);

            box-shadow:
                0 14px 34px
                rgba(255, 107, 53, 0.28);
        }

        .create-button:active {

            transform:
                translateY(0);
        }

        .create-button:focus-visible {

            outline:
                2px solid #ffad7f;

            outline-offset: 3px;
        }


        /* =====================================================
           LOGIN SECTION
           ===================================================== */

        .login-section {

            position: relative;
            z-index: 1;

            margin-top: 25px;

            padding-top: 21px;

            border-top:
                1px solid rgba(255, 255, 255, 0.07);

            text-align: center;
        }

        .login-text {

            color: #89898f;

            font-size: 13px;

            line-height: 1.5;
        }

        .login-link {

            color: #ff7a3d;

            font-weight: 800;

            margin-left: 3px;
        }

        .login-link:hover {

            color: #ff9a68;

            text-decoration: underline;
        }


        /* =====================================================
           BROWSE LINK
           ===================================================== */

        .browse-link {

            position: relative;
            z-index: 1;

            display: block;

            margin-top: 18px;

            text-align: center;

            color: #77777e;

            font-size: 12px;

            font-weight: 700;
        }

        .browse-link:hover {

            color: #ff8a55;

            text-decoration: underline;
        }


        /* =====================================================
           ACCOUNT NOTE
           ===================================================== */

        .account-note {

            position: relative;
            z-index: 1;

            margin-top: 21px;

            padding-top: 17px;

            border-top:
                1px solid rgba(255, 255, 255, 0.06);

            color: #66666c;

            font-size: 11px;

            line-height: 1.65;

            text-align: center;
        }


        /* =====================================================
           FOOTER
           ===================================================== */

        .footer {

            background:
                #09090b;

            border-top:
                1px solid rgba(255, 255, 255, 0.06);

            color: #77777d;

            text-align: center;

            padding:
                22px 15px;

            font-size: 12px;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 600px) {

            .navbar {

                padding:
                    11px 14px;
            }

            .nav-inner {

                min-height: 48px;

                gap: 10px;
            }

            .logo {

                font-size: 23px;
            }

            .nav-links {

                gap: 3px;
            }

            .nav-links a {

                padding:
                    8px 9px;

                font-size: 11px;
            }

            .register-wrap {

                padding:
                    30px 14px 45px;
            }

            .register-card {

                padding:
                    29px 21px 27px;

                border-radius: 19px;
            }

            .register-icon {

                width: 58px;
                height: 58px;

                font-size: 27px;

                border-radius: 16px;
            }

            .register-card h1 {

                font-size: 25px;
            }

            .subtitle {

                font-size: 13px;

                margin-bottom: 23px;
            }

            .form-group {

                margin-bottom: 15px;
            }

            .form-control {

                min-height: 47px;

                font-size: 14px;
            }

            .create-button {

                min-height: 49px;
            }
        }


        @media (max-width: 390px) {

            .nav-links a:first-child {

                display: none;
            }

            .register-wrap {

                padding-left: 11px;
                padding-right: 11px;
            }

            .register-card {

                padding:
                    26px 17px 25px;

                border-radius: 17px;
            }

            .register-card h1 {

                font-size: 23px;
            }

            .account-note {

                font-size: 10.5px;
            }
        }

    </style>

</head>


<body>


<!-- =========================================================
     NAVBAR
     ========================================================= -->

<header class="navbar">

    <div class="nav-inner">

        <a
            class="logo"
            href="<%= contextPath %>/restaurent">

            Foodwala

        </a>


        <nav class="nav-links">

            <a
                href="<%= contextPath %>/restaurent">

                Restaurants

            </a>


            <a
                href="<%= contextPath %>/cart">

                🛒 Cart

            </a>

        </nav>

    </div>

</header>


<!-- =========================================================
     REGISTER
     ========================================================= -->

<main class="register-wrap">

    <section class="register-card">


        <!-- BRAND ICON -->

        <div class="register-icon">

            F

        </div>


        <!-- TITLE -->

        <h1>

            Create your account

        </h1>


        <p class="subtitle">

            Join Foodwala and make your food ordering
            experience faster and easier.

        </p>


        <!-- =================================================
             ERROR MESSAGE
             ================================================= -->

        <% if (errorMessage != null &&
               !errorMessage.trim().isEmpty()) { %>

            <div class="error-message">

                <%= errorMessage %>

            </div>

        <% } %>


        <!-- =================================================
             REGISTRATION FORM
             ================================================= -->

        <form
            action="<%= contextPath %>/register"
            method="post">


            <!-- USERNAME -->

            <div class="form-group">

                <label for="username">

                    Username

                </label>

                <input
                    class="form-control"
                    type="text"
                    id="username"
                    name="username"
                    placeholder="Enter your username"
                    maxlength="100"
                    autocomplete="username"
                    required>

            </div>


            <!-- PASSWORD -->

            <div class="form-group">

                <label for="password">

                    Password

                </label>

                <input
                    class="form-control"
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Create a password"
                    maxlength="255"
                    autocomplete="new-password"
                    required>

                <span class="field-hint">

                    Choose a password you can remember.

                </span>

            </div>


            <!-- EMAIL -->

            <div class="form-group">

                <label for="email">

                    Email Address

                </label>

                <input
                    class="form-control"
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Enter your email address"
                    maxlength="150"
                    autocomplete="email"
                    required>

            </div>


            <!-- PHONE -->

            <div class="form-group">

                <label for="phone">

                    Phone Number

                </label>

                <input
                    class="form-control"
                    type="tel"
                    id="phone"
                    name="phone"
                    placeholder="Enter your phone number"
                    maxlength="20"
                    autocomplete="tel"
                    required>

            </div>


            <!-- ADDRESS -->

            <div class="form-group">

                <label for="address">

                    Delivery Address

                </label>

                <input
                    class="form-control"
                    type="text"
                    id="address"
                    name="address"
                    placeholder="Enter your delivery address"
                    maxlength="255"
                    autocomplete="street-address"
                    required>

            </div>


            <!-- CREATE ACCOUNT -->

            <button
                type="submit"
                class="create-button">

                Create Account

            </button>

        </form>


        <!-- =================================================
             LOGIN
             ================================================= -->

        <div class="login-section">

            <div class="login-text">

                Already have an account?

                <a
                    class="login-link"
                    href="<%= contextPath %>/login">

                    Login

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


        <!-- =================================================
             NOTE
             ================================================= -->

        <div class="account-note">

            You can browse restaurants, view menus and add
            items to your cart without logging in.
            Login is required when you proceed to checkout.

        </div>


    </section>

</main>


<!-- =========================================================
     FOOTER
     ========================================================= -->

<footer class="footer">

    Foodwala · Fresh food. Simple ordering.

</footer>


</body>

</html>