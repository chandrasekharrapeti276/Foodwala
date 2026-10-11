package com.tap.DAO1;

import java.sql.Connection;
import java.util.List;

import com.tap.module.OrderItem;

public interface OrderItemDAO {

    // Add one order item
    void addOrderItem(OrderItem orderItem);

    // Add one order item using an existing connection.
    // Used during the order transaction.
    boolean addOrderItem(
            Connection connection,
            OrderItem orderItem
    );

    // Get one order item by ID
    OrderItem getOrderItem(int orderItemId);

    // Update an existing order item
    void updateOrderItem(OrderItem orderItem);

    // Delete an order item
    void deleteOrderItem(int orderItemId);

    // Get all order items
    List<OrderItem> getAllOrderItems();

    // Get all items belonging to one order
    List<OrderItem> getOrderItemsByOrderId(
            int orderId
    );
}