package org.expense.tracker.app;

import org.expense.tracker.dao.ExpenseDAO;
import org.expense.tracker.model.Expense;
import org.expense.tracker.service.ExpenseService;
import org.expense.tracker.util.DBConnection;
import org.expense.tracker.util.EnvConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

public class MainApp {

    private static final Logger logger = LoggerFactory.getLogger(MainApp.class);
    private final ExpenseService expenseService;
    private final Scanner scanner;

    public MainApp() {
        EnvConfig.load(); // Load environment variables at application start
        this.expenseService = new ExpenseService(new ExpenseDAO());
        this.scanner = new Scanner(System.in);
    }

    public static void main(String[] args) {
        MainApp app = new MainApp();
        app.run();
    }

    public void run() {
        logger.info("CLI Expense Tracker application started.");
        printWelcomeMessage();
        while (true) {
            printMenu();
            String choice = scanner.nextLine();
            try {
                switch (choice) {
                    case "1":
                        addExpense();
                        break;
                    case "2":
                        viewExpenses();
                        break;
                    case "3":
                        updateExpense();
                        break;
                    case "4":
                        deleteExpense();
                        break;
                    case "5":
                        exportExpenses();
                        break;
                    case "6":
                        System.out.println("Exiting application. Goodbye!");
                        logger.info("CLI Expense Tracker application stopped.");
                        DBConnection.closeConnection();
                        return;
                    default:
                        System.out.println("Invalid choice. Please try again.");
                }
            } catch (Exception e) {
                logger.error("An error occurred during command execution: {}", e.getMessage());
                System.out.println("An unexpected error occurred. Please try again.");
            }
            System.out.println("\nPress Enter to continue...");
            scanner.nextLine(); // Consume the newline
        }
    }

    private void printWelcomeMessage() {
        System.out.println("****************************************");
        System.out.println("*    Welcome to CLI Expense Tracker    *");
        System.out.println("****************************************");
    }

    private void printMenu() {
        System.out.println("\n--- Main Menu ---");
        System.out.println("1. Add Expense");
        System.out.println("2. View/Filter Expenses");
        System.out.println("3. Update Expense");
        System.out.println("4. Delete Expense");
        System.out.println("5. Export Expenses to CSV");
        System.out.println("6. Exit");
        System.out.print("Enter your choice: ");
    }

    private void addExpense() {
        System.out.println("\n--- Add New Expense ---");
        LocalDate date = promptForDate("Enter date (YYYY-MM-DD): ");
        System.out.print("Enter category: ");
        String category = scanner.nextLine();
        System.out.print("Enter description (optional): ");
        String description = scanner.nextLine();
        BigDecimal amount = promptForBigDecimal("Enter amount: ");

        if (date != null && category != null && !category.trim().isEmpty() && amount != null) {
            Expense newExpense = new Expense(date, category, description, amount);
            expenseService.addExpense(newExpense);
            System.out.println("Expense added successfully!");
        } else {
            System.out.println("Invalid input. Expense not added.");
        }
    }

    private void viewExpenses() {
        System.out.println("\n--- View/Filter Expenses ---");
        System.out.println("Do you want to filter expenses? (yes/no): ");
        String filterChoice = scanner.nextLine().trim().toLowerCase();

        List<Expense> expenses;
        if ("yes".equals(filterChoice)) {
            LocalDate startDate = promptForDate("Enter start date for filter (YYYY-MM-DD, leave blank for no filter): ");
            LocalDate endDate = promptForDate("Enter end date for filter (YYYY-MM-DD, leave blank for no filter): ");
            System.out.print("Enter category for filter (leave blank for no filter): ");
            String category = scanner.nextLine();
            BigDecimal minAmount = promptForBigDecimalOptional("Enter minimum amount for filter (leave blank for no filter): ");
            BigDecimal maxAmount = promptForBigDecimalOptional("Enter maximum amount for filter (leave blank for no filter): ");

            expenses = expenseService.filterExpenses(startDate, endDate, category, minAmount, maxAmount);
        } else {
            expenses = expenseService.getAllExpenses();
        }

        if (expenses.isEmpty()) {
            System.out.println("No expenses found.");
            return;
        }

        System.out.println("\n--- Your Expenses ---");
        System.out.printf("%-5s %-12s %-15s %-30s %-10s\n", "ID", "Date", "Category", "Description", "Amount");
        System.out.println("--------------------------------------------------------------------------");
        for (Expense expense : expenses) {
            System.out.printf("%-5d %-12s %-15s %-30s %-10.2f\n",
                    expense.getId(),
                    expense.getDate().toString(),
                    expense.getCategory(),
                    truncateString(expense.getDescription(), 28),
                    expense.getAmount());
        }
        System.out.println("--------------------------------------------------------------------------");

        BigDecimal total = expenseService.getTotalExpenses(expenses);
        System.out.println("Total expenses displayed: " + total);

        Map<String, BigDecimal> categoryTotals = expenseService.getCategoryTotals(expenses);
        if (!categoryTotals.isEmpty()) {
            System.out.println("\nCategory Totals:");
            categoryTotals.forEach((cat, sum) -> System.out.printf("  %-15s: %.2f\n", cat, sum));
        }
    }

