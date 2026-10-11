
package com.tap.controlers;

import java.io.IOException;
import java.util.List;

import com.tap.DAO1.MenuDAO;
import com.tap.DAO1.RestaurentDAO;
import com.tap.DAOimpl.MenuDAOImpl;
import com.tap.DAOimpl.RestaurentDAOImpl;
import com.tap.module.Menu;
import com.tap.module.Restaurent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final MenuDAO menuDAO = new MenuDAOImpl();
    private final RestaurentDAO restaurentDAO = new RestaurentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String idParameter = request.getParameter("restaurentId");

        if (idParameter == null || idParameter.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/restaurent");
            return;
        }

        final int restaurentId;

        try {
            restaurentId = Integer.parseInt(idParameter.trim());

            if (restaurentId <= 0) {
                response.sendRedirect(request.getContextPath() + "/restaurent");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/restaurent");
            return;
        }

        try {
            Restaurent restaurent = restaurentDAO.getRestaurent(restaurentId);

            if (restaurent == null || !restaurent.isActive()) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Restaurant not found or is inactive."
                );
                return;
            }

            List<Menu> menus = menuDAO.getMenusByRestaurentId(restaurentId);

            request.setAttribute("restaurent", restaurent);
            request.setAttribute("menus", menus);
            request.setAttribute("restaurentId", restaurentId);

            String added = request.getParameter("added");
            if ("1".equals(added)) {
                request.setAttribute("cartMessage",
                    "Item added to your cart successfully.");
            }

            request.getRequestDispatcher("/menu.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(
                "Unable to load the restaurant menu.", e
            );
        }
    }
}