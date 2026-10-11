package com.tap.controlers;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");

        /*
         * Get the existing session.
         *
         * false prevents creation of a new session when
         * there is no existing session.
         */
        HttpSession session =
                request.getSession(false);

        if (session != null) {

            /*
             * Remove logged-in user information.
             */
            session.removeAttribute("userId");
            session.removeAttribute("username");
            session.removeAttribute("user");
            session.removeAttribute("role");

            /*
             * Remove temporary navigation information.
             */
            session.removeAttribute("returnTo");
            session.removeAttribute("redirectAfterLogin");

            /*
             * Remove any temporary checkout/customer
             * information from a previous order flow.
             */
            session.removeAttribute(
                    "pendingCustomerName"
            );

            session.removeAttribute(
                    "pendingPhone"
            );

            session.removeAttribute(
                    "pendingAddress"
            );

            session.removeAttribute(
                    "pendingPaymentMode"
            );

            /*
             * IMPORTANT:
             *
             * Do NOT invalidate the session.
             *
             * We intentionally keep:
             *
             *     cart
             *
             * so that the user's cart remains available
             * after logout.
             */
        }

        /*
         * After logout, return to the public
         * restaurant page.
         */
        response.sendRedirect(
                request.getContextPath()
                        + "/restaurent"
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Use the same logout process for POST requests.
         */
        doGet(
                request,
                response
        );
    }
}