    private void updateExpense() {
        System.out.println("\n--- Update Expense ---");
        int id = promptForInt("Enter ID of expense to update: ");
        Expense existingExpense = expenseService.getExpenseById(id);

        if (existingExpense == null) {
            System.out.println("Expense with ID " + id + " not found.");
            return;
        }

        System.out.println("Current Expense Details: " + existingExpense);

        LocalDate newDate = promptForDate("Enter new date (YYYY-MM-DD, leave blank to keep current: " + existingExpense.getDate() + "): ");
        if (newDate == null) newDate = existingExpense.getDate();

        System.out.print("Enter new category (leave blank to keep current: " + existingExpense.getCategory() + "): ");
        String newCategory = scanner.nextLine();
        if (newCategory.trim().isEmpty()) newCategory = existingExpense.getCategory();

        System.out.print("Enter new description (leave blank to keep current: " + (existingExpense.getDescription() != null ? existingExpense.getDescription() : "") + "): ");
        String newDescription = scanner.nextLine();
        if (newDescription.trim().isEmpty()) newDescription = existingExpense.getDescription();

        BigDecimal newAmount = promptForBigDecimalOptional("Enter new amount (leave blank to keep current: " + existingExpense.getAmount() + "): ");
        if (newAmount == null) newAmount = existingExpense.getAmount();

        Expense updatedExpense = new Expense(id, newDate, newCategory, newDescription, newAmount);
        expenseService.updateExpense(updatedExpense);
        System.out.println("Expense updated successfully!");
    }

    private void deleteExpense() {
        System.out.println("\n--- Delete Expense ---");
        int id = promptForInt("Enter ID of expense to delete: ");
        Expense existingExpense = expenseService.getExpenseById(id);

        if (existingExpense == null) {
            System.out.println("Expense with ID " + id + " not found.");
            return;
        }

        System.out.println("Are you sure you want to delete this expense? (yes/no): " + existingExpense);
        String confirmation = scanner.nextLine().trim().toLowerCase();

        if ("yes".equals(confirmation)) {
            expenseService.deleteExpense(id);
            System.out.println("Expense deleted successfully!");
        } else {
            System.out.println("Expense deletion cancelled.");
        }
    }

    private void exportExpenses() {
        System.out.println("\n--- Export Expenses to CSV ---");
        System.out.println("Do you want to export all expenses or filtered expenses? (all/filtered): ");
        String exportChoice = scanner.nextLine().trim().toLowerCase();

        List<Expense> expensesToExport;
        if ("filtered".equals(exportChoice)) {
            LocalDate startDate = promptForDate("Enter start date for filter (YYYY-MM-DD, leave blank for no filter): ");
            LocalDate endDate = promptForDate("Enter end date for filter (YYYY-MM-DD, leave blank for no filter): ");
            System.out.print("Enter category for filter (leave blank for no filter): ");
            String category = scanner.nextLine();
            BigDecimal minAmount = promptForBigDecimalOptional("Enter minimum amount for filter (leave blank for no filter): ");
            BigDecimal maxAmount = promptForBigDecimalOptional("Enter maximum amount for filter (leave blank for no filter): ");

            expensesToExport = expenseService.filterExpenses(startDate, endDate, category, minAmount, maxAmount);
        } else {
            expensesToExport = expenseService.getAllExpenses();
        }

        if (expensesToExport.isEmpty()) {
            System.out.println("No expenses to export.");
            return;
        }

        String timestamp = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "_" +
                          java.time.LocalTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HHmmss"));
        String filename = "expenses_" + timestamp + ".csv";
        expenseService.exportExpensesToCsv(expensesToExport, filename);
    }

    private LocalDate promptForDate(String message) {
        while (true) {
            System.out.print(message);
            String input = scanner.nextLine();
            if (input.trim().isEmpty()) {
                return null; // Allow empty input for optional dates
            }
            try {
                return LocalDate.parse(input);
            } catch (DateTimeParseException e) {
                System.out.println("Invalid date format. Please use YYYY-MM-DD.");
            }
        }
    }

    private BigDecimal promptForBigDecimal(String message) {
        while (true) {
            System.out.print(message);
            String input = scanner.nextLine();
            try {
                BigDecimal amount = new BigDecimal(input);
                if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                    System.out.println("Amount must be a positive number.");
                } else {
                    return amount;
                }
            } catch (NumberFormatException e) {
                System.out.println("Invalid amount. Please enter a numeric value.");
            }
        }
    }

    private BigDecimal promptForBigDecimalOptional(String message) {
        while (true) {
            System.out.print(message);
            String input = scanner.nextLine();
            if (input.trim().isEmpty()) {
                return null;
            }
            try {
                BigDecimal amount = new BigDecimal(input);
                if (amount.compareTo(BigDecimal.ZERO) < 0) {
                    System.out.println("Amount cannot be negative.");
                } else {
                    return amount;
                }
            } catch (NumberFormatException e) {
                System.out.println("Invalid amount. Please enter a numeric value.");
            }
        }
    }

    private int promptForInt(String message) {
        while (true) {
            System.out.print(message);
            String input = scanner.nextLine();
            try {
                return Integer.parseInt(input);
            } catch (NumberFormatException e) {
                System.out.println("Invalid input. Please enter a whole number.");
            }
        }
    }

    private String truncateString(String text, int maxLength) {
        if (text == null) {
            return "";
        }
        if (text.length() > maxLength) {
            return text.substring(0, maxLength - 3) + "...";
        }
        return text;
    }
}
