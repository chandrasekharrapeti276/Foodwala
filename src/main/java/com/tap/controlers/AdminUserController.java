
package com.tap.controlers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

import com.tap.DAO1.UserDAO;
import com.tap.DAOimpl.UserDAOImpl;
import com.tap.module.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/adminUsers")
public class AdminUserController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    private static final String ADMIN_ROLE = "ADMIN";
    private static final String LOGIN_PAGE = "/Login.jsp";
    private static final String USER_PAGE = "/AdminUser.jsp";

    private static final String[] VALID_ROLES = {
        "ALL", "ADMIN", "USER"
    };

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (!isAdmin(session)) {
            response.sendRedirect(
                    request.getContextPath() + LOGIN_PAGE);
            return;
        }

        String search = trimToEmpty(
                request.getParameter("search"));

        String roleFilter = trimToEmpty(
                request.getParameter("role"))
                .toUpperCase(Locale.ROOT);

        if (!isValidRoleFilter(roleFilter)) {
            roleFilter = "ALL";
        }

        try {
            List<User> fetchedUsers = userDAO.getAllUsers();

            List<User> allUsers = fetchedUsers == null
                    ? Collections.emptyList()
                    : fetchedUsers;

            int totalUsers = 0;
            int adminUsers = 0;
            int customerUsers = 0;

            List<User> filteredUsers = new ArrayList<>();

            String searchValue = search.toLowerCase(Locale.ROOT);

            for (User user : allUsers) {
                if (user == null) {
                    continue;
                }

                totalUsers++;

                String currentRole = trimToEmpty(user.getRole());

                if (ADMIN_ROLE.equalsIgnoreCase(currentRole)) {
                    adminUsers++;
                } else {
                    customerUsers++;
                }

                boolean roleMatches =
                        "ALL".equals(roleFilter)
                        || roleFilter.equalsIgnoreCase(currentRole);

                if (!roleMatches) {
                    continue;
                }

                boolean searchMatches = searchValue.isEmpty();

                if (!searchMatches) {
                    String username = safeLower(user.getUsername());
                    String email = safeLower(user.getEmail());
                    String phone = safeLower(user.getPhone());
                    String address = safeLower(user.getAddress());
                    String userId = String.valueOf(user.getUserId());

                    searchMatches =
                            username.contains(searchValue)
                            || email.contains(searchValue)
                            || phone.contains(searchValue)
                            || address.contains(searchValue)
                            || userId.contains(searchValue);
                }

                if (searchMatches) {
                    filteredUsers.add(user);
                }
            }

            request.setAttribute("users", filteredUsers);
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("adminUsers", adminUsers);
            request.setAttribute("customerUsers", customerUsers);
            request.setAttribute("search", search);
            request.setAttribute("roleFilter", roleFilter);
            request.setAttribute("userError", null);

            request.getRequestDispatcher(USER_PAGE)
                    .forward(request, response);

        } catch (Exception e) {
            getServletContext().log(
                    "Error loading users in AdminUserController.", e);

            request.setAttribute("users", Collections.emptyList());
            request.setAttribute("totalUsers", 0);
            request.setAttribute("adminUsers", 0);
            request.setAttribute("customerUsers", 0);
            request.setAttribute("search", search);
            request.setAttribute("roleFilter", roleFilter);
            request.setAttribute(
                    "userError",
                    "Unable to load user information. Please try again.");

            request.getRequestDispatcher(USER_PAGE)
                    .forward(request, response);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (!isAdmin(session)) {
            response.sendRedirect(
                    request.getContextPath() + LOGIN_PAGE);
            return;
        }

        String action = trimToEmpty(
                request.getParameter("action"))
                .toLowerCase(Locale.ROOT);

        try {
            switch (action) {
                case "add":
                    addUser(request);
                    break;

                case "update":
                    updateUser(request, session);
                    break;

                case "delete":
                    deleteUser(request, session);
                    break;

                default:
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid user management action.");
                    return;
            }

            response.sendRedirect(
                    request.getContextPath() + "/adminUsers?updated=1");

        } catch (IllegalArgumentException e) {
            getServletContext().log(
                    "Invalid user management request.", e);

            response.sendRedirect(
                    request.getContextPath()
                    + "/adminUsers?error=invalid");

        } catch (Exception e) {
            getServletContext().log(
                    "Error processing user management action.", e);

            response.sendRedirect(
                    request.getContextPath()
                    + "/adminUsers?error=operation");
        }
    }

    private void addUser(HttpServletRequest request)
            throws Exception {

        User user = readUserForm(request);

        String password = trimToEmpty(
                request.getParameter("password"));

        validateUser(user, password, true);

        user.setPassword(password);

        userDAO.addUser(user);
    }

    private void updateUser(
            HttpServletRequest request,
            HttpSession session) throws Exception {

        int userId = parseUserId(
                request.getParameter("userId"));

        int loggedInUserId = parseSessionUserId(session);

        if (userId == loggedInUserId) {
            throw new IllegalArgumentException(
                    "You cannot edit your own account here.");
        }

        User existingUser = userDAO.getUser(userId);

        if (existingUser == null) {
            throw new IllegalArgumentException("User not found.");
        }

        User submittedUser = readUserForm(request);
        submittedUser.setUserId(userId);

        String password = trimToEmpty(
                request.getParameter("password"));

        validateUser(submittedUser, password, false);

        // Blank password means retain the existing password.
        if (password.isEmpty()) {
            submittedUser.setPassword(existingUser.getPassword());
        } else {
            submittedUser.setPassword(password);
        }

        userDAO.updateUser(submittedUser);
    }

    private void deleteUser(
            HttpServletRequest request,
            HttpSession session) throws Exception {

        int userId = parseUserId(
                request.getParameter("userId"));

        int loggedInUserId = parseSessionUserId(session);

        if (userId == loggedInUserId) {
            throw new IllegalArgumentException(
                    "You cannot delete your own account.");
        }

        User existingUser = userDAO.getUser(userId);

        if (existingUser == null) {
            throw new IllegalArgumentException("User not found.");
        }

        userDAO.deleteUser(userId);
    }

    private User readUserForm(HttpServletRequest request) {
        User user = new User();

        user.setUsername(trimToEmpty(
                request.getParameter("username")));

        user.setPassword(trimToEmpty(
                request.getParameter("password")));

        user.setEmail(trimToEmpty(
                request.getParameter("email")));

        user.setPhone(trimToEmpty(
                request.getParameter("phone")));

        user.setAddress(trimToEmpty(
                request.getParameter("address")));

        String role = trimToEmpty(
                request.getParameter("role"))
                .toUpperCase(Locale.ROOT);

        if (!"ADMIN".equals(role) && !"USER".equals(role)) {
            throw new IllegalArgumentException("Invalid user role.");
        }

        user.setRole(role);

        return user;
    }

    private void validateUser(
            User user,
            String password,
            boolean requirePassword) {

        if (user.getUsername().isEmpty()) {
            throw new IllegalArgumentException("Username is required.");
        }

        if (user.getUsername().length() > 100) {
            throw new IllegalArgumentException("Username is too long.");
        }

        if (user.getEmail().isEmpty()
                || !user.getEmail().matches(
                        "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            throw new IllegalArgumentException(
                    "Enter a valid email address.");
        }

        if (user.getEmail().length() > 254) {
            throw new IllegalArgumentException("Email is too long.");
        }

        if (user.getPhone().length() > 30) {
            throw new IllegalArgumentException("Phone number is too long.");
        }

        if (user.getAddress().length() > 1000) {
            throw new IllegalArgumentException("Address is too long.");
        }

        if (requirePassword && password.isEmpty()) {
            throw new IllegalArgumentException("Password is required.");
        }

        if (!password.isEmpty() && password.length() < 8) {
            throw new IllegalArgumentException(
                    "Password must contain at least 8 characters.");
        }

        if (password.length() > 200) {
            throw new IllegalArgumentException("Password is too long.");
        }
    }

    private int parseUserId(String value) {
        try {
            int userId = Integer.parseInt(trimToEmpty(value));

            if (userId <= 0) {
                throw new IllegalArgumentException("Invalid user ID.");
            }

            return userId;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid user ID.", e);
        }
    }

    private int parseSessionUserId(HttpSession session) {
        Object value = session.getAttribute("userId");

        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Invalid logged-in user session.", e);
        }
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }

        Object userId = session.getAttribute("userId");
        Object roleObject = session.getAttribute("role");

        if (userId == null || roleObject == null) {
            return false;
        }

        try {
            if (Integer.parseInt(String.valueOf(userId)) <= 0) {
                return false;
            }
        } catch (NumberFormatException e) {
            return false;
        }

        return ADMIN_ROLE.equalsIgnoreCase(
                String.valueOf(roleObject).trim());
    }

    private boolean isValidRoleFilter(String roleFilter) {
        for (String validRole : VALID_ROLES) {
            if (validRole.equals(roleFilter)) {
                return true;
            }
        }

        return false;
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String safeLower(String value) {
        return trimToEmpty(value).toLowerCase(Locale.ROOT);
    }
}
