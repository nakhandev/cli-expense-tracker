package org.expense.tracker.service;

import com.opencsv.CSVWriter;
import org.expense.tracker.dao.ExpenseDAO;
import org.expense.tracker.model.Expense;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class ExpenseService {

    private static final Logger logger = LoggerFactory.getLogger(ExpenseService.class);
    private final ExpenseDAO expenseDAO;
    private static final String EXPORT_DIR = "src/main/resources/export/";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public ExpenseService(ExpenseDAO expenseDAO) {
        this.expenseDAO = expenseDAO;
    }

    public void addExpense(Expense expense) {
        if (expense.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            logger.warn("Attempted to add an expense with non-positive amount: {}", expense.getAmount());
            System.out.println("Error: Expense amount must be positive.");
            return;
        }
        expenseDAO.addExpense(expense);
        logger.info("Expense added: {}", expense);
    }

    public Expense getExpenseById(int id) {
        return expenseDAO.getExpenseById(id);
    }

    public List<Expense> getAllExpenses() {
        return expenseDAO.getAllExpenses();
    }

    public void updateExpense(Expense expense) {
        if (expense.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            logger.warn("Attempted to update an expense with non-positive amount: {}", expense.getAmount());
            System.out.println("Error: Expense amount must be positive.");
            return;
        }
        expenseDAO.updateExpense(expense);
        logger.info("Expense updated: {}", expense);
    }

    public void deleteExpense(int id) {
        expenseDAO.deleteExpense(id);
        logger.info("Expense deleted with ID: {}", id);
    }

    public List<Expense> filterExpenses(LocalDate startDate, LocalDate endDate, String category, BigDecimal minAmount, BigDecimal maxAmount) {
        List<Expense> filteredExpenses = getAllExpenses(); // Start with all expenses

        if (startDate != null && endDate != null) {
            filteredExpenses = filteredExpenses.stream()
                    .filter(e -> !e.getDate().isBefore(startDate) && !e.getDate().isAfter(endDate))
                    .collect(Collectors.toList());
            logger.debug("Filtered by date range ({} to {}): {} expenses", startDate, endDate, filteredExpenses.size());
        }

        if (category != null && !category.trim().isEmpty()) {
            filteredExpenses = filteredExpenses.stream()
                    .filter(e -> e.getCategory().equalsIgnoreCase(category))
                    .collect(Collectors.toList());
            logger.debug("Filtered by category '{}': {} expenses", category, filteredExpenses.size());
        }

        if (minAmount != null && maxAmount != null) {
            filteredExpenses = filteredExpenses.stream()
                    .filter(e -> e.getAmount().compareTo(minAmount) >= 0 && e.getAmount().compareTo(maxAmount) <= 0)
                    .collect(Collectors.toList());
            logger.debug("Filtered by amount range ({} to {}): {} expenses", minAmount, maxAmount, filteredExpenses.size());
        } else if (minAmount != null) {
            filteredExpenses = filteredExpenses.stream()
                    .filter(e -> e.getAmount().compareTo(minAmount) >= 0)
                    .collect(Collectors.toList());
            logger.debug("Filtered by minimum amount {}: {} expenses", minAmount, filteredExpenses.size());
        } else if (maxAmount != null) {
            filteredExpenses = filteredExpenses.stream()
                    .filter(e -> e.getAmount().compareTo(maxAmount) <= 0)
                    .collect(Collectors.toList());
            logger.debug("Filtered by maximum amount {}: {} expenses", maxAmount, filteredExpenses.size());
        }

        return filteredExpenses;
    }

    public BigDecimal getTotalExpenses(List<Expense> expenses) {
        return expenses.stream()
                .map(Expense::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public Map<String, BigDecimal> getCategoryTotals(List<Expense> expenses) {
        return expenses.stream()
                .collect(Collectors.groupingBy(
                        Expense::getCategory,
                        Collectors.reducing(BigDecimal.ZERO, Expense::getAmount, BigDecimal::add)
                ));
    }

    public void exportExpensesToCsv(List<Expense> expenses, String filename) {
        Path exportPath = Paths.get(EXPORT_DIR);
        if (!Files.exists(exportPath)) {
            try {
                Files.createDirectories(exportPath);
                logger.info("Created export directory: {}", exportPath);
            } catch (IOException e) {
                logger.error("Failed to create export directory: {}", e.getMessage());
                System.err.println("Error: Could not create export directory.");
                return;
            }
        }

        String filePath = EXPORT_DIR + filename;
        try (CSVWriter writer = new CSVWriter(new FileWriter(filePath))) {
            String[] header = {"ID", "Date", "Category", "Description", "Amount"};
            writer.writeNext(header);

            for (Expense expense : expenses) {
                String[] data = {
                        String.valueOf(expense.getId()),
                        expense.getDate().format(DATE_FORMATTER),
                        expense.getCategory(),
                        expense.getDescription(),
                        expense.getAmount().toPlainString()
                };
                writer.writeNext(data);
            }
            logger.info("Expenses exported successfully to: {}", filePath);
            System.out.println("Expenses exported successfully to: " + filePath);
        } catch (IOException e) {
            logger.error("Error exporting expenses to CSV: {}", e.getMessage());
            System.err.println("Error: Failed to export expenses to CSV. " + e.getMessage());
        }
    }
}
