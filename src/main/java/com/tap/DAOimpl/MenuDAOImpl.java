
package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO1.MenuDAO;
import com.tap.module.Menu;
import com.tap.util.DBconnection;

public class MenuDAOImpl implements MenuDAO {

    private static final String SELECT_BY_RESTAURANT =
        "SELECT menuId, restaurentId, itemName, description, " +
        "price, isAvailable, imagePath " +
        "FROM menu WHERE restaurentId = ? ORDER BY menuId ASC";

    private static final String SELECT_BY_ID =
        "SELECT menuId, restaurentId, itemName, description, " +
        "price, isAvailable, imagePath " +
        "FROM menu WHERE menuId = ?";

    private static final String INSERT_SQL =
        "INSERT INTO menu " +
        "(restaurentId, itemName, description, price, isAvailable, imagePath) " +
        "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String UPDATE_SQL =
        "UPDATE menu SET restaurentId = ?, itemName = ?, " +
        "description = ?, price = ?, isAvailable = ?, imagePath = ? " +
        "WHERE menuId = ?";

    private static final String DELETE_SQL =
        "DELETE FROM menu WHERE menuId = ?";

    private Connection getConnection() throws SQLException {
        Connection connection = DBconnection.getConnection();

        if (connection == null || connection.isClosed()) {
            throw new SQLException(
                "Database connection is unavailable. " +
                "Check DBconnection.java and MySQL."
            );
        }

        return connection;
    }

    @Override
    public List<Menu> getMenusByRestaurentId(int restaurentId)
            throws Exception {

        List<Menu> menus = new ArrayList<>();

        if (restaurentId <= 0) {
            return menus;
        }

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(SELECT_BY_RESTAURANT)) {

            statement.setInt(1, restaurentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    menus.add(mapMenu(resultSet));
                }
            }

        } catch (SQLException e) {
            throw new SQLException(
                "Failed to load menu items for restaurentId " +
                restaurentId + ". Check the menu table and column names.",
                e
            );
        }

        return menus;
    }

    @Override
    public Menu getMenu(int menuId) throws Exception {

        if (menuId <= 0) {
            return null;
        }

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(SELECT_BY_ID)) {

            statement.setInt(1, menuId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapMenu(resultSet);
                }
            }

        } catch (SQLException e) {
            throw new SQLException(
                "Failed to retrieve menu item with ID " + menuId + ".",
                e
            );
        }

        return null;
    }

    @Override
    public void addMenu(Menu menu) throws Exception {

        validateMenu(menu);

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(INSERT_SQL)) {

            statement.setInt(1, menu.getRestaurentId());
            statement.setString(2, menu.getItemName().trim());
            statement.setString(3, menu.getDescription());
            statement.setDouble(4, menu.getPrice());
            statement.setBoolean(5, menu.isAvailable());
            statement.setString(6, normalizeImagePath(menu.getImagePath()));

            int rows = statement.executeUpdate();

            if (rows == 0) {
                throw new SQLException("The menu item was not inserted.");
            }

        } catch (SQLException e) {
            throw new SQLException(
                "Failed to add menu item. Verify the restaurant ID " +
                "and the menu table constraints.",
                e
            );
        }
    }

    @Override
    public void updateMenu(Menu menu) throws Exception {

        if (menu == null || menu.getMenuId() <= 0) {
            throw new IllegalArgumentException(
                "A valid menu item and menu ID are required."
            );
        }

        validateMenu(menu);

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(UPDATE_SQL)) {

            statement.setInt(1, menu.getRestaurentId());
            statement.setString(2, menu.getItemName().trim());
            statement.setString(3, menu.getDescription());
            statement.setDouble(4, menu.getPrice());
            statement.setBoolean(5, menu.isAvailable());
            statement.setString(6, normalizeImagePath(menu.getImagePath()));
            statement.setInt(7, menu.getMenuId());

            int rows = statement.executeUpdate();

            if (rows == 0) {
                throw new SQLException(
                    "No menu item was updated. Menu ID " +
                    menu.getMenuId() + " may not exist."
                );
            }

        } catch (SQLException e) {
            throw new SQLException(
                "Failed to update menu item with ID " +
                menu.getMenuId() + ".",
                e
            );
        }
    }

    @Override
    public void deleteMenu(int menuId) throws Exception {

        if (menuId <= 0) {
            throw new IllegalArgumentException(
                "A valid menu ID is required."
            );
        }

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(DELETE_SQL)) {

            statement.setInt(1, menuId);

            int rows = statement.executeUpdate();

            if (rows == 0) {
                throw new SQLException(
                    "No menu item found with ID " + menuId + "."
                );
            }

        } catch (SQLException e) {
            throw new SQLException(
                "Failed to delete menu item with ID " + menuId +
                ". Check whether an existing order references this item.",
                e
            );
        }
    }

    private void validateMenu(Menu menu) {

        if (menu == null) {
            throw new IllegalArgumentException(
                "Menu item is required."
            );
        }

        if (menu.getRestaurentId() <= 0) {
            throw new IllegalArgumentException(
                "A valid restaurant ID is required."
            );
        }

        if (menu.getItemName() == null ||
                menu.getItemName().trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Food item name is required."
            );
        }

        if (!Double.isFinite(menu.getPrice()) || menu.getPrice() < 0) {
            throw new IllegalArgumentException(
                "Price must be a valid non-negative number."
            );
        }
    }

    private String normalizeImagePath(String imagePath) {

        if (imagePath == null || imagePath.trim().isEmpty()) {
            return null;
        }

        return imagePath.trim();
    }

    private Menu mapMenu(ResultSet resultSet) throws SQLException {

        Menu menu = new Menu();

        menu.setMenuId(resultSet.getInt("menuId"));
        menu.setRestaurentId(resultSet.getInt("restaurentId"));
        menu.setItemName(resultSet.getString("itemName"));
        menu.setDescription(resultSet.getString("description"));
        menu.setPrice(resultSet.getDouble("price"));
        menu.setAvailable(resultSet.getBoolean("isAvailable"));
        menu.setImagePath(resultSet.getString("imagePath"));

        return menu;
    }
}