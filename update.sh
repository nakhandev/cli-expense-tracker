#!/bin/bash

# ==============================
# CLI Expense Tracker Git Updater
# ==============================

# Go to project folder (optional if running inside the folder)
# cd /path/to/cli-expense-tracker

# Pull latest changes from GitHub
echo "Pulling latest changes..."
git pull origin main

# Ask for commit message
read -p "Enter commit message: " commit_message

# Stage all changes
git add .

# Commit changes
git commit -m "$commit_message"

# Push to GitHub
git push origin main

echo "✅ Update complete! Your changes are now on GitHub."
