package com.tap.controlers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tap.util.DBconnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================================================
    // POST - REGISTER NEW USER
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // =====================================================
        // GET FORM VALUES
        // =====================================================

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String address =
                request.getParameter("address");

        // =====================================================
        // NORMALIZE VALUES
        // =====================================================

        if (username != null) {
            username = username.trim();
        }

        if (email != null) {
            email = email.trim().toLowerCase();
        }

        if (phone != null) {
            phone = phone.trim();
        }

        if (address != null) {
            address = address.trim();
        }

        // =====================================================
        // BASIC VALIDATION
        // =====================================================

        if (isEmpty(username)
                || isEmpty(password)
                || isEmpty(email)
                || isEmpty(phone)
                || isEmpty(address)) {

            redirectWithError(
                    request,
                    response,
                    "failed"
            );

            return;
        }

        // =====================================================
        // LENGTH VALIDATION
        // =====================================================

        if (username.length() > 100
                || password.length() > 255
                || email.length() > 150
                || phone.length() > 20
                || address.length() > 255) {

            redirectWithError(
                    request,
                    response,
                    "failed"
            );

            return;
        }

        // =====================================================
        // USERNAME VALIDATION
        //
        // Allows:
        // letters
        // numbers
        // underscore
        // dot
        // hyphen
        //
        // Minimum 3 characters.
        // =====================================================

        if (!username.matches(
                "^[a-zA-Z0-9._-]{3,100}$")) {

            redirectWithError(
                    request,
                    response,
                    "failed"
            );

            return;
        }

        // =====================================================
        // EMAIL VALIDATION
        // =====================================================

        if (!email.matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {

            redirectWithError(
                    request,
                    response,
                    "failed"
            );

            return;
        }

        // =====================================================
        // PHONE VALIDATION
        //
        // Examples:
        // 9876543210
        // +919876543210
        // =====================================================

        if (!phone.matches(
                "^\\+?[0-9]{10,15}$")) {

            redirectWithError(
                    request,
                    response,
                    "failed"
            );

            return;
        }

        // =====================================================
        // SQL - CHECK EXISTING USER
        // =====================================================

        String checkSql =
                "SELECT userId "
                + "FROM users "
                + "WHERE username = ? "
                + "OR email = ?";

        // =====================================================
        // SQL - INSERT USER
        // =====================================================

        String insertSql =
                "INSERT INTO users "
                + "(username, password, email, phone, address, role) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        Connection connection = null;

        try {

            // =================================================
            // DATABASE CONNECTION
            // =================================================

            connection =
                    DBconnection.getConnection();

            if (connection == null) {

                redirectWithError(
                        request,
                        response,
                        "failed"
                );

                return;
            }

            // =================================================
            // CHECK USERNAME / EMAIL
            // =================================================

            try (
                    PreparedStatement checkStatement =
                            connection.prepareStatement(
                                    checkSql
                            )
            ) {

                checkStatement.setString(
                        1,
                        username
                );

                checkStatement.setString(
                        2,
                        email
                );

                try (
                        ResultSet resultSet =
                                checkStatement.executeQuery()
                ) {

                    if (resultSet.next()) {

                        redirectWithError(
                                request,
                                response,
                                "exists"
                        );

                        return;
                    }
                }
            }

            // =================================================
            // INSERT NEW USER
            // =================================================

            try (
                    PreparedStatement insertStatement =
                            connection.prepareStatement(
                                    insertSql
                            )
            ) {

                insertStatement.setString(
                        1,
                        username
                );

                /*
                 * Keep password format compatible with
                 * the current LoginController and UserDAOImpl.
                 */
                insertStatement.setString(
                        2,
                        password
                );

                insertStatement.setString(
                        3,
                        email
                );

                insertStatement.setString(
                        4,
                        phone
                );

                insertStatement.setString(
                        5,
                        address
                );

                /*
                 * IMPORTANT:
                 *
                 * A user registering normally must always
                 * receive the USER role.
                 *
                 * The registration form cannot create ADMIN.
                 */
                insertStatement.setString(
                        6,
                        "USER"
                );

                int rowsInserted =
                        insertStatement.executeUpdate();

                // =============================================
                // REGISTRATION SUCCESS
                // =============================================

                if (rowsInserted > 0) {

                    response.sendRedirect(
                            request.getContextPath()
                                    + "/Login.jsp?registered=success"
                    );

                    return;
                }

                // =============================================
                // INSERT FAILED
                // =============================================

                redirectWithError(
                        request,
                        response,
                        "failed"
                );
            }

        } catch (SQLException e) {

            e.printStackTrace();

            // =================================================
            // MYSQL DUPLICATE KEY
            //
            // username and email are UNIQUE.
            // Error 1062 = duplicate entry.
            // =================================================

            if (e.getErrorCode() == 1062) {

                redirectWithError(
                        request,
                        response,
                        "exists"
                );

            } else {

                redirectWithError(
                        request,
                        response,
                        "failed"
                );
            }

        } finally {

            // =================================================
            // CLOSE DATABASE CONNECTION
            // =================================================

            if (connection != null) {

                try {
                    connection.close();

                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // =========================================================
    // GET - OPEN REGISTRATION PAGE
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/Register.jsp"
        );
    }

    // =========================================================
    // CHECK EMPTY STRING
    // =========================================================

    private boolean isEmpty(String value) {

        return value == null
                || value.trim().isEmpty();
    }

    // =========================================================
    // REDIRECT WITH REGISTRATION ERROR
    // =========================================================

    private void redirectWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            String error)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/Register.jsp?error="
                        + error
        );
    }
}