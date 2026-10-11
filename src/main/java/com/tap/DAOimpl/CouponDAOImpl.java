package com.tap.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO1.CouponDAO;
import com.tap.module.Coupon;
import com.tap.util.DBconnection;

public class CouponDAOImpl implements CouponDAO {

    // =========================================================
    // SQL QUERIES
    // =========================================================

    private static final String ADD_COUPON =
            "INSERT INTO coupons " +
            "(couponCode, description, discountType, discountValue, " +
            "minimumOrderAmount, maximumDiscount, isActive, expiryDate) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String GET_COUPON =
            "SELECT couponId, couponCode, description, discountType, " +
            "discountValue, minimumOrderAmount, maximumDiscount, " +
            "isActive, expiryDate, createdAt " +
            "FROM coupons " +
            "WHERE couponId = ?";

    private static final String GET_COUPON_BY_CODE =
            "SELECT couponId, couponCode, description, discountType, " +
            "discountValue, minimumOrderAmount, maximumDiscount, " +
            "isActive, expiryDate, createdAt " +
            "FROM coupons " +
            "WHERE UPPER(couponCode) = UPPER(?)";

    private static final String UPDATE_COUPON =
            "UPDATE coupons SET " +
            "couponCode = ?, " +
            "description = ?, " +
            "discountType = ?, " +
            "discountValue = ?, " +
            "minimumOrderAmount = ?, " +
            "maximumDiscount = ?, " +
            "isActive = ?, " +
            "expiryDate = ? " +
            "WHERE couponId = ?";

    private static final String DELETE_COUPON =
            "DELETE FROM coupons " +
            "WHERE couponId = ?";

    private static final String GET_ALL_COUPONS =
            "SELECT couponId, couponCode, description, discountType, " +
            "discountValue, minimumOrderAmount, maximumDiscount, " +
            "isActive, expiryDate, createdAt " +
            "FROM coupons " +
            "ORDER BY couponId ASC";

    private static final String GET_ACTIVE_COUPONS =
            "SELECT couponId, couponCode, description, discountType, " +
            "discountValue, minimumOrderAmount, maximumDiscount, " +
            "isActive, expiryDate, createdAt " +
            "FROM coupons " +
            "WHERE isActive = TRUE " +
            "AND (expiryDate IS NULL OR expiryDate >= CURDATE()) " +
            "ORDER BY couponId ASC";

    // =========================================================
    // ADD COUPON
    // =========================================================

    @Override
    public void addCoupon(Coupon coupon) {

        if (coupon == null) {
            return;
        }

        if (!isValidCoupon(coupon)) {
            return;
        }

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(ADD_COUPON)) {

            statement.setString(
                    1,
                    coupon.getCouponCode().trim()
            );

            statement.setString(
                    2,
                    coupon.getDescription()
            );

            statement.setString(
                    3,
                    coupon.getDiscountType()
            );

            statement.setDouble(
                    4,
                    coupon.getDiscountValue()
            );

            statement.setDouble(
                    5,
                    coupon.getMinimumOrderAmount()
            );

            setMaximumDiscount(
                    statement,
                    6,
                    coupon
            );

            statement.setBoolean(
                    7,
                    coupon.isActive()
            );

            setExpiryDate(
                    statement,
                    8,
                    coupon
            );

            statement.executeUpdate();

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to add coupon."
            );

