#!/bin/bash

# CLI Expense Tracker - Enhanced Stop Script
# This script provides comprehensive cleanup and process management for the CLI Expense Tracker

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
LOG_FILE="logs/shutdown.log"
CREATE_LOG_DIR=true
DEFAULT_DB_USER="nakhan"
DEFAULT_DB_PASSWORD="Linux@1998"
DB_NAME="expense_tracker"

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
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 🛑 CLI Expense Tracker v2.0                 ║"
    echo "║                   Enhanced Stop Script                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -f, --force         Force kill all Java processes"
    echo "  -c, --clean         Clean Maven build artifacts"
    echo "  -b, --backup        Create backup before cleanup"
    echo "  -s, --status        Show detailed status only (no cleanup)"
    echo "  -d, --debug         Enable debug mode with verbose output"
    echo "  --no-log           Disable logging to file"
    echo ""
    echo "Examples:"
    echo "  $0                  Interactive cleanup with prompts"
    echo "  $0 --force          Force stop all processes"
    echo "  $0 --status         Show status without cleanup"
}

# Parse command line arguments
FORCE_KILL=false
CLEAN_BUILD=false
CREATE_BACKUP=false
STATUS_ONLY=false
DEBUG_MODE=false
ENABLE_LOGGING=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE_KILL=true
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -b|--backup)
            CREATE_BACKUP=true
            shift
            ;;
        -s|--status)
            STATUS_ONLY=true
            shift
            ;;
        -d|--debug)
            DEBUG_MODE=true
            set -x
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
log "INFO" "Stop script started from $(pwd)"

# Function to check if process is running
check_process() {
    ps aux | grep -v grep | grep -q "org.expense.tracker.app.MainApp"
}

# Function to get process details
get_process_details() {
    ps aux | grep "org.expense.tracker.app.MainApp" | grep -v grep
}

# Function to kill processes gracefully
graceful_shutdown() {
    local pids=$(pgrep -f "org.expense.tracker.app.MainApp")
    if [ ! -z "$pids" ]; then
        echo -e "${YELLOW}🔄 Attempting graceful shutdown...${NC}"
        for pid in $pids; do
            if kill -TERM "$pid" 2>/dev/null; then
                echo -e "${BLUE}📤 Sent SIGTERM to process $pid${NC}"
                # Wait up to 10 seconds for graceful shutdown
                for i in {1..10}; do
                    if ! kill -0 "$pid" 2>/dev/null; then
                        echo -e "${GREEN}✅ Process $pid stopped gracefully${NC}"
                        return 0
                    fi
                    sleep 1
                done
                echo -e "${YELLOW}⚠️  Process $pid didn't respond to SIGTERM${NC}"
                return 1
            fi
        done
    fi
    return 0
}

# Function to force kill processes
force_kill_processes() {
    local pids=$(pgrep -f "org.expense.tracker.app.MainApp")
    if [ ! -z "$pids" ]; then
        echo -e "${RED}🔨 Force killing processes...${NC}"
        for pid in $pids; do
            if kill -9 "$pid" 2>/dev/null; then
                echo -e "${RED}💀 Force killed process $pid${NC}"
                log "WARNING" "Force killed process $pid"
            fi
        done
    fi
}

# Check for running processes
echo -e "${BLUE}🔍 Checking for running Java processes...${NC}"

if check_process; then
    PROCESS_DETAILS=$(get_process_details)
    echo -e "${PURPLE}📋 Found running CLI Expense Tracker processes:${NC}"
    echo "$PROCESS_DETAILS"
    echo ""

    if [ "$STATUS_ONLY" = true ]; then
        log "INFO" "Status check completed - processes are running"
        echo -e "${GREEN}✅ Status check completed${NC}"
        exit 0
    fi

    if [ "$FORCE_KILL" = true ]; then
        force_kill_processes
    else
        # Attempt graceful shutdown first
        if ! graceful_shutdown; then
            echo -e "${YELLOW}🔄 Graceful shutdown failed, attempting force kill...${NC}"
            read -p "   Force kill the processes? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                force_kill_processes
            else
                echo -e "${YELLOW}⏭️  Keeping processes running${NC}"
            fi
        fi
    fi
else
    echo -e "${GREEN}✅ No running CLI Expense Tracker processes found.${NC}"
    log "INFO" "No running processes found"
