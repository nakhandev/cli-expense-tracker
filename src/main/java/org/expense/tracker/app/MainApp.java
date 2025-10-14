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
                        viewAllExpenses();
                        break;
                    case "3":
                        searchExpenses();
                        break;
                    case "4":
                        updateExpense();
                        break;
                    case "5":
                        deleteExpense();
                        break;
                    case "6":
                        viewSummaryReports();
                        break;
                    case "7":
                        exportExpenses();
                        break;
                    case "8":
                        showSettings();
                        break;
                    case "9":
                        showHelp();
                        break;
                    case "0":
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
        System.out.println("╔══════════════════════════════════════════════════╗");
        System.out.println("║          💰 CLI Expense Tracker v2.0          ║");
        System.out.println("║              Personal Finance Manager           ║");
        System.out.println("╚══════════════════════════════════════════════════╝");
    }

    private void printMenu() {
        System.out.println("\n📋 Main Menu:");
        System.out.println("1. ➕ Add New Expense");
        System.out.println("2. 👁️  View All Expenses");
        System.out.println("3. 🔍 Search/Filter Expenses");
        System.out.println("4. ✏️  Update Expense");
        System.out.println("5. 🗑️  Delete Expense");
        System.out.println("6. 📊 View Summary Reports");
        System.out.println("7. 📈 Export to CSV");
        System.out.println("8. ⚙️  Settings");
        System.out.println("9. ❓ Help");
        System.out.println("0. 🚪 Exit");
        System.out.print("\nEnter your choice (0-9): ");
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

    private void viewAllExpenses() {
        System.out.println("\n--- View All Expenses ---");
        List<Expense> expenses = expenseService.getAllExpenses();

        if (expenses.isEmpty()) {
            System.out.println("No expenses found.");
            return;
        }

        displayExpenses(expenses);
    }

    private void searchExpenses() {
        System.out.println("\n--- Search/Filter Expenses ---");
        LocalDate startDate = promptForDate("Enter start date for filter (YYYY-MM-DD, leave blank for no filter): ");
        LocalDate endDate = promptForDate("Enter end date for filter (YYYY-MM-DD, leave blank for no filter): ");
        System.out.print("Enter category for filter (leave blank for no filter): ");
        String category = scanner.nextLine();
        BigDecimal minAmount = promptForBigDecimalOptional("Enter minimum amount for filter (leave blank for no filter): ");
        BigDecimal maxAmount = promptForBigDecimalOptional("Enter maximum amount for filter (leave blank for no filter): ");

        List<Expense> expenses = expenseService.filterExpenses(startDate, endDate, category, minAmount, maxAmount);

        if (expenses.isEmpty()) {
            System.out.println("No expenses found matching your criteria.");
            return;
        }

        System.out.println("\n--- Filtered Expenses ---");
        displayExpenses(expenses);
    }

    private void displayExpenses(List<Expense> expenses) {
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

    private void viewSummaryReports() {
        System.out.println("\n📊 === EXPENSE SUMMARY REPORTS ===");

        List<Expense> allExpenses = expenseService.getAllExpenses();
        if (allExpenses.isEmpty()) {
            System.out.println("No expenses found for reporting.");
            return;
        }

        // Total Expenses
        BigDecimal totalAmount = expenseService.getTotalExpenses(allExpenses);
        System.out.println("\n💰 Total Expenses: $" + String.format("%.2f", totalAmount));

        // Average Expense
        BigDecimal averageAmount = totalAmount.divide(BigDecimal.valueOf(allExpenses.size()), 2, BigDecimal.ROUND_HALF_UP);
        System.out.println("📊 Average Expense: $" + String.format("%.2f", averageAmount));

        // Category Breakdown
        System.out.println("\n📈 Category Breakdown:");
        System.out.println("----------------------------------------");
        Map<String, BigDecimal> categoryTotals = expenseService.getCategoryTotals(allExpenses);
        categoryTotals.entrySet().stream()
            .sorted(Map.Entry.<String, BigDecimal>comparingByValue().reversed())
            .forEach(entry -> {
                String category = entry.getKey();
                BigDecimal amount = entry.getValue();
                double percentage = amount.doubleValue() / totalAmount.doubleValue() * 100;
                System.out.printf("  %-15s: $%8.2f (%5.1f%%)\n", category, amount, percentage);
            });

        // Monthly Summary (if we have multiple months)
        System.out.println("\n📅 Monthly Summary:");
        System.out.println("----------------------------------------");
        Map<String, BigDecimal> monthlyTotals = expenseService.getMonthlyTotals(allExpenses);
        monthlyTotals.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .forEach(entry -> {
                String month = entry.getKey();
                BigDecimal amount = entry.getValue();
                System.out.printf("  %-10s: $%8.2f\n", month, amount);
            });

        // Recent Trends (last 7 days vs previous 7 days)
        LocalDate today = LocalDate.now();
        LocalDate lastWeek = today.minusDays(7);
        LocalDate twoWeeksAgo = today.minusDays(14);

        List<Expense> last7Days = expenseService.filterExpenses(lastWeek, today, null, null, null);
        List<Expense> previous7Days = expenseService.filterExpenses(twoWeeksAgo, lastWeek, null, null, null);

        BigDecimal last7Total = expenseService.getTotalExpenses(last7Days);
        BigDecimal previous7Total = expenseService.getTotalExpenses(previous7Days);

        System.out.println("\n📈 Recent Trends:");
        System.out.println("----------------------------------------");
        System.out.printf("  Last 7 days:     $%8.2f\n", last7Total);
        System.out.printf("  Previous 7 days: $%8.2f\n", previous7Total);

        if (previous7Total.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal change = last7Total.subtract(previous7Total);
            double changePercent = change.doubleValue() / previous7Total.doubleValue() * 100;
            String trend = change.compareTo(BigDecimal.ZERO) >= 0 ? "📈" : "📉";
            System.out.printf("  Change:          %s $%8.2f (%+.1f%%)\n", trend, change.abs(), changePercent);
        }
    }

    private void showSettings() {
        System.out.println("\n⚙️  === APPLICATION SETTINGS ===");

        System.out.println("\n📋 Current Configuration:");
        System.out.println("----------------------------------------");

        // Database settings
        System.out.println("🗄️  Database:");
        System.out.println("  URL: " + System.getProperty("DB_URL", "Not configured"));
        System.out.println("  User: " + System.getProperty("DB_USER", "Not configured"));

        // Application settings
        System.out.println("\n⚙️  Application:");
        System.out.println("  Version: 2.0.0");
        System.out.println("  Log Level: " + System.getProperty("LOG_LEVEL", "INFO"));
        System.out.println("  Export Path: " + System.getProperty("EXPORT_PATH", "src/main/resources/export/"));

        // Performance settings
        System.out.println("\n🚀 Performance:");
        System.out.println("  Max Memory: " + System.getProperty("MAX_MEMORY", "512m"));
        System.out.println("  Batch Size: " + System.getProperty("BATCH_SIZE", "1000"));

        System.out.println("\n💡 Tips:");
        System.out.println("  • Use environment variables to configure database settings");
        System.out.println("  • Check logs directory for application logs");
        System.out.println("  • Export directory contains CSV files");
        System.out.println("  • Use 'Help' option for usage guidance");
    }

    private void showHelp() {
        System.out.println("\n❓ === CLI EXPENSE TRACKER HELP ===");

        System.out.println("\n📖 Getting Started:");
        System.out.println("  1. Add expenses with option 1");
        System.out.println("  2. View all expenses with option 2");
        System.out.println("  3. Search/filter with option 3");
        System.out.println("  4. Update expenses with option 4");
        System.out.println("  5. Delete expenses with option 5");

        System.out.println("\n📊 Advanced Features:");
        System.out.println("  6. View detailed reports and analytics");
        System.out.println("  7. Export data to CSV files");
        System.out.println("  8. Check application settings");
        System.out.println("  9. Get help and usage tips");

        System.out.println("\n💡 Usage Tips:");
        System.out.println("  • Use descriptive categories for better organization");
        System.out.println("  • Add descriptions to remember expense details");
        System.out.println("  • Use search filters to find specific expenses");
        System.out.println("  • Export data regularly for backup");
        System.out.println("  • Check summary reports for spending insights");

        System.out.println("\n🛠️  Data Management:");
        System.out.println("  • All data is stored in MySQL database");
        System.out.println("  • Use export feature for data portability");
        System.out.println("  • Database configuration in .env file");
        System.out.println("  • Automatic logging for troubleshooting");

        System.out.println("\n⌨️  Keyboard Shortcuts:");
        System.out.println("  • Enter 0 anytime to exit");
        System.out.println("  • Press Enter to continue after each action");
        System.out.println("  • Use Ctrl+C to force quit if needed");

        System.out.println("\n🔗 For more information:");
        System.out.println("  Check the README.md file for detailed documentation");
    }
}
