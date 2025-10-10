package org.expense.tracker.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final Logger logger = LoggerFactory.getLogger(DBConnection.class);
    private static Connection connection = null;

    private DBConnection() {
        // Private constructor to prevent instantiation
    }

    public static Connection getConnection() {
        try {
            // Check if connection is null or closed
            if (connection == null || connection.isClosed()) {
                // Load environment variables
                EnvConfig.load();
                String dbUrl = EnvConfig.get("DB_URL");
                String dbUser = EnvConfig.get("DB_USER");
                String dbPassword = EnvConfig.get("DB_PASSWORD");

                if (dbUrl == null || dbUser == null || dbPassword == null) {
                    logger.error("Database connection properties (DB_URL, DB_USER, DB_PASSWORD) are not set in .env file.");
                    throw new SQLException("Missing database configuration.");
                }

                // Register JDBC driver (optional for modern JDBC, but good practice)
                Class.forName("com.mysql.cj.jdbc.Driver");

                logger.info("Attempting to connect to database: {}", dbUrl);
                connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                logger.info("Database connection established successfully.");
            }
        } catch (SQLException e) {
            logger.error("Failed to connect to the database: {}", e.getMessage());
            e.printStackTrace();
            connection = null; // Reset connection on failure
            throw new RuntimeException("Database connection failed", e);
        } catch (ClassNotFoundException e) {
            logger.error("MySQL JDBC Driver not found: {}", e.getMessage());
            e.printStackTrace();
            connection = null;
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        } catch (Exception e) {
            logger.error("An unexpected error occurred during database connection: {}", e.getMessage());
            e.printStackTrace();
            connection = null;
            throw new RuntimeException("Unexpected error during database connection", e);
        }
        return connection;
    }

    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                connection = null;
                logger.info("Database connection closed.");
            } catch (SQLException e) {
                logger.error("Failed to close the database connection: {}", e.getMessage());
                e.printStackTrace();
            }
        }
    }
}
