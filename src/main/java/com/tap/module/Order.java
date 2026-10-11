
package com.tap.module;

import java.sql.Timestamp;

public class Order {

    private int orderId;
    private int userId;

    private String deliveryName;
    private String deliveryPhone;
    private String deliveryAddress;

    private double totalAmount;
    private String status;
    private Timestamp orderDate;

    // Payment method selected during checkout
    private String paymentMode;

    public Order() {
    }

    public Order(
            int orderId,
            int userId,
            String deliveryName,
            String deliveryPhone,
            String deliveryAddress,
            double totalAmount,
            String status,
            Timestamp orderDate) {

        this.orderId = orderId;
        this.userId = userId;
        this.deliveryName = deliveryName;
        this.deliveryPhone = deliveryPhone;
        this.deliveryAddress = deliveryAddress;
        this.totalAmount = totalAmount;
        this.status = status;
        this.orderDate = orderDate;
    }

    public Order(
            int userId,
            String deliveryName,
            String deliveryPhone,
            String deliveryAddress,
            double totalAmount,
            String status,
            Timestamp orderDate) {

        this.userId = userId;
        this.deliveryName = deliveryName;
        this.deliveryPhone = deliveryPhone;
        this.deliveryAddress = deliveryAddress;
        this.totalAmount = totalAmount;
        this.status = status;
        this.orderDate = orderDate;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getDeliveryName() {
        return deliveryName;
    }

    public void setDeliveryName(String deliveryName) {
        this.deliveryName = deliveryName;
    }

    public String getDeliveryPhone() {
        return deliveryPhone;
    }

    public void setDeliveryPhone(String deliveryPhone) {
        this.deliveryPhone = deliveryPhone;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    // Payment mode getter and setter

    public String getPaymentMode() {
        return paymentMode;
    }

    public void setPaymentMode(String paymentMode) {
        this.paymentMode = paymentMode;
    }

    @Override
    public String toString() {
        return "Order{" +
                "orderId=" + orderId +
                ", userId=" + userId +
                ", deliveryName='" + deliveryName + '\'' +
                ", deliveryPhone='" + deliveryPhone + '\'' +
                ", deliveryAddress='" + deliveryAddress + '\'' +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                ", orderDate=" + orderDate +
                ", paymentMode='" + paymentMode + '\'' +
                '}';
    }
}
