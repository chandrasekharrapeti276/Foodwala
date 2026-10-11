
package com.tap.DAO1;

import java.util.List;

import com.tap.module.User;

public interface UserDAO {

    /**
     * Authenticate a user using username and password.
     */
    User login(String username, String password) throws Exception;

    /**
     * Retrieve a user by their ID.
     */
    User getUser(int userId) throws Exception;

    /**
     * Retrieve all users for Admin User Management.
     */
    List<User> getAllUsers() throws Exception;

    /**
     * Add a new user.
     */
    void addUser(User user) throws Exception;

    /**
     * Update an existing user's details.
     */
    void updateUser(User user) throws Exception;

    /**
     * Delete a user by their ID.
     */
    void deleteUser(int userId) throws Exception;
}
