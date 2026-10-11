
package com.tap.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBconnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/foodwaladatabase"
            + "?useSSL=false"
            + "&serverTimezone=Asia/Kolkata"
            + "&allowPublicKeyRetrieval=true";

    private static final String USER = "root";

    private static final String PASSWORD =
            System.getenv("FOODWALA_DB_PASSWORD");

    private DBconnection() {
        // Prevent object creation
    }

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Foodwala: MySQL JDBC driver loaded.");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                    "MySQL Connector/J driver is missing."
            );
        }
    }

    public static Connection getConnection()
            throws SQLException {

        if (PASSWORD == null || PASSWORD.trim().isEmpty()) {
            throw new SQLException(
                    "FOODWALA_DB_PASSWORD environment variable "
                    + "is not configured."
            );
        }

        Connection connection = DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
        );

        System.out.println(
                "Foodwala: Database connection successful."
        );

        return connection;
    }
}
