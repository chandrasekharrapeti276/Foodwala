package com.tap.controlers;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/home")
public class HomeController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Foodwala does not use a separate homepage.
         *
         * The restaurant listing is the main/start page.
         *
         * Therefore:
         *
         * /home
         *     -> /restaurent
         *
         * This also keeps old links/bookmarks to /home
         * working without showing Home.jsp.
         */

        response.sendRedirect(
                request.getContextPath()
                        + "/restaurent"
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * POST requests to /home follow the same
         * restaurant-page flow.
         */

        doGet(
                request,
                response
        );
    }
}