package com.tap.controlers;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.tap.module.CartItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class CartControl extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================================================
    // GET - DISPLAY CART
    // =========================================================

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession();

        Map<Integer, CartItem> cart =
                (Map<Integer, CartItem>)
                        session.getAttribute("cart");

        // -----------------------------------------------------
        // CREATE CART IF IT DOES NOT EXIST
        // -----------------------------------------------------

        if (cart == null) {

            cart =
                    new LinkedHashMap<Integer, CartItem>();

            session.setAttribute(
                    "cart",
                    cart
            );
        }

        // -----------------------------------------------------
        // SEND CART TO JSP
        // -----------------------------------------------------

        request.setAttribute(
                "cart",
                cart
        );

        // -----------------------------------------------------
        // PREVENT BROWSER CACHING
        // -----------------------------------------------------

        response.setHeader(
                "Cache-Control",
                "no-store, no-cache, must-revalidate"
        );

        response.setHeader(
                "Pragma",
                "no-cache"
        );

        response.setDateHeader(
                "Expires",
                0
        );

        // -----------------------------------------------------
        // FORWARD TO CART PAGE
        // -----------------------------------------------------

        request.getRequestDispatcher(
                "/Cart.jsp"
        ).forward(
                request,
                response
        );
    }

    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        doGet(
                request,
                response
        );
    }
}