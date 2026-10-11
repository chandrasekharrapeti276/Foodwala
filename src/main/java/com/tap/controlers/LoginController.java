package com.tap.controlers;

import java.io.IOException;

import com.tap.DAO1.UserDAO;
import com.tap.DAOimpl.UserDAOImpl;
import com.tap.module.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO =
            new UserDAOImpl();

    // =========================================================
    // GET - SHOW LOGIN PAGE
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher(
                "/Login.jsp"
        ).forward(
                request,
                response
        );
    }

    // =========================================================
    // POST - LOGIN
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        // =====================================================
        // VALIDATION
        // =====================================================

        if (username == null ||
                password == null ||
                username.trim().isEmpty() ||
                password.trim().isEmpty()) {

            request.setAttribute(
                    "error",
                    "Please enter username and password."
            );

            request.getRequestDispatcher(
                    "/Login.jsp"
            ).forward(
                    request,
                    response
            );

            return;
        }

        try {

            // =================================================
            // AUTHENTICATE USER
            // =================================================

            User user =
                    userDAO.login(
                            username.trim(),
                            password
                    );

            // =================================================
            // INVALID LOGIN
            // =================================================

            if (user == null) {

                request.setAttribute(
                        "error",
                        "Invalid username or password."
                );

                request.getRequestDispatcher(
                        "/Login.jsp"
                ).forward(
                        request,
                        response
                );

                return;
            }

            // =================================================
            // CREATE / GET SESSION
            // =================================================

            HttpSession session =
                    request.getSession();

            // =================================================
            // STORE USER INFORMATION
            // =================================================

            session.setAttribute(
                    "userId",
                    user.getUserId()
            );

            session.setAttribute(
                    "username",
                    user.getUsername()
            );

            session.setAttribute(
                    "user",
                    user
            );

            session.setAttribute(
                    "role",
                    user.getRole()
            );

            // =================================================
            // CHECK WHERE LOGIN WAS REQUESTED FROM
            // =================================================

            Object redirectAttribute =
                    session.getAttribute(
                            "redirectAfterLogin"
                    );

            String redirectPath = null;

            if (redirectAttribute != null) {

                redirectPath =
                        redirectAttribute.toString().trim();
            }

            // Remove it immediately so that a future login
            // does not accidentally reuse an old redirect.
            session.removeAttribute(
                    "redirectAfterLogin"
            );

            // =================================================
            // REDIRECT AFTER LOGIN
            // =================================================

            if (redirectPath != null &&
                    redirectPath.startsWith("/")) {

                /*
                 * Example:
                 *
                 * redirectPath = "/Foodwala/checkout"
                 *
                 * request.getContextPath() = "/Foodwala"
                 *
                 * We must not add the context path twice.
                 */

                if (redirectPath.equals(
                        request.getContextPath()
                                + "/checkout")) {

                    response.sendRedirect(
                            redirectPath
                    );

                    return;
                }

                /*
                 * Normal application-relative redirect.
                 */
                if (!redirectPath.startsWith(
                        request.getContextPath()
                )) {

                    response.sendRedirect(
                            request.getContextPath()
                                    + redirectPath
                    );

                    return;
                }

                /*
                 * Redirect already contains context path.
                 */
                response.sendRedirect(
                        redirectPath
                );

                return;
            }

            // =================================================
            // NORMAL LOGIN
            // =================================================

            response.sendRedirect(
                    request.getContextPath()
                            + "/restaurent"
            );

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to login. Please try again."
            );

            request.getRequestDispatcher(
                    "/Login.jsp"
            ).forward(
                    request,
                    response
            );
        }
    }
}