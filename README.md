# 🚀 CLI Expense Tracker

<div align="center">

[![Java](https://img.shields.io/badge/Java-21%2B-orange.svg)](https://openjdk.java.net/)
[![Maven](https://img.shields.io/badge/Maven-3.6%2B-blue.svg)](https://maven.apache.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0%2B-lightgrey.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)]()

*A powerful, feature-rich command-line application for personal expense tracking and management with MySQL backend and comprehensive automation scripts.*

</div>

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [🏗️ Architecture](#️-architecture)
- [🚀 Quick Start](#-quick-start)
- [📖 Detailed Setup](#-detailed-setup)
- [💻 Usage Guide](#-usage-guide)
- [🔧 Management Scripts](#-management-scripts)
- [🔍 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Features

### 💰 **Core Expense Management**
- ➕ **Add Expenses**: Record amount, date, category, and description with validation
- ✏️ **Update Expenses**: Modify existing expense details by ID with change tracking
- 🗑️ **Delete Expenses**: Remove expenses by ID with confirmation prompts
- 👁️ **View & Filter**: Advanced filtering by date range, category, amount, or description
- 📊 **Summary Reports**: Total spending, category breakdowns, and spending trends
- 📈 **Export Functionality**: Export to CSV with customizable filters and formatting

### 🔧 **Enhanced Management Scripts**
- 🚀 **Smart Start Script**: Pre-flight checks, dependency validation, and error recovery
- 🛑 **Advanced Stop Script**: Graceful shutdown, process management, and cleanup automation
- 📤 **Git Push Script**: Streamlined git operations with branch management and validation

### 🛡️ **Enterprise Features**
- 🔐 **Secure Configuration**: Environment-based configuration with `.env` support
- 📝 **Comprehensive Logging**: Structured logging with multiple levels and file rotation
- 🔄 **Automated Backups**: Backup creation before cleanup operations
- ⚡ **Performance Monitoring**: System resource tracking and optimization tips
- 🗄️ **Database Management**: Connection pooling and automated schema management

---

## 🛠️ Tech Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Language** | Java | 21+ | Core application logic |
| **Build Tool** | Maven | 3.6+ | Project management & dependencies |
| **Database** | MySQL | 8.0+ | Data persistence |
| **DB Access** | JDBC | Native | Database connectivity |
| **Configuration** | dotenv-java | Latest | Environment management |
| **CSV Processing** | OpenCSV | Latest | Export functionality |
| **Logging** | SLF4J + Logback | Latest | Structured logging |
| **Shell Scripts** | Bash | 4.0+ | Automation & management |

---

## 🏗️ Architecture

```
cli-expense-tracker/
│
├── 🚀 **Enhanced Scripts** ⚡
│   ├── start.sh          # Smart application launcher with pre-flight checks
│   ├── stop.sh           # Advanced process manager with cleanup
│   └── push.sh           # Git workflow automation (renamed from update.sh)
│
├── 📁 **Source Code** 💻
│   ├── src/main/java/org/expense/tracker/
│   │   ├── model/        # Expense.java (Data models)
│   │   ├── dao/          # ExpenseDAO.java (Data access layer)
│   │   ├── service/      # ExpenseService.java (Business logic)
│   │   ├── util/         # DBConnection.java, EnvConfig.java (Utilities)
│   │   └── app/          # MainApp.java (Application entry point)
│   │
│   └── src/main/resources/
│       ├── .env              # Database configuration
│       ├── .env.example      # Configuration template
│       ├── logback.xml       # Logging configuration
│       └── export/           # CSV export directory
│
├── 📁 **Project Files** 📄
│   ├── pom.xml           # Maven project configuration
│   ├── README.md         # This documentation
│   └── LICENSE           # License information
│
├── 📁 **Enhanced Features** ✨
│   ├── logs/             # Application and script logs
│   └── target/           # Maven build artifacts
│
└── 🧪 **Testing** 🧪
    └── src/test/         # Unit tests
```

---

## 🚀 Quick Start

### 1. **Prerequisites Check** ✅
```bash
# Verify Java installation
java -version

# Verify Maven installation
mvn -version

# Verify MySQL is running
mysql --version
```

### 2. **Clone & Setup** ⚡
```bash
# Clone the repository
git clone https://github.com/nawabdev-nak/cli-expense-tracker.git
cd cli-expense-tracker

# Make scripts executable
chmod +x start.sh stop.sh push.sh

# Quick start (includes all setup)
./start.sh
```

### 3. **Database Auto-Setup** 🗄️
The application automatically creates:
- Database: `expense_tracker`
- Tables: `expenses` with proper schema
- User permissions and configurations

---

## 📖 Detailed Setup

### System Requirements

| Component | Minimum | Recommended | Installation |
|-----------|---------|-------------|--------------|
| **Java JDK** | 17 | 21+ | [OpenJDK Download](https://openjdk.java.net/install/) |
| **Maven** | 3.6 | 3.9+ | [Maven Download](https://maven.apache.org/install.html) |
| **MySQL** | 5.7 | 8.0+ | [MySQL Download](https://dev.mysql.com/downloads/mysql/) |
| **Git** | 2.0+ | Latest | [Git Download](https://git-scm.com/downloads) |

### Database Configuration

#### Option 1: Automatic Setup (Recommended)
The application handles database setup automatically when you run `./start.sh`

#### Option 2: Manual Setup
```sql
-- Create database
CREATE DATABASE expense_tracker CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user (replace with your credentials)
CREATE USER 'expense_user'@'localhost' IDENTIFIED BY 'SecurePassword123!';

-- Grant permissions
GRANT ALL PRIVILEGES ON expense_tracker.* TO 'expense_user'@'localhost';

-- Create expenses table
USE expense_tracker;
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_date (date),
    INDEX idx_category (category),
    INDEX idx_amount (amount)
);

FLUSH PRIVILEGES;
```

### Environment Configuration

Update `src/main/resources/.env`:
```env
# Database Configuration
DB_URL=jdbc:mysql://localhost:3306/expense_tracker?useSSL=false&serverTimezone=UTC
DB_USER=expense_user
DB_PASSWORD=SecurePassword123!
DB_MAX_CONNECTIONS=10

# Application Configuration
APP_NAME=CLI Expense Tracker
APP_VERSION=2.0.0
LOG_LEVEL=INFO
EXPORT_PATH=src/main/resources/export/

# Performance Settings
BATCH_SIZE=1000
MAX_MEMORY=512m
```

---

## 💻 Usage Guide

### Application Interface

Once started, the application provides an interactive menu:

```
╔══════════════════════════════════════════════════╗
║          💰 CLI Expense Tracker v2.0          ║
║              Personal Finance Manager           ║
╚══════════════════════════════════════════════════╝

📋 Main Menu:
1. ➕ Add New Expense
2. 👁️  View All Expenses
3. 🔍 Search/Filter Expenses
4. ✏️  Update Expense
5. 🗑️  Delete Expense
6. 📊 View Summary Reports
7. 📈 Export to CSV
8. ⚙️  Settings
9. ❓ Help
0. 🚪 Exit

Enter your choice (0-9):
```

### Adding Your First Expense

1. Select option `1` (Add New Expense)
2. Enter expense details:
   - Amount: `25.50`
   - Date: `2024-01-15` (or press Enter for today)
   - Category: `Food & Dining`
   - Description: `Lunch at restaurant`

### Viewing and Filtering

- **View All**: Option `2` shows all expenses with pagination
- **Filter by Category**: Use option `3` and select category filter
- **Date Range**: Filter expenses between specific dates
- **Amount Range**: Find expenses within budget limits

### Export Features

- **Export All**: Export complete expense history
- **Filtered Export**: Export only specific categories or date ranges
- **Custom Format**: Configurable CSV formatting options

---

## 🔧 Management Scripts

### 🚀 Enhanced Start Script (`start.sh`)

**Basic Usage:**
```bash
./start.sh                    # Normal start with compilation
./start.sh --help             # Show all options
```

**Advanced Options:**
```bash
./start.sh --skip-compile     # Start without recompiling
./start.sh --clean           # Clean build then start
./start.sh --debug           # Debug mode with verbose output
./start.sh --no-log          # Disable file logging
```

**Features:**
- ✅ Pre-flight dependency checks
- ✅ Java version validation (21+ recommended)
- ✅ Maven build verification
- ✅ Database connectivity testing
- ✅ Comprehensive error reporting
- ✅ Process management with PID tracking
- ✅ Colored output and progress indicators

### 🛑 Enhanced Stop Script (`stop.sh`)

**Basic Usage:**
```bash
./stop.sh                     # Interactive cleanup
./stop.sh --help              # Show all options
```

**Advanced Options:**
```bash
./stop.sh --force            # Force kill all processes
./stop.sh --clean            # Clean build artifacts
./stop.sh --backup           # Create backup before cleanup
./stop.sh --status           # Show status only (no cleanup)
```

**Features:**
- ✅ Graceful process shutdown
- ✅ Force kill with confirmation
- ✅ Automated backup creation
- ✅ System resource monitoring
- ✅ Export directory management
- ✅ Database connectivity status
- ✅ Log file management

### 📤 Enhanced Git Push Script (`push.sh`)

**Basic Usage:**
```bash
./push.sh "commit message"    # Push with commit message
./push.sh --help              # Show all options
```

**Advanced Options:**
```bash
./push.sh --pull "message"    # Pull then push
./push.sh --status            # Show git status only
./push.sh --branch develop    # Work with different branch
./push.sh --force             # Force push (use carefully)
```

**Features:**
- ✅ Automatic branch management
- ✅ Pre-push validation
- ✅ Commit message handling
- ✅ Remote repository management
- ✅ Git status reporting
- ✅ Conflict detection and resolution guidance

---

## 🔍 Troubleshooting

### Common Issues & Solutions

#### 🚫 **"Java not found" Error**
```bash
# Check Java installation
java -version

# If not found, install OpenJDK 21+
sudo apt update
sudo apt install openjdk-21-jdk
```

#### 🚫 **"Maven not found" Error**
```bash
# Install Maven
sudo apt install maven

# Or download manually
wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
```

#### 🚫 **Database Connection Failed**
```bash
# Check MySQL service
sudo systemctl status mysql

# Test connection manually
mysql -u username -p -e "USE expense_tracker; SELECT 1;"

# Verify .env configuration
cat src/main/resources/.env
```

#### 🚫 **Permission Denied on Scripts**
```bash
# Make scripts executable
chmod +x start.sh stop.sh push.sh

# Or run with bash explicitly
bash start.sh
```

### Debug Mode

Enable debug mode for detailed logging:

```bash
# Start in debug mode
./start.sh --debug

# Stop with verbose output
./stop.sh --debug

# Push with detailed git information
./push.sh --debug "commit message"
```

### Log Files

All scripts create detailed logs in the `logs/` directory:
- `logs/startup.log` - Application startup information
- `logs/shutdown.log` - Application shutdown and cleanup
- `logs/git.log` - Git operations and push information

### Performance Issues

**High Memory Usage:**
```bash
# Check memory usage
./stop.sh --status

# Optimize Java memory settings in .env
MAX_MEMORY=256m
```

**Slow Database Queries:**
```bash
# Check database performance
mysql -u username -p -e "SHOW PROCESSLIST;"

# Optimize with indexes (if needed)
mysql -u username -p expense_tracker -e "ANALYZE TABLE expenses;"
```

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Make** your changes with proper documentation
4. **Test** thoroughly using the management scripts
5. **Commit** with clear messages: `./push.sh "Add amazing feature"`
6. **Push** and create a Pull Request

### Code Standards

- Follow Java naming conventions
- Add comments for complex logic
- Update documentation for new features
- Test all changes with the enhanced scripts
- Ensure backward compatibility

### Testing

```bash
# Run unit tests
mvn test

# Test application startup
./start.sh --debug

# Test all management scripts
./stop.sh --status
./push.sh --status
```

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**💡 Found this project helpful? Give it a ⭐️ star!**

[🔗 Repository](https://github.com/nawabdev-nak/cli-expense-tracker) •
[🐛 Issues](https://github.com/nawabdev-nak/cli-expense-tracker/issues) •
[💬 Discussions](https://github.com/nawabdev-nak/cli-expense-tracker/discussions)

*Built with ❤️ using Java, Maven, and MySQL*

</div>
