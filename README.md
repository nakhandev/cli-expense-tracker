# CLI Expense Tracker

A simple command-line Java application to track, manage, and export personal expenses using MySQL as the backend database.

## Features

- **Add Expense**: Record amount, date, category, and description.
- **Update Expense**: Modify existing expense details by ID.
- **Delete Expense**: Remove an expense by ID.
- **View/Filter Expenses**:
    - View all expenses.
    - Filter by date range, category, or amount.
    - Display summary (total spent, category totals).
- **Export Expenses**: Export filtered or all expenses to a CSV file.

## Tech Stack

- **Language**: Java (OpenJDK 21+)
- **Database**: MySQL
- **ORM / DB Access**: JDBC
- **Configuration**: dotenv-java (for `.env` file parsing)
- **Build Tool**: Maven
- **CSV Export**: OpenCSV
- **Logging**: SLF4J + Logback

## Architecture

The application follows a simplified MVC pattern:

```
cli-expense-tracker/
│
├── src/
│   ├── main/java/
│   │   ├── org/expense/tracker/
│   │   │   ├── model/           # Expense.java (entity class)
│   │   │   ├── dao/             # ExpenseDAO.java (CRUD operations)
│   │   │   ├── service/         # ExpenseService.java (business logic)
│   │   │   ├── util/            # DBConnection.java, EnvConfig.java
│   │   │   └── app/             # MainApp.java (entry point)
│   │
│   └── main/resources/
│       ├── .env.example         # DB credentials template
│       ├── logback.xml          # Logging configuration
│       └── export/              # Default CSV export folder
│
├── pom.xml                      # Maven project file
├── README.md
├── LICENSE
├── start.sh                     # Application startup script
├── stop.sh                      # Application management script
└── .gitignore                   # Git ignore patterns
```

## Setup and Installation

### 1. Prerequisites

- **Java Development Kit (JDK) 21+**: Ensure you have OpenJDK 21 or a compatible JDK installed.
- **Maven**: Install Maven for project management.
- **MySQL Server**: A running MySQL server instance.

### 2. Database Setup

The application includes automated database setup. However, if you need to set it up manually:

```sql
CREATE DATABASE expense_tracker;
CREATE USER 'nakhan'@'localhost' IDENTIFIED BY 'Linux@1998';
GRANT ALL PRIVILEGES ON expense_tracker.* TO 'nakhan'@'localhost';
FLUSH PRIVILEGES;
USE expense_tracker;

CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL
);
```

### 3. Configuration

The `.env` file is already configured in `src/main/resources/`. Update the database credentials if needed:

```env
DB_URL=jdbc:mysql://localhost:3306/expense_tracker
DB_USER=your-username
DB_PASSWORD=your-password
```

### 4. Build and Run

#### Option 1: Using Start Script (Recommended)

1.  Navigate to the project root directory (`cli-expense-tracker/`).
2.  Make the start script executable (first time only):

    ```bash
    chmod +x start.sh
    ```

3.  Run the application:

    ```bash
    ./start.sh
    ```

#### Option 2: Manual Build and Run

1.  Navigate to the project root directory (`cli-expense-tracker/`).
2.  Build the project using Maven:

    ```bash
    mvn clean compile
    ```

3.  Run the application:

    ```bash
    java -cp target/classes:$(mvn dependency:build-classpath -q -Dmdep.outputFile=/dev/stdout) org.expense.tracker.app.MainApp
    ```

    Or simply:

    ```bash
    mvn exec:java -Dexec.mainClass="org.expense.tracker.app.MainApp"
    ```

#### Option 3: Management Scripts

- **Start Application**: `./start.sh` - Compiles and starts the application with pre-flight checks
- **Stop Application**: `./stop.sh` - Shows application status and helps with cleanup tasks

## Usage

Once the application is running, follow the on-screen menu prompts to add, view, update, delete, and export expenses.

## License

[License information will go here]
