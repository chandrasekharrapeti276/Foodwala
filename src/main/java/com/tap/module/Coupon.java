package com.tap.module;

import java.sql.Date;
import java.sql.Timestamp;

public class Coupon {

    private int couponId;
    private String couponCode;
    private String description;
    private String discountType;
    private double discountValue;
    private double minimumOrderAmount;
    private Double maximumDiscount;
    private boolean isActive;
    private Date expiryDate;
    private Timestamp createdAt;

    public Coupon() {
    }

    public Coupon(
            int couponId,
            String couponCode,
            String description,
            String discountType,
            double discountValue,
            double minimumOrderAmount,
            Double maximumDiscount,
            boolean isActive,
            Date expiryDate,
            Timestamp createdAt) {

        this.couponId = couponId;
        this.couponCode = couponCode;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.minimumOrderAmount = minimumOrderAmount;
        this.maximumDiscount = maximumDiscount;
        this.isActive = isActive;
        this.expiryDate = expiryDate;
        this.createdAt = createdAt;
    }

    public int getCouponId() {
        return couponId;
    }

    public void setCouponId(int couponId) {
        this.couponId = couponId;
    }

    public String getCouponCode() {
        return couponCode;
    }

    public void setCouponCode(String couponCode) {
        this.couponCode = couponCode;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public double getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(double discountValue) {
        this.discountValue = discountValue;
    }

    public double getMinimumOrderAmount() {
        return minimumOrderAmount;
    }

    public void setMinimumOrderAmount(double minimumOrderAmount) {
        this.minimumOrderAmount = minimumOrderAmount;
    }

    public Double getMaximumDiscount() {
        return maximumDiscount;
    }

    public void setMaximumDiscount(Double maximumDiscount) {
        this.maximumDiscount = maximumDiscount;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        this.isActive = active;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Coupon{" +
                "couponId=" + couponId +
                ", couponCode='" + couponCode + '\'' +
                ", description='" + description + '\'' +
                ", discountType='" + discountType + '\'' +
                ", discountValue=" + discountValue +
                ", minimumOrderAmount=" + minimumOrderAmount +
                ", maximumDiscount=" + maximumDiscount +
                ", isActive=" + isActive +
                ", expiryDate=" + expiryDate +
                ", createdAt=" + createdAt +
                '}';
    }
}