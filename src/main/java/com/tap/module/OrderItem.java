package com.tap.module;

public class OrderItem {

    private int orderItemId;
    private int orderId;
    private int menuId;
    private int quantity;
    private double itemTotal;

    // =========================================
    // DEFAULT CONSTRUCTOR
    // =========================================

    public OrderItem() {
    }

    // =========================================
    // PARAMETERIZED CONSTRUCTOR
    // =========================================

    public OrderItem(
            int orderItemId,
            int orderId,
            int menuId,
            int quantity,
            double itemTotal) {

        this.orderItemId = orderItemId;
        this.orderId = orderId;
        this.menuId = menuId;
        this.quantity = quantity;
        this.itemTotal = itemTotal;
    }

    // =========================================
    // ORDER ITEM ID
    // =========================================

    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    // =========================================
    // ORDER ID
    // =========================================

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    // =========================================
    // MENU ID
    // =========================================

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    // =========================================
    // QUANTITY
    // =========================================

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    // =========================================
    // ITEM TOTAL
    // =========================================

    public double getItemTotal() {
        return itemTotal;
    }

    public void setItemTotal(double itemTotal) {
        this.itemTotal = itemTotal;
    }

    // =========================================
    // TO STRING
    // =========================================

    @Override
    public String toString() {
        return "OrderItem{" +
                "orderItemId=" + orderItemId +
                ", orderId=" + orderId +
                ", menuId=" + menuId +
                ", quantity=" + quantity +
                ", itemTotal=" + itemTotal +
                '}';
    }
}