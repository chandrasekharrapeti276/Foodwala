package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO1.UserDAO;
import com.tap.module.User;
import com.tap.util.DBconnection;

public class UserDAOImpl implements UserDAO {

    // =========================================================
    // LOGIN
    // =========================================================

    @Override
    public User login(
            String username,
            String password) throws Exception {

        String sql =
                "SELECT userId, username, password, email, " +
                "phone, address, role " +
                "FROM users " +
                "WHERE username = ? AND password = ?";

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, username);
            statement.setString(2, password);

            try (ResultSet rs =
                         statement.executeQuery()) {

                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }


    // =========================================================
    // GET USER BY ID
    // =========================================================

    @Override
    public User getUser(int userId)
            throws Exception {

        String sql =
                "SELECT userId, username, password, email, " +
                "phone, address, role " +
                "FROM users " +
                "WHERE userId = ?";

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet rs =
                         statement.executeQuery()) {

                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }


    // =========================================================
    // GET ALL USERS
    // =========================================================

    @Override
    public List<User> getAllUsers()
            throws Exception {

        List<User> users =
                new ArrayList<>();

        String sql =
                "SELECT userId, username, password, email, " +
                "phone, address, role " +
                "FROM users " +
                "ORDER BY userId ASC";

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet rs =
                     statement.executeQuery()) {

            while (rs.next()) {

                users.add(
                        mapUser(rs)
                );
            }
        }

        return users;
    }


    // =========================================================
    // ADD USER
    // =========================================================

    @Override
    public void addUser(User user)
            throws Exception {

        String sql =
                "INSERT INTO users " +
                "(username, password, email, phone, address, role) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(
                    1,
                    user.getUsername()
            );

            statement.setString(
                    2,
                    user.getPassword()
            );

            statement.setString(
                    3,
                    user.getEmail()
            );

            statement.setString(
                    4,
                    user.getPhone()
            );

            statement.setString(
                    5,
                    user.getAddress()
            );

            statement.setString(
                    6,
                    user.getRole()
            );

            statement.executeUpdate();
        }
    }


    // =========================================================
    // UPDATE USER
    // =========================================================

    @Override
    public void updateUser(User user)
            throws Exception {

        String sql =
                "UPDATE users SET " +
                "username = ?, " +
                "password = ?, " +
                "email = ?, " +
                "phone = ?, " +
                "address = ?, " +
                "role = ? " +
                "WHERE userId = ?";

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(
                    1,
                    user.getUsername()
            );

            statement.setString(
                    2,
                    user.getPassword()
            );

            statement.setString(
                    3,
                    user.getEmail()
            );

            statement.setString(
                    4,
                    user.getPhone()
            );

            statement.setString(
                    5,
                    user.getAddress()
            );

            statement.setString(
                    6,
                    user.getRole()
            );

            statement.setInt(
                    7,
                    user.getUserId()
            );

            statement.executeUpdate();
        }
    }


    // =========================================================
    // DELETE USER
    // =========================================================

    @Override
    public void deleteUser(int userId)
            throws Exception {

        String sql =
                "DELETE FROM users " +
                "WHERE userId = ?";

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(
                    1,
                    userId
            );

            statement.executeUpdate();
        }
    }


    // =========================================================
    // MAP RESULT SET TO USER
    // =========================================================

    private User mapUser(ResultSet rs)
            throws Exception {

        User user =
                new User();

        user.setUserId(
                rs.getInt("userId")
        );

        user.setUsername(
                rs.getString("username")
        );

        user.setPassword(
                rs.getString("password")
        );

        user.setEmail(
                rs.getString("email")
        );

        user.setPhone(
                rs.getString("phone")
        );

        user.setAddress(
                rs.getString("address")
        );

        user.setRole(
                rs.getString("role")
        );

        return user;
    }
}