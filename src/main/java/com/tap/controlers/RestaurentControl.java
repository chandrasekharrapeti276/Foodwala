
package com.tap.controlers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.tap.DAO1.RestaurentDAO;
import com.tap.DAOimpl.RestaurentDAOImpl;
import com.tap.module.Restaurent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/restaurent")
public class RestaurentControl extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RestaurentDAO restaurentDAO =
            new RestaurentDAOImpl();

    private final RestaurentDAOImpl restaurentDAOImpl =
            new RestaurentDAOImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            System.out.println(
                "[Foodwala] Loading restaurants and menu search data..."
            );

            List<Restaurent> restaurants =
                    restaurentDAO.getAllRestaurents();

            if (restaurants == null) {
                throw new ServletException(
                    "Restaurant DAO returned null."
                );
            }

            Map<Integer, String> menuSearchText =
                    restaurentDAOImpl
                        .getMenuSearchTextForActiveRestaurants();

            request.setAttribute(
                "restaurents",
                restaurants
            );

            request.setAttribute(
                "menuSearchText",
                menuSearchText
            );

            request.removeAttribute("restaurantError");

            System.out.println(
                "[Foodwala] Restaurants loaded: " +
                restaurants.size()
            );

            System.out.println(
                "[Foodwala] Menu-search entries loaded: " +
                menuSearchText.size()
            );

            request.getRequestDispatcher(
                "/retaurent.jsp"
            ).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute(
                "restaurantError",
                "Unable to load restaurants or menu search data. " +
                "Check the Eclipse/Tomcat Console for details."
            );

            request.setAttribute("restaurents", null);
            request.setAttribute("menuSearchText", null);

            request.getRequestDispatcher(
                "/retaurent.jsp"
            ).forward(request, response);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
