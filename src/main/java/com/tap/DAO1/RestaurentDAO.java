
package com.tap.DAO1;

import java.util.List;

import com.tap.module.Restaurent;

public interface RestaurentDAO {

    // Add a new restaurant
    void addRestaurent(Restaurent restaurent)
            throws Exception;

    // Get one restaurant by restaurant ID
    Restaurent getRestaurent(int restaurentId)
            throws Exception;

    // Update an existing restaurant
    void updateRestaurent(Restaurent restaurent)
            throws Exception;

    // Delete a restaurant by restaurant ID
    void deleteRestaurent(int restaurentId)
            throws Exception;

    // Get active restaurants for the customer-facing restaurant page
    List<Restaurent> getAllRestaurents()
            throws Exception;

    // Get both active and inactive restaurants for the admin page
    List<Restaurent> getAllRestaurentsForAdmin()
            throws Exception;
}
