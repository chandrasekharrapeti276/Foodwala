package com.tap.DAO1;

import java.util.List;

import com.tap.module.Coupon;

public interface CouponDAO {

    void addCoupon(Coupon coupon);

    Coupon getCoupon(int couponId);

    Coupon getCouponByCode(String couponCode);

    void updateCoupon(Coupon coupon);

    void deleteCoupon(int couponId);

    List<Coupon> getAllCoupons();

    List<Coupon> getActiveCoupons();
}