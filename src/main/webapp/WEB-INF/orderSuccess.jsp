<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Foodwala | Order Successful</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/foodwala.css">

</head>

<body>

<header class="navbar">

    <div class="nav-inner">

        <a class="logo"
           href="<%= request.getContextPath() %>/restaurent">
            Foodwala
        </a>

        <div class="nav-links">

            <a href="<%= request.getContextPath() %>/restaurent">
                Restaurants
            </a>

            <a href="<%= request.getContextPath() %>/logout">
                Logout
            </a>

        </div>

    </div>

</header>


<main class="page">

    <section class="success-card">

        <div class="success-icon">
            ✓
        </div>


        <h1>
            Order Placed Successfully!
        </h1>


        <p class="description">
            Thank you for ordering with Foodwala.
            Your order has been placed successfully.
        </p>


        <%
            Object orderId =
                    request.getAttribute("orderId");

            Object total =
                    request.getAttribute("total");
        %>


        <%
            if (orderId != null) {
        %>

            <p>
                <strong>
                    Order ID:
                </strong>

                #<%= orderId %>
            </p>

        <%
            }
        %>


        <%
            if (total != null) {
        %>

            <p>
                <strong>
                    Order Total:
                </strong>

                ₹<%= String.format(
                        "%.2f",
                        ((Number) total).doubleValue()
                    ) %>
            </p>

        <%
            }
        %>


        <div
            class="card-actions"
            style="justify-content:center;">

            <a
                class="btn btn-primary"
                href="<%= request.getContextPath() %>/restaurent">

                Order More Food

            </a>

        </div>

    </section>

</main>


<footer class="footer">
    Foodwala · Thank you for ordering
</footer>

</body>

</html>