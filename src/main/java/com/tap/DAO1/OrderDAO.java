package com.tap.DAO1;

import java.util.List;

import com.tap.module.Order;
import com.tap.module.OrderItem;

public interface OrderDAO {

    // Create a new order and its order items
    int createOrder(
            Order order,
            List<OrderItem> orderItems)
            throws Exception;

    // Get one order by order ID
    Order getOrder(
            int orderId)
            throws Exception;

    // Get all orders
    List<Order> getAllOrders()
            throws Exception;

    // Get all orders belonging to a user
    List<Order> getOrdersByUserId(
            int userId)
            throws Exception;

    // Get all items belonging to an order
    List<OrderItem> getOrderItems(
            int orderId)
            throws Exception;

    // Update order status
    void updateOrderStatus(
            int orderId,
            String status)
            throws Exception;
}