fi

# Create backup if requested
if [ "$CREATE_BACKUP" = true ]; then
    echo ""
    echo -e "${BLUE}💾 Creating backup...${NC}"
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    if mkdir -p "$BACKUP_DIR"; then
        # Backup important directories
        if [ -d "src/main/resources/export" ]; then
            cp -r src/main/resources/export "$BACKUP_DIR/" 2>/dev/null || true
        fi
        if [ -d "logs" ]; then
            cp -r logs "$BACKUP_DIR/" 2>/dev/null || true
        fi
        echo -e "${GREEN}✅ Backup created: $BACKUP_DIR${NC}"
        log "INFO" "Backup created: $BACKUP_DIR"
    else
        echo -e "${RED}❌ Failed to create backup directory${NC}"
        log "ERROR" "Failed to create backup directory"
    fi
fi

# Clean Maven target directory if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo ""
    echo -e "${YELLOW}🧹 Cleaning Maven build artifacts...${NC}"
    if [ -d "target" ]; then
        echo -e "${BLUE}📁 Removing target directory...${NC}"
        if rm -rf target; then
            echo -e "${GREEN}✅ Target directory removed${NC}"
            log "INFO" "Target directory cleaned"
        else
            echo -e "${RED}❌ Failed to remove target directory${NC}"
            log "ERROR" "Failed to remove target directory"
        fi
    else
        echo -e "${YELLOW}📁 Target directory not found${NC}"
    fi
fi

# Show export directory contents
echo ""
echo -e "${CYAN}📊 Export Directory Status:${NC}"
if [ -d "src/main/resources/export" ]; then
    EXPORT_FILES=$(ls src/main/resources/export/*.csv 2>/dev/null | wc -l)
    if [ "$EXPORT_FILES" -gt 0 ]; then
        echo -e "${GREEN}✅ Export directory contains $EXPORT_FILES CSV file(s)${NC}"
        ls -la src/main/resources/export/
        log "INFO" "Export directory contains $EXPORT_FILES files"
    else
        echo -e "${YELLOW}📁 Export directory is empty${NC}"
    fi
else
    echo -e "${RED}❌ Export directory not found${NC}"
fi

# Show application status
echo ""
echo -e "${PURPLE}📋 Application Status:${NC}"

# Configuration check
if [ -f "src/main/resources/.env" ]; then
    echo -e "${GREEN}✅ Configuration file: Present${NC}"
    log "INFO" "Configuration file found"
else
    echo -e "${RED}❌ Configuration file: Missing${NC}"
    log "WARNING" "Configuration file missing"
fi

# Database check
echo -e "${BLUE}🔍 Checking database connectivity...${NC}"
DB_CHECK=$(mysql -u "$DEFAULT_DB_USER" -p"$DEFAULT_DB_PASSWORD" -e "USE $DB_NAME; SELECT COUNT(*) as count FROM expenses;" 2>/dev/null | tail -n1 | sed 's/count //')

if [ $? -eq 0 ] && [ ! -z "$DB_CHECK" ]; then
    echo -e "${GREEN}✅ Database: Connected ($DB_CHECK records)${NC}"
    log "INFO" "Database connection successful - $DB_CHECK records found"
else
    echo -e "${RED}❌ Database: Connection failed${NC}"
    log "ERROR" "Database connection failed"
fi

# System resource usage
echo ""
echo -e "${CYAN}🖥️  System Resource Usage:${NC}"
echo "   Memory: $(free -h | awk 'NR==2{printf "%.1fGB/%.1fGB (%.0f%%)", $3/1024, $2/1024, $3*100/$2}')"
echo "   Disk: $(df -h . | awk 'NR==2{print $3"/"$2" ("$5" used)"}')"
echo "   Load: $(uptime | awk -F'load average:' '{print $2}')"

# Log directory status
if [ -d "logs" ]; then
    LOG_COUNT=$(find logs -name "*.log" -type f | wc -l)
    LOG_SIZE=$(du -sh logs 2>/dev/null | cut -f1)
    echo -e "${BLUE}📝 Log files: $LOG_COUNT files ($LOG_SIZE)${NC}"
fi

echo ""
echo -e "${GREEN}✨ Stop script completed successfully!${NC}"
log "INFO" "Stop script completed"
