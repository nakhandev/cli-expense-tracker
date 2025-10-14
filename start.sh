#!/bin/bash

# CLI Expense Tracker - Enhanced Start Script
# This script compiles and runs the CLI Expense Tracker application with enhanced features

set -e  # Exit on any error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="logs/startup.log"
CREATE_LOG_DIR=true

# Create log directory if it doesn't exist
if [ "$CREATE_LOG_DIR" = true ] && [ ! -d "logs" ]; then
    mkdir -p logs
fi

# Logging function
log() {
    local level=$1
    shift
    local message=$@
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [$level] $message" | tee -a "$LOG_FILE"
}

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 🚀 CLI Expense Tracker v2.0                 ║"
    echo "║                    Enhanced Start Script                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -s, --skip-compile  Skip Maven compilation (use existing build)"
    echo "  -d, --debug         Enable debug mode with verbose output"
    echo "  -c, --clean         Clean Maven build before compiling"
    echo "  --no-log           Disable logging to file"
    echo ""
    echo "Examples:"
    echo "  $0                  Start with normal compilation"
    echo "  $0 --skip-compile   Start without recompiling"
    echo "  $0 --clean          Clean build before starting"
}

# Parse command line arguments
SKIP_COMPILE=false
DEBUG_MODE=false
CLEAN_BUILD=false
ENABLE_LOGGING=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--skip-compile)
            SKIP_COMPILE=true
            shift
            ;;
        -d|--debug)
            DEBUG_MODE=true
            set -x
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        --no-log)
            ENABLE_LOGGING=false
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

print_banner

# Navigate to the project directory
cd "$(dirname "$0")"
log "INFO" "Starting CLI Expense Tracker from $(pwd)"

# Check if Maven is installed
log "INFO" "Checking Maven installation..."
if ! command -v mvn &> /dev/null; then
    log "ERROR" "Maven is not installed"
    echo -e "${RED}❌ Error: Maven is not installed. Please install Maven to run this application.${NC}"
    exit 1
fi
log "INFO" "Maven version: $(mvn -v | head -n1)"

# Check if Java is installed
log "INFO" "Checking Java installation..."
if ! command -v java &> /dev/null; then
    log "ERROR" "Java is not installed"
    echo -e "${RED}❌ Error: Java is not installed. Please install Java 21+ to run this application.${NC}"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | sed 's/^1\.//' | cut -d'.' -f1)
log "INFO" "Java version: $(java -version 2>&1 | head -n1)"

if [ "$JAVA_VERSION" -lt 21 ]; then
    log "WARNING" "Java version $JAVA_VERSION is below recommended 21"
    echo -e "${YELLOW}⚠️  Warning: Java version $JAVA_VERSION is below recommended 21${NC}"
fi

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    log "INFO" "Cleaning Maven build..."
    echo -e "${YELLOW}🧹 Cleaning previous build...${NC}"
    if ! mvn clean > /dev/null 2>&1; then
        log "ERROR" "Failed to clean Maven build"
        echo -e "${RED}❌ Error: Failed to clean Maven build.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Build cleaned successfully${NC}"
fi

# Compile application unless skipped
if [ "$SKIP_COMPILE" = false ]; then
    log "INFO" "Compiling application..."
    echo -e "${BLUE}📦 Compiling application...${NC}"

    if ! mvn compile > /dev/null 2>&1; then
        log "ERROR" "Failed to compile application"
        echo -e "${RED}❌ Error: Failed to compile the application.${NC}"
        echo -e "${YELLOW}💡 Please check the Maven configuration and dependencies.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Compilation successful!${NC}"
    log "INFO" "Application compiled successfully"
else
    log "INFO" "Skipping compilation as requested"
    echo -e "${YELLOW}⏭️  Skipping compilation${NC}"
fi

# Check if target directory exists and has class files
if [ ! -d "target/classes" ] || [ ! "$(ls -A target/classes 2>/dev/null)" ]; then
    log "ERROR" "No compiled classes found"
    echo -e "${RED}❌ Error: No compiled classes found. Please compile the application first.${NC}"
    exit 1
fi

# Check if main class exists
MAIN_CLASS="org.expense.tracker.app.MainApp"
if [ ! -f "target/classes/$(echo $MAIN_CLASS | tr '.' '/')/MainApp.class" ]; then
    log "ERROR" "Main class not found: $MAIN_CLASS"
    echo -e "${RED}❌ Error: Main class not found. Please compile the application first.${NC}"
    exit 1
fi

# Build classpath
log "INFO" "Building classpath..."
CLASSPATH="target/classes:$(mvn dependency:build-classpath -q -Dmdep.outputFile=/dev/stdout 2>/dev/null || echo '')"

# Check database connectivity (optional)
log "INFO" "Checking database connectivity..."
if [ -f "src/main/resources/.env" ]; then
    # Simple check if we can connect to database
    if mysql --defaults-extra-file=src/main/resources/.env -e "USE expense_tracker; SELECT 1;" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Database connection successful${NC}"
        log "INFO" "Database connection verified"
    else
        echo -e "${YELLOW}⚠️  Database connection failed - application may not work properly${NC}"
        log "WARNING" "Database connection failed"
    fi
fi

echo ""
echo -e "${PURPLE}🎯 Starting CLI Expense Tracker...${NC}"
echo -e "${CYAN}   Press Ctrl+C to stop the application${NC}"
echo ""

# Start application with proper signal handling
cleanup() {
    echo ""
    echo -e "${BLUE}👋 Shutting down CLI Expense Tracker...${NC}"
    log "INFO" "Application stopped by user"
    exit 0
}

trap cleanup SIGINT SIGTERM

log "INFO" "Starting main application: $MAIN_CLASS"
java -cp "$CLASSPATH" "$MAIN_CLASS" &
APP_PID=$!

log "INFO" "Application started with PID: $APP_PID"
echo -e "${GREEN}🚀 Application started successfully (PID: $APP_PID)${NC}"

# Wait for application to finish
wait $APP_PID
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log "INFO" "Application exited normally"
    echo -e "${GREEN}✅ CLI Expense Tracker stopped normally${NC}"
else
    log "ERROR" "Application exited with error code: $EXIT_CODE"
    echo -e "${RED}❌ CLI Expense Tracker stopped with error (Code: $EXIT_CODE)${NC}"
fi
