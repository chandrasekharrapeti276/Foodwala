package com.tap.DAO1;

import java.util.List;

import com.tap.module.Favorite;

public interface FavoriteDAO {

    /*
     * Check whether a restaurant is already
     * present in the user's favorites.
     */
    boolean isFavorite(
            int userId,
            int restaurentId) throws Exception;

    /*
     * Add a restaurant to the user's favorites.
     */
    boolean addFavorite(
            int userId,
            int restaurentId) throws Exception;

    /*
     * Remove a restaurant from the user's favorites.
     */
    boolean removeFavorite(
            int userId,
            int restaurentId) throws Exception;

    /*
     * Get all favorite restaurants for a user.
     */
    List<Favorite> getFavoritesByUserId(
            int userId) throws Exception;
}