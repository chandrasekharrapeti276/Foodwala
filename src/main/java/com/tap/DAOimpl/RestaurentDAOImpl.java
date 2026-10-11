
package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.tap.DAO1.RestaurentDAO;
import com.tap.module.Restaurent;
import com.tap.util.DBconnection;

public class RestaurentDAOImpl implements RestaurentDAO {

    private Connection getConnection() throws SQLException {
        Connection connection = DBconnection.getConnection();

        if (connection == null) {
            throw new SQLException(
                "Database connection failed. Check DBconnection.java."
            );
        }

        return connection;
    }

    private void setAdminUserId(
            PreparedStatement statement,
            int parameterIndex,
            int adminUserId) throws SQLException {

        if (adminUserId > 0) {
            statement.setInt(parameterIndex, adminUserId);
        } else {
            statement.setNull(parameterIndex, Types.INTEGER);
        }
    }

    // ADD RESTAURANT
    @Override
    public void addRestaurent(Restaurent restaurent) throws Exception {

        if (restaurent == null) {
            throw new IllegalArgumentException(
                "Restaurant information is required."
            );
        }

        String sql =
            "INSERT INTO restaurent " +
            "(name, cuisineType, deliveryTime, address, adminUserId, " +
            "rating, discountPercent, isActive, imagePath) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setString(1, restaurent.getName());
            statement.setString(2, restaurent.getCuisineType());
            statement.setString(3, restaurent.getDeliveryTime());
            statement.setString(4, restaurent.getAddress());

            setAdminUserId(statement, 5, restaurent.getAdminUserId());

            statement.setDouble(6, restaurent.getRating());
            statement.setDouble(7, restaurent.getDiscountPercent());
            statement.setBoolean(8, restaurent.isActive());
            statement.setString(9, restaurent.getImagePath());

            statement.executeUpdate();
        }
    }

    // GET ONE RESTAURANT
    @Override
    public Restaurent getRestaurent(int restaurentId) throws Exception {

        String sql =
            "SELECT restaurentId, name, cuisineType, deliveryTime, " +
            "address, adminUserId, rating, discountPercent, " +
            "isActive, imagePath " +
            "FROM restaurent WHERE restaurentId = ?";

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setInt(1, restaurentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapRestaurant(resultSet);
                }
            }
        }

        return null;
    }

    // UPDATE RESTAURANT
    @Override
    public void updateRestaurent(Restaurent restaurent) throws Exception {

        if (restaurent == null) {
            throw new IllegalArgumentException(
                "Restaurant information is required."
            );
        }

        String sql =
            "UPDATE restaurent SET name = ?, cuisineType = ?, " +
            "deliveryTime = ?, address = ?, adminUserId = ?, " +
            "rating = ?, discountPercent = ?, isActive = ?, " +
            "imagePath = ? WHERE restaurentId = ?";

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setString(1, restaurent.getName());
            statement.setString(2, restaurent.getCuisineType());
            statement.setString(3, restaurent.getDeliveryTime());
            statement.setString(4, restaurent.getAddress());

            setAdminUserId(statement, 5, restaurent.getAdminUserId());

            statement.setDouble(6, restaurent.getRating());
            statement.setDouble(7, restaurent.getDiscountPercent());
            statement.setBoolean(8, restaurent.isActive());
            statement.setString(9, restaurent.getImagePath());
            statement.setInt(10, restaurent.getRestaurentId());

            statement.executeUpdate();
        }
    }

    // DELETE RESTAURANT
    @Override
    public void deleteRestaurent(int restaurentId) throws Exception {

        String sql =
            "DELETE FROM restaurent WHERE restaurentId = ?";

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setInt(1, restaurentId);
            statement.executeUpdate();
        }
    }

    // GET ALL ACTIVE RESTAURANTS FOR CUSTOMERS
    @Override
    public List<Restaurent> getAllRestaurents() throws Exception {

        String sql =
            "SELECT restaurentId, name, cuisineType, deliveryTime, " +
            "address, adminUserId, rating, discountPercent, " +
            "isActive, imagePath " +
            "FROM restaurent " +
            "WHERE isActive = TRUE " +
            "ORDER BY restaurentId ASC";

        return getRestaurantsByQuery(sql);
    }

    // GET ALL RESTAURANTS FOR ADMIN, INCLUDING INACTIVE ONES
    @Override
    public List<Restaurent> getAllRestaurentsForAdmin()
            throws Exception {

        String sql =
            "SELECT restaurentId, name, cuisineType, deliveryTime, " +
            "address, adminUserId, rating, discountPercent, " +
            "isActive, imagePath " +
            "FROM restaurent " +
            "ORDER BY restaurentId ASC";

        return getRestaurantsByQuery(sql);
    }

    // COMMON METHOD FOR LOADING RESTAURANTS
    private List<Restaurent> getRestaurantsByQuery(String sql)
            throws Exception {

        List<Restaurent> restaurants = new ArrayList<>();

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                restaurants.add(mapRestaurant(resultSet));
            }
        }

        return restaurants;
    }

    /*
     * GET SEARCHABLE MENU ITEM NAMES
     *
     * Returns:
     * restaurant ID -> searchable menu item names.
     */
    public Map<Integer, String> getMenuSearchTextForActiveRestaurants()
            throws Exception {

        Map<Integer, String> menuSearchText = new LinkedHashMap<>();

        String sql =
            "SELECT r.restaurentId, m.itemName " +
            "FROM restaurent r " +
            "INNER JOIN menu m " +
            "ON m.restaurentId = r.restaurentId " +
            "WHERE r.isActive = TRUE " +
            "AND m.isAvailable = TRUE " +
            "AND m.itemName IS NOT NULL " +
            "ORDER BY r.restaurentId, m.itemName";

        try (Connection connection = getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                int restaurantId =
                    resultSet.getInt("restaurentId");

                String itemName =
                    resultSet.getString("itemName");

                if (itemName == null || itemName.trim().isEmpty()) {
                    continue;
                }

                String existing = menuSearchText.get(restaurantId);

                if (existing == null) {
                    menuSearchText.put(
                        restaurantId,
                        itemName.trim()
                    );
                } else {
                    menuSearchText.put(
                        restaurantId,
                        existing + " " + itemName.trim()
                    );
                }
            }
        }

        System.out.println(
            "[Foodwala] Restaurants with searchable menu items: " +
            menuSearchText.size()
        );

        return menuSearchText;
    }

    // MAP DATABASE ROW TO RESTAURENT OBJECT
    private Restaurent mapRestaurant(ResultSet resultSet)
            throws SQLException {

        Restaurent restaurent = new Restaurent();

        restaurent.setRestaurentId(
            resultSet.getInt("restaurentId")
        );

        restaurent.setName(
            resultSet.getString("name")
        );

        restaurent.setCuisineType(
            resultSet.getString("cuisineType")
        );

        restaurent.setDeliveryTime(
            resultSet.getString("deliveryTime")
        );

        restaurent.setAddress(
            resultSet.getString("address")
        );

        restaurent.setAdminUserId(
            resultSet.getInt("adminUserId")
        );

        restaurent.setRating(
            resultSet.getDouble("rating")
        );

        restaurent.setDiscountPercent(
            resultSet.getDouble("discountPercent")
        );

        restaurent.setActive(
            resultSet.getBoolean("isActive")
        );

        restaurent.setImagePath(
            resultSet.getString("imagePath")
        );

        return restaurent;
    }
}
