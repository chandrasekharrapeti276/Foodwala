package com.tap.module;

public class CartItem {

    private int menuId;
    private String itemName;
    private double price;
    private int quantity;

    // =========================================
    // DEFAULT CONSTRUCTOR
    // =========================================

    public CartItem() {
    }

    // =========================================
    // PARAMETERIZED CONSTRUCTOR
    // =========================================

    public CartItem(
            int menuId,
            String itemName,
            double price,
            int quantity) {

        this.menuId = menuId;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
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
    // GET QUANTITY
    // =========================================

    public int getQuantity() {
        return quantity;
    }

    // =========================================
    // SET QUANTITY
    // =========================================

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    // =========================================
    // GET TOTAL
    // =========================================

    public double getTotal() {
        return price * quantity;
    }

    // =========================================
    // TO STRING
    // =========================================

    @Override
    public String toString() {
        return "CartItem{" +
                "menuId=" + menuId +
                ", itemName='" + itemName + '\'' +
                ", price=" + price +
                ", quantity=" + quantity +
                ", total=" + getTotal() +
                '}';
    }
}