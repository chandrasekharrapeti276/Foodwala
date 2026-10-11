
package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO1.OrderDAO;
import com.tap.module.Order;
import com.tap.module.OrderItem;
import com.tap.util.DBconnection;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public int createOrder(
            Order order,
            List<OrderItem> orderItems) throws Exception {

        if (order == null) {
            throw new IllegalArgumentException(
                    "Order cannot be null.");
        }

        if (orderItems == null || orderItems.isEmpty()) {
            throw new IllegalArgumentException(
                    "Order must contain at least one item.");
        }

        String orderSql =
                "INSERT INTO orders " +
                "(userId, deliveryName, deliveryPhone, " +
                "deliveryAddress, totalAmount, status, paymentMode) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        // Use order_item consistently for all order-item operations.
        String itemSql =
                "INSERT INTO order_item " +
                "(orderId, menuId, quantity, itemTotal) " +
                "VALUES (?, ?, ?, ?)";

        try (Connection connection = DBconnection.getConnection()) {

            if (connection == null) {
                throw new SQLException(
                        "Unable to connect to the database.");
            }

            connection.setAutoCommit(false);

            try {
                int orderId;

                // Save the main order.
                try (PreparedStatement orderStatement =
                             connection.prepareStatement(
                                     orderSql,
                                     Statement.RETURN_GENERATED_KEYS)) {

                    orderStatement.setInt(1, order.getUserId());
                    orderStatement.setString(2, order.getDeliveryName());
                    orderStatement.setString(3, order.getDeliveryPhone());
                    orderStatement.setString(4, order.getDeliveryAddress());
                    orderStatement.setDouble(5, order.getTotalAmount());
                    orderStatement.setString(6, order.getStatus());
                    orderStatement.setString(7, order.getPaymentMode());

                    int affectedRows = orderStatement.executeUpdate();

                    if (affectedRows == 0) {
                        throw new SQLException(
                                "Creating order failed.");
                    }

                    try (ResultSet keys =
                                 orderStatement.getGeneratedKeys()) {

                        if (!keys.next()) {
                            throw new SQLException(
                                    "Order ID was not generated.");
                        }

                        orderId = keys.getInt(1);
                    }
                }

                // Save all items for this order.
                try (PreparedStatement itemStatement =
                             connection.prepareStatement(itemSql)) {

                    int itemCount = 0;

                    for (OrderItem item : orderItems) {

                        if (item == null) {
                            continue;
                        }

                        if (item.getMenuId() <= 0
                                || item.getQuantity() <= 0
                                || item.getItemTotal() < 0) {

                            throw new SQLException(
                                    "Invalid order item.");
                        }

                        itemStatement.setInt(1, orderId);
                        itemStatement.setInt(2, item.getMenuId());
                        itemStatement.setInt(3, item.getQuantity());
                        itemStatement.setDouble(4, item.getItemTotal());

                        itemStatement.addBatch();
                        itemCount++;
                    }

                    if (itemCount == 0) {
                        throw new SQLException(
                                "No valid order items were provided.");
                    }

                    itemStatement.executeBatch();
                }

                connection.commit();
                order.setOrderId(orderId);

                return orderId;

            } catch (Exception e) {

                try {
                    connection.rollback();
                } catch (SQLException rollbackException) {
                    e.addSuppressed(rollbackException);
                }

                throw e;

            } finally {

                try {
                    connection.setAutoCommit(true);
                } catch (SQLException ignored) {
                    // The connection is closed automatically.
                }
            }
        }
    }

    @Override
    public Order getOrder(int orderId) throws Exception {

        String sql =
                "SELECT orderId, userId, deliveryName, deliveryPhone, " +
                "deliveryAddress, totalAmount, status, orderDate, paymentMode " +
                "FROM orders WHERE orderId = ?";

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, orderId);

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {
                    return mapOrder(rs);
                }
            }
        }

        return null;
    }

    @Override
    public List<Order> getAllOrders() throws Exception {

        List<Order> orders = new ArrayList<>();

        String sql =
                "SELECT orderId, userId, deliveryName, deliveryPhone, " +
                "deliveryAddress, totalAmount, status, orderDate, paymentMode " +
                "FROM orders ORDER BY orderDate DESC";

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                orders.add(mapOrder(rs));
            }
        }

        return orders;
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) throws Exception {

        List<Order> orders = new ArrayList<>();

        String sql =
                "SELECT orderId, userId, deliveryName, deliveryPhone, " +
                "deliveryAddress, totalAmount, status, orderDate, paymentMode " +
                "FROM orders WHERE userId = ? ORDER BY orderDate DESC";

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    orders.add(mapOrder(rs));
                }
            }
        }

        return orders;
    }

    @Override
    public List<OrderItem> getOrderItems(int orderId) throws Exception {

        List<OrderItem> items = new ArrayList<>();

        String sql =
                "SELECT orderItemId, orderId, menuId, quantity, itemTotal " +
                "FROM order_item WHERE orderId = ? ORDER BY orderItemId";

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, orderId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {

                    OrderItem item = new OrderItem();

                    item.setOrderItemId(rs.getInt("orderItemId"));
                    item.setOrderId(rs.getInt("orderId"));
                    item.setMenuId(rs.getInt("menuId"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setItemTotal(rs.getDouble("itemTotal"));

                    items.add(item);
                }
            }
        }

        return items;
    }

    @Override
    public void updateOrderStatus(int orderId, String status)
            throws Exception {

        String sql =
                "UPDATE orders SET status = ? WHERE orderId = ?";

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, orderId);

            int affectedRows = statement.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException(
                        "Order not found: " + orderId);
            }
        }
    }

    private Order mapOrder(ResultSet rs) throws SQLException {

        Order order = new Order();

        order.setOrderId(rs.getInt("orderId"));
        order.setUserId(rs.getInt("userId"));
        order.setDeliveryName(rs.getString("deliveryName"));
        order.setDeliveryPhone(rs.getString("deliveryPhone"));
        order.setDeliveryAddress(rs.getString("deliveryAddress"));
        order.setTotalAmount(rs.getDouble("totalAmount"));
        order.setStatus(rs.getString("status"));
        order.setOrderDate(rs.getTimestamp("orderDate"));
        order.setPaymentMode(rs.getString("paymentMode"));

        return order;
    }
}
