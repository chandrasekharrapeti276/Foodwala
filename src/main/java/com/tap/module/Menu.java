package com.tap.module;

public class Menu {

    private int menuId;
    private int restaurentId;
    private String itemName;
    private String description;
    private double price;
    private boolean isAvailable;
    private String imagePath;

    // =========================================
    // DEFAULT CONSTRUCTOR
    // =========================================

    public Menu() {
    }

    // =========================================
    // PARAMETERIZED CONSTRUCTOR
    // =========================================

    public Menu(
            int menuId,
            int restaurentId,
            String itemName,
            String description,
            double price,
            boolean isAvailable,
            String imagePath) {

        this.menuId = menuId;
        this.restaurentId = restaurentId;
        this.itemName = itemName;
        this.description = description;
        this.price = price;
        this.isAvailable = isAvailable;
        this.imagePath = imagePath;
    }

    // =========================================
    // GET MENU ID
    // =========================================

    public int getMenuId() {
        return menuId;
    }

    // =========================================
    // SET MENU ID
    // =========================================

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    // =========================================
    // GET RESTAURENT ID
    // =========================================

    public int getRestaurentId() {
        return restaurentId;
    }

    // =========================================
    // SET RESTAURENT ID
    // =========================================

    public void setRestaurentId(int restaurentId) {
        this.restaurentId = restaurentId;
    }

    // =========================================
    // GET ITEM NAME
    // =========================================

    public String getItemName() {
        return itemName;
    }

    // =========================================
    // SET ITEM NAME
    // =========================================

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    // =========================================
    // GET DESCRIPTION
    // =========================================

    public String getDescription() {
        return description;
    }

    // =========================================
    // SET DESCRIPTION
    // =========================================

    public void setDescription(String description) {
        this.description = description;
    }

    // =========================================
    // GET PRICE
    // =========================================

    public double getPrice() {
        return price;
    }

    // =========================================
    // SET PRICE
    // =========================================

    public void setPrice(double price) {
        this.price = price;
    }

    // =========================================
    // CHECK AVAILABILITY
    // =========================================

    public boolean isAvailable() {
        return isAvailable;
    }

    // =========================================
    // SET AVAILABILITY
    // =========================================

    public void setAvailable(boolean available) {
        this.isAvailable = available;
    }

    // =========================================
    // GET IMAGE PATH
    // =========================================

    public String getImagePath() {
        return imagePath;
    }

    // =========================================
    // SET IMAGE PATH
    // =========================================

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    // =========================================
    // TO STRING
    // =========================================

    @Override
    public String toString() {
        return "Menu{" +
                "menuId=" + menuId +
                ", restaurentId=" + restaurentId +
                ", itemName='" + itemName + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", isAvailable=" + isAvailable +
                ", imagePath='" + imagePath + '\'' +
                '}';
    }
}