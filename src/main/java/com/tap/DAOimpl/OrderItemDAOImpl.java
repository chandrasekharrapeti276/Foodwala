package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO1.OrderItemDAO;
import com.tap.module.OrderItem;
import com.tap.util.DBconnection;

public class OrderItemDAOImpl implements OrderItemDAO {

    // =========================================================
    // SQL QUERIES
    // =========================================================

    private static final String INSERT_ORDER_ITEM =
            "INSERT INTO orderItem " +
            "(orderId, menuId, quantity, itemTotal) " +
            "VALUES (?, ?, ?, ?)";

    private static final String SELECT_ORDER_ITEM_BY_ID =
            "SELECT orderItemId, orderId, menuId, quantity, itemTotal " +
            "FROM orderItem " +
            "WHERE orderItemId = ?";

    private static final String UPDATE_ORDER_ITEM =
            "UPDATE orderItem SET " +
            "orderId = ?, " +
            "menuId = ?, " +
            "quantity = ?, " +
            "itemTotal = ? " +
            "WHERE orderItemId = ?";

    private static final String DELETE_ORDER_ITEM =
            "DELETE FROM orderItem " +
            "WHERE orderItemId = ?";

    private static final String SELECT_ALL_ORDER_ITEMS =
            "SELECT orderItemId, orderId, menuId, quantity, itemTotal " +
            "FROM orderItem " +
            "ORDER BY orderItemId ASC";

    private static final String SELECT_ORDER_ITEMS_BY_ORDER_ID =
            "SELECT orderItemId, orderId, menuId, quantity, itemTotal " +
            "FROM orderItem " +
            "WHERE orderId = ? " +
            "ORDER BY orderItemId ASC";


    // =========================================================
    // ADD ORDER ITEM
    // =========================================================

    @Override
    public void addOrderItem(OrderItem orderItem) {

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             INSERT_ORDER_ITEM)) {

            statement.setInt(
                    1,
                    orderItem.getOrderId()
            );

            statement.setInt(
                    2,
                    orderItem.getMenuId()
            );

            statement.setInt(
                    3,
                    orderItem.getQuantity()
            );

            statement.setDouble(
                    4,
                    orderItem.getItemTotal()
            );

            statement.executeUpdate();

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to add order item."
            );

            e.printStackTrace();
        }
    }


    // =========================================================
    // ADD ORDER ITEM USING EXISTING CONNECTION
    // Used during order transaction
    // =========================================================

    public boolean addOrderItem(
            Connection connection,
            OrderItem orderItem) {

        try (PreparedStatement statement =
                     connection.prepareStatement(
                             INSERT_ORDER_ITEM)) {

            statement.setInt(
                    1,
                    orderItem.getOrderId()
            );

            statement.setInt(
                    2,
                    orderItem.getMenuId()
            );

            statement.setInt(
                    3,
                    orderItem.getQuantity()
            );

            statement.setDouble(
                    4,
                    orderItem.getItemTotal()
            );

            int rowsInserted =
                    statement.executeUpdate();

            return rowsInserted > 0;

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to add order item "
                    + "using existing connection."
            );

            e.printStackTrace();

            return false;
        }
    }


    // =========================================================
    // GET ORDER ITEM BY ID
    // =========================================================

    @Override
    public OrderItem getOrderItem(
            int orderItemId) {

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ORDER_ITEM_BY_ID)) {

            statement.setInt(
                    1,
                    orderItemId
            );

            try (ResultSet rs =
                         statement.executeQuery()) {

                if (rs.next()) {

                    return mapOrderItem(rs);
                }
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to get order item."
            );

            e.printStackTrace();
        }

        return null;
    }


    // =========================================================
    // UPDATE ORDER ITEM
    // =========================================================

    @Override
    public void updateOrderItem(
            OrderItem orderItem) {

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             UPDATE_ORDER_ITEM)) {

            statement.setInt(
                    1,
                    orderItem.getOrderId()
            );

            statement.setInt(
                    2,
                    orderItem.getMenuId()
            );

            statement.setInt(
                    3,
                    orderItem.getQuantity()
            );

            statement.setDouble(
                    4,
                    orderItem.getItemTotal()
            );

            statement.setInt(
                    5,
                    orderItem.getOrderItemId()
            );

            statement.executeUpdate();

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to update order item."
            );

            e.printStackTrace();
        }
    }


    // =========================================================
    // DELETE ORDER ITEM
    // =========================================================

    @Override
    public void deleteOrderItem(
            int orderItemId) {

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             DELETE_ORDER_ITEM)) {

            statement.setInt(
                    1,
                    orderItemId
            );

            statement.executeUpdate();

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to delete order item."
            );

            e.printStackTrace();
        }
    }


    // =========================================================
    // GET ALL ORDER ITEMS
    // =========================================================

    @Override
    public List<OrderItem> getAllOrderItems() {

        List<OrderItem> orderItems =
                new ArrayList<>();

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ALL_ORDER_ITEMS);
             ResultSet rs =
                     statement.executeQuery()) {

            while (rs.next()) {

                orderItems.add(
                        mapOrderItem(rs)
                );
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to load all order items."
            );

            e.printStackTrace();
        }

        return orderItems;
    }


    // =========================================================
    // GET ORDER ITEMS BY ORDER ID
    // =========================================================

    @Override
    public List<OrderItem> getOrderItemsByOrderId(
            int orderId) {

        List<OrderItem> orderItems =
                new ArrayList<>();

        try (Connection connection =
                     DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ORDER_ITEMS_BY_ORDER_ID)) {

            statement.setInt(
                    1,
                    orderId
            );

            try (ResultSet rs =
                         statement.executeQuery()) {

                while (rs.next()) {

                    orderItems.add(
                            mapOrderItem(rs)
                    );
                }
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to load order items "
                    + "for order ID: "
                    + orderId
            );

            e.printStackTrace();
        }

        return orderItems;
    }


    // =========================================================
    // MAP RESULT SET TO ORDER ITEM
    // =========================================================

    private OrderItem mapOrderItem(
            ResultSet rs)
            throws SQLException {

        OrderItem orderItem =
                new OrderItem();

        orderItem.setOrderItemId(
                rs.getInt("orderItemId")
        );

        orderItem.setOrderId(
                rs.getInt("orderId")
        );

        orderItem.setMenuId(
                rs.getInt("menuId")
        );

        orderItem.setQuantity(
                rs.getInt("quantity")
        );

        orderItem.setItemTotal(
                rs.getDouble("itemTotal")
        );

        return orderItem;
    }
}