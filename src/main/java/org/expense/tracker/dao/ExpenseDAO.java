package org.expense.tracker.dao;

import org.expense.tracker.model.Expense;
import org.expense.tracker.util.DBConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ExpenseDAO {

    private static final Logger logger = LoggerFactory.getLogger(ExpenseDAO.class);

    private static final String INSERT_EXPENSE_SQL = "INSERT INTO expenses (date, category, description, amount) VALUES (?, ?, ?, ?)";
    private static final String SELECT_EXPENSE_BY_ID_SQL = "SELECT id, date, category, description, amount FROM expenses WHERE id = ?";
    private static final String SELECT_ALL_EXPENSES_SQL = "SELECT id, date, category, description, amount FROM expenses ORDER BY date DESC";
    private static final String UPDATE_EXPENSE_SQL = "UPDATE expenses SET date = ?, category = ?, description = ?, amount = ? WHERE id = ?";
    private static final String DELETE_EXPENSE_SQL = "DELETE FROM expenses WHERE id = ?";
    private static final String SELECT_EXPENSES_BY_DATE_RANGE_SQL = "SELECT id, date, category, description, amount FROM expenses WHERE date BETWEEN ? AND ? ORDER BY date DESC";
    private static final String SELECT_EXPENSES_BY_CATEGORY_SQL = "SELECT id, date, category, description, amount FROM expenses WHERE category = ? ORDER BY date DESC";
    private static final String SELECT_EXPENSES_BY_AMOUNT_RANGE_SQL = "SELECT id, date, category, description, amount FROM expenses WHERE amount BETWEEN ? AND ? ORDER BY amount DESC";


    public void addExpense(Expense expense) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(INSERT_EXPENSE_SQL, Statement.RETURN_GENERATED_KEYS)) {

            preparedStatement.setDate(1, Date.valueOf(expense.getDate()));
            preparedStatement.setString(2, expense.getCategory());
            preparedStatement.setString(3, expense.getDescription());
            preparedStatement.setBigDecimal(4, expense.getAmount());

            int affectedRows = preparedStatement.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = preparedStatement.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        expense.setId(generatedKeys.getInt(1));
                        logger.info("Expense added successfully with ID: {}", expense.getId());
                    }
                }
            } else {
                logger.warn("Adding expense failed, no rows affected.");
            }

        } catch (SQLException e) {
            logger.error("Error adding expense: {}", e.getMessage());
            e.printStackTrace();
        }
    }

    public Expense getExpenseById(int id) {
        Expense expense = null;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_EXPENSE_BY_ID_SQL)) {

            preparedStatement.setInt(1, id);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    expense = mapResultSetToExpense(resultSet);
                    logger.debug("Retrieved expense by ID: {}", id);
                } else {
                    logger.info("No expense found with ID: {}", id);
                }
            }
        } catch (SQLException e) {
            logger.error("Error retrieving expense by ID {}: {}", id, e.getMessage());
            e.printStackTrace();
        }
        return expense;
    }

    public List<Expense> getAllExpenses() {
        List<Expense> expenses = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(SELECT_ALL_EXPENSES_SQL)) {

            while (resultSet.next()) {
                expenses.add(mapResultSetToExpense(resultSet));
            }
            logger.debug("Retrieved {} expenses.", expenses.size());
        } catch (SQLException e) {
            logger.error("Error retrieving all expenses: {}", e.getMessage());
            e.printStackTrace();
        }
        return expenses;
    }

    public void updateExpense(Expense expense) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_EXPENSE_SQL)) {

            preparedStatement.setDate(1, Date.valueOf(expense.getDate()));
            preparedStatement.setString(2, expense.getCategory());
            preparedStatement.setString(3, expense.getDescription());
            preparedStatement.setBigDecimal(4, expense.getAmount());
            preparedStatement.setInt(5, expense.getId());

            int affectedRows = preparedStatement.executeUpdate();
            if (affectedRows > 0) {
                logger.info("Expense with ID {} updated successfully.", expense.getId());
            } else {
                logger.warn("Updating expense with ID {} failed, no rows affected. Expense might not exist.", expense.getId());
            }

        } catch (SQLException e) {
            logger.error("Error updating expense with ID {}: {}", expense.getId(), e.getMessage());
            e.printStackTrace();
        }
    }

    public void deleteExpense(int id) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(DELETE_EXPENSE_SQL)) {

            preparedStatement.setInt(1, id);
            int affectedRows = preparedStatement.executeUpdate();
            if (affectedRows > 0) {
                logger.info("Expense with ID {} deleted successfully.", id);
            } else {
                logger.warn("Deleting expense with ID {} failed, no rows affected. Expense might not exist.", id);
            }

        } catch (SQLException e) {
            logger.error("Error deleting expense with ID {}: {}", id, e.getMessage());
            e.printStackTrace();
        }
    }

    public List<Expense> getExpensesByDateRange(LocalDate startDate, LocalDate endDate) {
        List<Expense> expenses = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_EXPENSES_BY_DATE_RANGE_SQL)) {

            preparedStatement.setDate(1, Date.valueOf(startDate));
            preparedStatement.setDate(2, Date.valueOf(endDate));

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    expenses.add(mapResultSetToExpense(resultSet));
                }
            }
            logger.debug("Retrieved {} expenses between {} and {}.", expenses.size(), startDate, endDate);
        } catch (SQLException e) {
            logger.error("Error retrieving expenses by date range ({} to {}): {}", startDate, endDate, e.getMessage());
            e.printStackTrace();
        }
        return expenses;
    }

    public List<Expense> getExpensesByCategory(String category) {
        List<Expense> expenses = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_EXPENSES_BY_CATEGORY_SQL)) {

            preparedStatement.setString(1, category);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    expenses.add(mapResultSetToExpense(resultSet));
                }
            }
            logger.debug("Retrieved {} expenses for category '{}'.", expenses.size(), category);
        } catch (SQLException e) {
            logger.error("Error retrieving expenses by category '{}': {}", category, e.getMessage());
            e.printStackTrace();
        }
        return expenses;
    }

    public List<Expense> getExpensesByAmountRange(BigDecimal minAmount, BigDecimal maxAmount) {
        List<Expense> expenses = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_EXPENSES_BY_AMOUNT_RANGE_SQL)) {

            preparedStatement.setBigDecimal(1, minAmount);
            preparedStatement.setBigDecimal(2, maxAmount);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    expenses.add(mapResultSetToExpense(resultSet));
                }
            }
            logger.debug("Retrieved {} expenses between amount {} and {}.", expenses.size(), minAmount, maxAmount);
        } catch (SQLException e) {
            logger.error("Error retrieving expenses by amount range ({} to {}): {}", minAmount, maxAmount, e.getMessage());
            e.printStackTrace();
        }
        return expenses;
    }

    private Expense mapResultSetToExpense(ResultSet resultSet) throws SQLException {
        int id = resultSet.getInt("id");
        LocalDate date = resultSet.getDate("date").toLocalDate();
        String category = resultSet.getString("category");
        String description = resultSet.getString("description");
        BigDecimal amount = resultSet.getBigDecimal("amount");
        return new Expense(id, date, category, description, amount);
    }
}