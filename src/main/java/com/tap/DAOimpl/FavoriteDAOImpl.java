package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO1.FavoriteDAO;
import com.tap.module.Favorite;
import com.tap.util.DBconnection;

public class FavoriteDAOImpl implements FavoriteDAO {

    /*
     * ============================================================
     * CHECK WHETHER RESTAURANT IS ALREADY FAVORITED
     * ============================================================
     */
    @Override
    public boolean isFavorite(
            int userId,
            int restaurentId) throws Exception {

        String sql =
                "SELECT favoriteId " +
                "FROM favorites " +
                "WHERE userId = ? " +
                "AND restaurentId = ? " +
                "LIMIT 1";

        try (
                Connection connection =
                        DBconnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, userId);
            statement.setInt(2, restaurentId);

            try (
                    ResultSet resultSet =
                            statement.executeQuery()
            ) {

                return resultSet.next();
            }
        }
    }

    /*
     * ============================================================
     * ADD FAVORITE
     * ============================================================
     */
    @Override
    public boolean addFavorite(
            int userId,
            int restaurentId) throws Exception {

        /*
         * Basic validation.
         */
        if (userId <= 0 || restaurentId <= 0) {
            return false;
        }

        /*
         * Prevent duplicate favorites.
         */
        if (isFavorite(userId, restaurentId)) {
            return true;
        }

        /*
         * Make sure the restaurant actually exists.
         */
        String restaurantCheckSql =
                "SELECT restaurentId " +
                "FROM restaurent " +
                "WHERE restaurentId = ? " +
                "LIMIT 1";

        try (
                Connection connection =
                        DBconnection.getConnection();

                PreparedStatement checkStatement =
                        connection.prepareStatement(
                                restaurantCheckSql
                        )
        ) {

            checkStatement.setInt(1, restaurentId);

            try (
                    ResultSet resultSet =
                            checkStatement.executeQuery()
            ) {

                if (!resultSet.next()) {
                    return false;
                }
            }
        }

        /*
         * Insert favorite into database.
         */
        String insertSql =
                "INSERT INTO favorites " +
                "(userId, restaurentId) " +
                "VALUES (?, ?)";

        try (
                Connection connection =
                        DBconnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(insertSql)
        ) {

            statement.setInt(1, userId);
            statement.setInt(2, restaurentId);

            int rows =
                    statement.executeUpdate();

            return rows > 0;
        }
    }

    /*
     * ============================================================
     * REMOVE FAVORITE
     * ============================================================
     */
    @Override
    public boolean removeFavorite(
            int userId,
            int restaurentId) throws Exception {

        if (userId <= 0 || restaurentId <= 0) {
            return false;
        }

        String sql =
                "DELETE FROM favorites " +
                "WHERE userId = ? " +
                "AND restaurentId = ?";

        try (
                Connection connection =
                        DBconnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, userId);
            statement.setInt(2, restaurentId);

            int rows =
                    statement.executeUpdate();

            return rows > 0;
        }
    }

    /*
     * ============================================================
     * GET ALL FAVORITES FOR A USER
     * ============================================================
     */
    @Override
    public List<Favorite> getFavoritesByUserId(
            int userId) throws Exception {

        List<Favorite> favorites =
                new ArrayList<>();

        if (userId <= 0) {
            return favorites;
        }

        String sql =
                "SELECT " +
                "f.favoriteId, " +
                "f.userId, " +
                "f.restaurentId, " +
                "f.createdAt, " +
                "r.name, " +
                "r.cuisineType, " +
                "r.deliveryTime, " +
                "r.address, " +
                "r.rating, " +
                "r.discountPercent, " +
                "r.imagePath " +
                "FROM favorites f " +
                "INNER JOIN restaurent r " +
                "ON f.restaurentId = r.restaurentId " +
                "WHERE f.userId = ? " +
                "ORDER BY f.createdAt DESC";

        try (
                Connection connection =
                        DBconnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, userId);

            try (
                    ResultSet resultSet =
                            statement.executeQuery()
            ) {

                while (resultSet.next()) {

                    Favorite favorite =
                            new Favorite();

                    /*
                     * Favorite table data.
                     */
                    favorite.setFavoriteId(
                            resultSet.getInt(
                                    "favoriteId"
                            )
                    );

                    favorite.setUserId(
                            resultSet.getInt(
                                    "userId"
                            )
                    );

                    favorite.setRestaurentId(
                            resultSet.getInt(
                                    "restaurentId"
                            )
                    );

                    favorite.setCreatedAt(
                            resultSet.getTimestamp(
                                    "createdAt"
                            )
                    );

                    /*
                     * Restaurant data.
                     */
                    favorite.setRestaurentName(
                            resultSet.getString(
                                    "name"
                            )
                    );

                    favorite.setCuisineType(
                            resultSet.getString(
                                    "cuisineType"
                            )
                    );

                    favorite.setDeliveryTime(
                            resultSet.getString(
                                    "deliveryTime"
                            )
                    );

                    favorite.setAddress(
                            resultSet.getString(
                                    "address"
                            )
                    );

                    favorite.setRating(
                            resultSet.getDouble(
                                    "rating"
                            )
                    );

                    favorite.setDiscountPercent(
                            resultSet.getDouble(
                                    "discountPercent"
                            )
                    );

                    favorite.setImagePath(
                            resultSet.getString(
                                    "imagePath"
                            )
                    );

                    favorites.add(favorite);
                }
            }
        }

        return favorites;
    }
}