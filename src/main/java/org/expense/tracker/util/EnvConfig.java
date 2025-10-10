package org.expense.tracker.util;

import io.github.cdimascio.dotenv.Dotenv;
import io.github.cdimascio.dotenv.DotenvException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EnvConfig {

    private static final Logger logger = LoggerFactory.getLogger(EnvConfig.class);
    private static Dotenv dotenv;

    private EnvConfig() {
        // Private constructor to prevent instantiation
    }

    public static void load() {
        if (dotenv == null) {
            try {
                dotenv = Dotenv.configure()
                        .load(); // Load .env from the classpath root (target/classes or JAR root)
                logger.info(".env file loaded successfully.");
            } catch (DotenvException e) {
                logger.warn("Could not load .env file. Ensure it exists in src/main/resources. Error: {}", e.getMessage());
                // Fallback or handle gracefully if .env is not found (e.g., use system environment variables)
            }
        }
    }

    public static String get(String key) {
        if (dotenv == null) {
            load(); // Attempt to load if not already loaded
        }
        String value = dotenv != null ? dotenv.get(key) : System.getenv(key);
        if (value == null) {
            logger.warn("Environment variable '{}' not found in .env or system environment.", key);
        }
        return value;
    }
}