#!/bin/bash

# CLI Expense Tracker - Start Script
# This script compiles and runs the CLI Expense Tracker application

echo "🚀 Starting CLI Expense Tracker..."
echo "================================="

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Error: Maven is not installed. Please install Maven to run this application."
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java is not installed. Please install Java 21+ to run this application."
    exit 1
fi

# Navigate to the project directory
cd "$(dirname "$0")"

echo "📦 Compiling application..."
if ! mvn compile > /dev/null 2>&1; then
    echo "❌ Error: Failed to compile the application."
    echo "   Please check the Maven configuration and dependencies."
    exit 1
fi

echo "✅ Compilation successful!"

echo ""
echo "🎯 Starting CLI Expense Tracker..."
echo "   Press Ctrl+C to stop the application"
echo ""

# Run the application
java -cp target/classes:$(mvn dependency:build-classpath -q -Dmdep.outputFile=/dev/stdout) org.expense.tracker.app.MainApp

echo ""
echo "👋 CLI Expense Tracker stopped."
