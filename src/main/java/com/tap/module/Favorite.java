package com.tap.module;

import java.sql.Timestamp;

public class Favorite {

    private int favoriteId;
    private int userId;
    private int restaurentId;

    private String restaurentName;
    private String cuisineType;
    private String deliveryTime;
    private String address;

    private double rating;
    private double discountPercent;

    private String imagePath;

    private Timestamp createdAt;

    /*
     * ============================================================
     * DEFAULT CONSTRUCTOR
     * ============================================================
     */
    public Favorite() {
    }

    /*
     * ============================================================
     * FULL CONSTRUCTOR
     * ============================================================
     */
    public Favorite(
            int favoriteId,
            int userId,
            int restaurentId,
            String restaurentName,
            String cuisineType,
            String deliveryTime,
            String address,
            double rating,
            double discountPercent,
            String imagePath,
            Timestamp createdAt) {

        this.favoriteId = favoriteId;
        this.userId = userId;
        this.restaurentId = restaurentId;

        this.restaurentName = restaurentName;
        this.cuisineType = cuisineType;
        this.deliveryTime = deliveryTime;
        this.address = address;

        this.rating = rating;
        this.discountPercent = discountPercent;

        this.imagePath = imagePath;
        this.createdAt = createdAt;
    }

    /*
     * ============================================================
     * FAVORITE ID
     * ============================================================
     */
    public int getFavoriteId() {
        return favoriteId;
    }

    public void setFavoriteId(int favoriteId) {
        this.favoriteId = favoriteId;
    }

    /*
     * ============================================================
     * USER ID
     * ============================================================
     */
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    /*
     * ============================================================
     * RESTAURENT ID
     * ============================================================
     */
    public int getRestaurentId() {
        return restaurentId;
    }

    public void setRestaurentId(int restaurentId) {
        this.restaurentId = restaurentId;
    }

    /*
     * ============================================================
     * RESTAURENT NAME
     * ============================================================
     */
    public String getRestaurentName() {
        return restaurentName;
    }

    public void setRestaurentName(String restaurentName) {
        this.restaurentName = restaurentName;
    }

    /*
     * ============================================================
     * CUISINE TYPE
     * ============================================================
     */
    public String getCuisineType() {
        return cuisineType;
    }

    public void setCuisineType(String cuisineType) {
        this.cuisineType = cuisineType;
    }

    /*
     * ============================================================
     * DELIVERY TIME
     * ============================================================
     */
    public String getDeliveryTime() {
        return deliveryTime;
    }

    public void setDeliveryTime(String deliveryTime) {
        this.deliveryTime = deliveryTime;
    }

    /*
     * ============================================================
     * ADDRESS
     * ============================================================
     */
    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    /*
     * ============================================================
     * RATING
     * ============================================================
     */
    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {

        if (rating < 0) {
            rating = 0;
        }

        if (rating > 5) {
            rating = 5;
        }

        this.rating = rating;
    }

    /*
     * ============================================================
     * DISCOUNT PERCENT
     * ============================================================
     */
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

    /*
     * ============================================================
     * IMAGE PATH
     * ============================================================
     */
    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    /*
     * ============================================================
     * CREATED AT
     * ============================================================
     */
    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /*
     * ============================================================
     * TO STRING
     * ============================================================
     */
    @Override
    public String toString() {

        return "Favorite{" +
                "favoriteId=" + favoriteId +
                ", userId=" + userId +
                ", restaurentId=" + restaurentId +
                ", restaurentName='" + restaurentName + '\'' +
                ", cuisineType='" + cuisineType + '\'' +
                ", deliveryTime='" + deliveryTime + '\'' +
                ", address='" + address + '\'' +
                ", rating=" + rating +
                ", discountPercent=" + discountPercent +
                ", imagePath='" + imagePath + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}