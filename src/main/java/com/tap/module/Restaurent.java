package com.tap.module;

public class Restaurent {

    private int restaurentId;
    private String name;
    private String cuisineType;
    private String deliveryTime;
    private String address;
    private int adminUserId;
    private double rating;

    // Restaurant-level discount percentage
    private double discountPercent;

    private boolean isActive;
    private String imagePath;


    // =========================================================
    // DEFAULT CONSTRUCTOR
    // =========================================================

    public Restaurent() {
    }


    // =========================================================
    // FULL CONSTRUCTOR
    // =========================================================

    public Restaurent(
            int restaurentId,
            String name,
            String cuisineType,
            String deliveryTime,
            String address,
            int adminUserId,
            double rating,
            double discountPercent,
            boolean isActive,
            String imagePath) {

        this.restaurentId = restaurentId;
        this.name = name;
        this.cuisineType = cuisineType;
        this.deliveryTime = deliveryTime;
        this.address = address;
        this.adminUserId = adminUserId;
        this.rating = rating;
        this.discountPercent = discountPercent;
        this.isActive = isActive;
        this.imagePath = imagePath;
    }


    // =========================================================
    // RESTAURANT ID
    // =========================================================

    public int getRestaurentId() {
        return restaurentId;
    }

    public void setRestaurentId(int restaurentId) {
        this.restaurentId = restaurentId;
    }


    // =========================================================
    // NAME
    // =========================================================

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }


    // =========================================================
    // CUISINE TYPE
    // =========================================================

    public String getCuisineType() {
        return cuisineType;
    }

    public void setCuisineType(String cuisineType) {
        this.cuisineType = cuisineType;
    }


    // =========================================================
    // DELIVERY TIME
    // =========================================================

    public String getDeliveryTime() {
        return deliveryTime;
    }

    public void setDeliveryTime(String deliveryTime) {
        this.deliveryTime = deliveryTime;
    }


    // =========================================================
    // ADDRESS
    // =========================================================

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }


    // =========================================================
    // ADMIN USER ID
    // =========================================================

    public int getAdminUserId() {
        return adminUserId;
    }

    public void setAdminUserId(int adminUserId) {
        this.adminUserId = adminUserId;
    }


    // =========================================================
    // RATING
    // =========================================================

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }


    // =========================================================
    // DISCOUNT PERCENT
    // =========================================================

    public double getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(double discountPercent) {

        if (discountPercent < 0) {
            discountPercent = 0;
        }

        if (discountPercent > 100) {
            discountPercent = 100;
        }

        this.discountPercent = discountPercent;
    }


    // =========================================================
    // ACTIVE
    // =========================================================

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        this.isActive = active;
    }


    // =========================================================
    // IMAGE PATH
    // =========================================================

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }


    // =========================================================
    // CALCULATE DISCOUNTED PRICE
    // =========================================================

    public double getDiscountedPrice(double originalPrice) {

        if (originalPrice < 0) {
            originalPrice = 0;
        }

        if (discountPercent <= 0) {
            return originalPrice;
        }

        double discountedPrice =
                originalPrice -
                (originalPrice * discountPercent / 100.0);

        return Math.round(discountedPrice * 100.0) / 100.0;
    }


    // =========================================================
    // TO STRING
    // =========================================================

    @Override
    public String toString() {

        return "Restaurent{" +
                "restaurentId=" + restaurentId +
                ", name='" + name + '\'' +
                ", cuisineType='" + cuisineType + '\'' +
                ", deliveryTime='" + deliveryTime + '\'' +
                ", address='" + address + '\'' +
                ", adminUserId=" + adminUserId +
                ", rating=" + rating +
                ", discountPercent=" + discountPercent +
                ", isActive=" + isActive +
                ", imagePath='" + imagePath + '\'' +
                '}';
    }
}