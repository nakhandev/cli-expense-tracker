#!/bin/bash

# CLI Expense Tracker - Stop Script
# This script helps with cleanup and stopping any running instances

echo "🛑 CLI Expense Tracker - Stop Script"
echo "==================================="

# Navigate to the project directory
cd "$(dirname "$0")"

echo "🔍 Checking for running Java processes..."
# Find any Java processes that might be running the expense tracker
JAVA_PROCESSES=$(ps aux | grep "org.expense.tracker.app.MainApp" | grep -v grep)

if [ -z "$JAVA_PROCESSES" ]; then
    echo "✅ No running CLI Expense Tracker processes found."
else
    echo "📋 Found running processes:"
    echo "$JAVA_PROCESSES"
    echo ""
    echo "💡 To stop the application:"
    echo "   - If running interactively: Press Ctrl+C in the terminal"
    echo "   - To force kill (use carefully): killall java"
fi

echo ""
echo "🧹 Performing cleanup tasks..."

# Clean Maven target directory (optional cleanup)
if [ -d "target" ]; then
    echo "📁 Maven target directory found."
    read -p "   Remove target directory? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf target
        echo "   ✅ Target directory removed."
    else
        echo "   ⏭️  Target directory kept."
    fi
fi

# Show export directory contents
if [ -d "src/main/resources/export" ]; then
    EXPORT_COUNT=$(ls src/main/resources/export/*.csv 2>/dev/null | wc -l)
    if [ "$EXPORT_COUNT" -gt 0 ]; then
        echo "📊 Export directory contains $EXPORT_COUNT CSV file(s)."
        ls -la src/main/resources/export/
    else
        echo "📊 Export directory is empty."
    fi
fi

echo ""
echo "📋 Application Status:"
echo "   - Configuration: $(ls src/main/resources/.env 2>/dev/null && echo '✅ Present' || echo '❌ Missing')"
echo "   - Database: $(mysql -u nakhan -pLinux@1998 -e "USE expense_tracker; SELECT COUNT(*) as count FROM expenses;" 2>/dev/null | tail -n1 | sed 's/count //' && echo ' records' || echo '❌ Connection failed')"
echo ""
echo "✨ Stop script completed."