            e.printStackTrace();
        }
    }

    // =========================================================
    // GET COUPON BY ID
    // =========================================================

    @Override
    public Coupon getCoupon(int couponId) {

        if (couponId <= 0) {
            return null;
        }

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(GET_COUPON)) {

            statement.setInt(
                    1,
                    couponId
            );

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {
                    return mapCoupon(rs);
                }
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to get coupon."
            );

            e.printStackTrace();
        }

        return null;
    }

    // =========================================================
    // GET COUPON BY CODE
    // =========================================================

    @Override
    public Coupon getCouponByCode(String couponCode) {

        if (couponCode == null ||
                couponCode.trim().isEmpty()) {

            return null;
        }

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             GET_COUPON_BY_CODE)) {

            statement.setString(
                    1,
                    couponCode.trim()
            );

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {
                    return mapCoupon(rs);
                }
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to find coupon by code."
            );

            e.printStackTrace();
        }

        return null;
    }

    // =========================================================
    // UPDATE COUPON
    // =========================================================

    @Override
    public void updateCoupon(Coupon coupon) {

        if (coupon == null) {
            return;
        }

        if (coupon.getCouponId() <= 0) {
            return;
        }

        if (!isValidCoupon(coupon)) {
            return;
        }

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             UPDATE_COUPON)) {

            statement.setString(
                    1,
                    coupon.getCouponCode().trim()
            );

            statement.setString(
                    2,
                    coupon.getDescription()
            );

            statement.setString(
                    3,
                    coupon.getDiscountType()
            );

            statement.setDouble(
                    4,
                    coupon.getDiscountValue()
            );

            statement.setDouble(
                    5,
                    coupon.getMinimumOrderAmount()
            );

            setMaximumDiscount(
                    statement,
                    6,
                    coupon
            );

            statement.setBoolean(
                    7,
                    coupon.isActive()
            );

            setExpiryDate(
                    statement,
                    8,
                    coupon
            );

            statement.setInt(
                    9,
                    coupon.getCouponId()
            );

            statement.executeUpdate();

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to update coupon."
            );

            e.printStackTrace();
        }
    }

    // =========================================================
    // DELETE COUPON
    // =========================================================

    @Override
    public void deleteCoupon(int couponId) {

        if (couponId <= 0) {
            return;
        }

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             DELETE_COUPON)) {

            statement.setInt(
                    1,
                    couponId
            );

            statement.executeUpdate();

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to delete coupon."
            );

            e.printStackTrace();
        }
    }

    // =========================================================
    // GET ALL COUPONS
    // =========================================================

    @Override
    public List<Coupon> getAllCoupons() {

        List<Coupon> coupons =
                new ArrayList<>();

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             GET_ALL_COUPONS);
             ResultSet rs =
                     statement.executeQuery()) {

            while (rs.next()) {

                coupons.add(
                        mapCoupon(rs)
                );
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to load all coupons."
            );

            e.printStackTrace();
        }

        return coupons;
    }

    // =========================================================
    // GET ACTIVE COUPONS
    // =========================================================

    @Override
    public List<Coupon> getActiveCoupons() {

        List<Coupon> coupons =
                new ArrayList<>();

        try (Connection connection = DBconnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             GET_ACTIVE_COUPONS);
             ResultSet rs =
                     statement.executeQuery()) {

            while (rs.next()) {

                coupons.add(
                        mapCoupon(rs)
                );
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR: Unable to load active coupons."
            );

            e.printStackTrace();
        }

        return coupons;
    }

    // =========================================================
    // MAP RESULT SET TO COUPON
    // =========================================================

    private Coupon mapCoupon(ResultSet rs)
            throws SQLException {

        Coupon coupon =
                new Coupon();

        coupon.setCouponId(
                rs.getInt("couponId")
        );

        coupon.setCouponCode(
                rs.getString("couponCode")
        );

        coupon.setDescription(
                rs.getString("description")
        );

        coupon.setDiscountType(
                rs.getString("discountType")
        );

        coupon.setDiscountValue(
                rs.getDouble("discountValue")
        );

        coupon.setMinimumOrderAmount(
                rs.getDouble("minimumOrderAmount")
        );

        double maximumDiscount =
                rs.getDouble("maximumDiscount");

        if (rs.wasNull()) {

            coupon.setMaximumDiscount(null);

        } else {

            coupon.setMaximumDiscount(
                    maximumDiscount
            );
        }

        coupon.setActive(
                rs.getBoolean("isActive")
        );

        coupon.setExpiryDate(
                rs.getDate("expiryDate")
        );

        coupon.setCreatedAt(
                rs.getTimestamp("createdAt")
        );

        return coupon;
    }

    // =========================================================
    // SET MAXIMUM DISCOUNT
    // =========================================================

    private void setMaximumDiscount(
            PreparedStatement statement,
            int parameterIndex,
            Coupon coupon)
            throws SQLException {

        if (coupon.getMaximumDiscount() != null) {

            statement.setDouble(
                    parameterIndex,
                    coupon.getMaximumDiscount()
            );

        } else {

            statement.setNull(
                    parameterIndex,
                    Types.DECIMAL
            );
        }
    }

    // =========================================================
    // SET EXPIRY DATE
    // =========================================================

    private void setExpiryDate(
            PreparedStatement statement,
            int parameterIndex,
            Coupon coupon)
            throws SQLException {

        if (coupon.getExpiryDate() != null) {

            statement.setDate(
                    parameterIndex,
                    coupon.getExpiryDate()
            );

        } else {

            statement.setNull(
                    parameterIndex,
                    Types.DATE
            );
        }
    }

    // =========================================================
    // BASIC COUPON VALIDATION
    // =========================================================

    private boolean isValidCoupon(Coupon coupon) {

        if (coupon.getCouponCode() == null ||
                coupon.getCouponCode().trim().isEmpty()) {

            return false;
        }

        if (coupon.getDiscountType() == null ||
                coupon.getDiscountType().trim().isEmpty()) {

            return false;
        }

        if (coupon.getDiscountValue() < 0) {
            return false;
        }

        if (coupon.getMinimumOrderAmount() < 0) {
            return false;
        }

        if (coupon.getMaximumDiscount() != null &&
                coupon.getMaximumDiscount() < 0) {

            return false;
        }

        return true;
    }
}