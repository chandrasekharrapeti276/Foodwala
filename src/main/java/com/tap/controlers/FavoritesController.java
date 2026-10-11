
package com.tap.controlers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.DAO1.FavoriteDAO;
import com.tap.DAOimpl.FavoriteDAOImpl;
import com.tap.module.Favorite;

@WebServlet("/favorites")
public class FavoritesController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FavoriteDAO favoriteDAO = new FavoriteDAOImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            session.setAttribute("redirectAfterLogin", "/favorites");
            response.sendRedirect(
                    request.getContextPath() + "/Login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("remove".equalsIgnoreCase(action)) {
            removeFavorite(request, response, session, userId);
            return;
        }

        loadFavorites(request, response, session, userId);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            session.setAttribute(
                    "redirectAfterLogin",
                    "/restaurent");

            response.sendRedirect(
                    request.getContextPath() + "/Login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equalsIgnoreCase(action)) {
            addFavorite(request, response, session, userId);
            return;
        }

        session.setAttribute(
                "favoriteError",
                "Invalid favorite action.");

        response.sendRedirect(
                request.getContextPath() + "/restaurent");
    }

    private Integer getLoggedInUserId(HttpSession session) {
        Object value = session.getAttribute("userId");

        if (value == null) {
            return null;
        }

        try {
            int userId = Integer.parseInt(value.toString());

            return userId > 0 ? userId : null;

        } catch (NumberFormatException e) {
            session.removeAttribute("userId");
            return null;
        }
    }

    private void addFavorite(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            int userId)
            throws IOException {

        String contextPath = request.getContextPath();
        String restaurantValue =
                request.getParameter("restaurentId");

        int restaurentId;

        try {
            restaurentId = Integer.parseInt(restaurantValue);

            if (restaurentId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException | NullPointerException e) {
            session.setAttribute(
                    "favoriteError",
                    "Invalid restaurant ID.");

            response.sendRedirect(contextPath + "/restaurent");
            return;
        }

        try {
            boolean alreadyFavorite =
                    favoriteDAO.isFavorite(userId, restaurentId);

            if (alreadyFavorite) {
                session.setAttribute(
                        "favoriteMessage",
                        "This restaurant is already in your favorites.");

            } else {
                boolean added =
                        favoriteDAO.addFavorite(userId, restaurentId);

                if (added) {
                    session.setAttribute(
                            "favoriteMessage",
                            "Restaurant added to favorites.");
                } else {
                    session.setAttribute(
                            "favoriteError",
                            "Restaurant could not be added. Please try again.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();

            session.setAttribute(
                    "favoriteError",
                    "Unable to save this restaurant. Check the server console.");
        }

        response.sendRedirect(contextPath + "/restaurent");
    }

    private void removeFavorite(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            int userId)
            throws IOException {

        String contextPath = request.getContextPath();
        String restaurantValue =
                request.getParameter("restaurentId");

        try {
            int restaurentId = Integer.parseInt(restaurantValue);

            if (restaurentId <= 0) {
                throw new NumberFormatException();
            }

            boolean removed =
                    favoriteDAO.removeFavorite(userId, restaurentId);

            if (removed) {
                session.setAttribute(
                        "favoriteMessage",
                        "Restaurant removed from favorites.");
            } else {
                session.setAttribute(
                        "favoriteError",
                        "Restaurant was not found in favorites.");
            }

        } catch (Exception e) {
            e.printStackTrace();

            session.setAttribute(
                    "favoriteError",
                    "Unable to remove this favorite.");
        }

        response.sendRedirect(contextPath + "/favorites");
    }

    private void loadFavorites(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            int userId)
            throws ServletException, IOException {

        try {
            List<Favorite> favorites =
                    favoriteDAO.getFavoritesByUserId(userId);

            if (favorites == null) {
                favorites = new ArrayList<>();
            }

            request.setAttribute("favorites", favorites);

            copySessionMessage(session, request, "favoriteMessage");
            copySessionMessage(session, request, "favoriteError");

            request.getRequestDispatcher("/Favorites.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute(
                    "favorites",
                    new ArrayList<Favorite>());

            request.setAttribute(
                    "favoriteError",
                    "Unable to load favorites. Check the server console.");

            request.getRequestDispatcher("/Favorites.jsp")
                   .forward(request, response);
        }
    }

    private void copySessionMessage(
            HttpSession session,
            HttpServletRequest request,
            String attributeName) {

        Object message = session.getAttribute(attributeName);

        if (message != null) {
            request.setAttribute(attributeName, message.toString());
            session.removeAttribute(attributeName);
        }
    }
}
