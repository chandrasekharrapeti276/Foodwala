package com.tap.DAO1;

import java.util.List;

import com.tap.module.Menu;

public interface MenuDAO {

    // Get all menu items for a restaurant
    List<Menu> getMenusByRestaurentId(int restaurentId)
            throws Exception;

    // Get one menu item by menu ID
    Menu getMenu(int menuId)
            throws Exception;

    // Add a new menu item
    void addMenu(Menu menu)
            throws Exception;

    // Update an existing menu item
    void updateMenu(Menu menu)
            throws Exception;

    // Delete a menu item
    void deleteMenu(int menuId)
            throws Exception;
}