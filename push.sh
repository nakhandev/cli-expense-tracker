#!/bin/bash

# CLI Expense Tracker - Enhanced Git Push Script
# This script provides comprehensive git operations for the CLI Expense Tracker project

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
LOG_FILE="logs/git.log"
CREATE_LOG_DIR=true
DEFAULT_BRANCH="main"
REMOTE_NAME="origin"

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
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 📤 CLI Expense Tracker v2.0                 ║"
    echo "║                  Enhanced Git Push Script                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [MESSAGE]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -b, --branch BRANCH Specify branch (default: main)"
    echo "  -r, --remote REMOTE Specify remote (default: origin)"
    echo "  -p, --pull          Pull changes before pushing"
    echo "  -f, --force         Force push (use with caution)"
    echo "  -s, --status        Show git status only"
    echo "  -d, --debug         Enable debug mode with verbose output"
    echo "  --no-log           Disable logging to file"
    echo ""
    echo "Examples:"
    echo "  $0 \"Fixed database connection bug\"    Push with commit message"
    echo "  $0 --pull \"Added new features\"       Pull then push"
    echo "  $0 --status                           Show git status"
    echo "  $0 --branch develop --pull            Work with develop branch"
}

# Parse command line arguments
BRANCH="$DEFAULT_BRANCH"
REMOTE="$REMOTE_NAME"
PULL_FIRST=false
FORCE_PUSH=false
STATUS_ONLY=false
DEBUG_MODE=false
ENABLE_LOGGING=true
COMMIT_MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -r|--remote)
            REMOTE="$2"
            shift 2
            ;;
        -p|--pull)
            PULL_FIRST=true
            shift
            ;;
        -f|--force)
            FORCE_PUSH=true
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
        -*)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$COMMIT_MESSAGE" ]; then
                COMMIT_MESSAGE="$1"
            else
                COMMIT_MESSAGE="$COMMIT_MESSAGE $1"
            fi
            shift
            ;;
    esac
done

print_banner

# Navigate to the project directory
cd "$(dirname "$0")"
log "INFO" "Git push script started from $(pwd)"

# Check if git is installed
log "INFO" "Checking git installation..."
if ! command -v git &> /dev/null; then
    log "ERROR" "Git is not installed"
    echo -e "${RED}❌ Error: Git is not installed. Please install Git to use this script.${NC}"
    exit 1
fi

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    log "ERROR" "Not in a git repository"
    echo -e "${RED}❌ Error: Not in a git repository. Please run this script from the project root.${NC}"
    exit 1
fi

log "INFO" "Git repository found"
echo -e "${GREEN}✅ Git repository detected${NC}"

# Show current git status
echo ""
echo -e "${BLUE}📋 Current Git Status:${NC}"
git status --porcelain | head -20
STATUS_LINES=$(git status --porcelain | wc -l)

if [ "$STATUS_LINES" -eq 0 ]; then
    echo -e "${YELLOW}📭 No changes detected${NC}"
    log "INFO" "No changes in working directory"
else
    echo -e "${CYAN}📝 $STATUS_LINES change(s) detected${NC}"
fi

# Show current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${PURPLE}🌿 Current branch: $CURRENT_BRANCH${NC}"

# Check if we're on the expected branch
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo -e "${YELLOW}⚠️  Warning: Currently on branch '$CURRENT_BRANCH', but targeting '$BRANCH'${NC}"
    read -p "   Switch to branch '$BRANCH'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "INFO" "Switching to branch: $BRANCH"
        echo -e "${BLUE}🔄 Switching to branch: $BRANCH${NC}"
        if ! git checkout "$BRANCH" 2>/dev/null; then
            log "ERROR" "Failed to checkout branch: $BRANCH"
            echo -e "${RED}❌ Error: Failed to checkout branch '$BRANCH'${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Switched to branch: $BRANCH${NC}"
    else
        echo -e "${YELLOW}⏭️  Staying on current branch: $CURRENT_BRANCH${NC}"
        BRANCH="$CURRENT_BRANCH"
    fi
fi

# Show status only if requested
if [ "$STATUS_ONLY" = true ]; then
    echo ""
    echo -e "${CYAN}🔍 Detailed Git Status:${NC}"
    git status
    echo ""
    echo -e "${BLUE}🌿 Branch Information:${NC}"
    git branch -vv
    echo ""
    echo -e "${PURPLE}📊 Remote Information:${NC}"
    git remote -v
    log "INFO" "Status check completed"
    echo -e "${GREEN}✅ Status check completed${NC}"
    exit 0
fi

# Pull changes if requested
if [ "$PULL_FIRST" = true ]; then
    echo ""
    echo -e "${BLUE}⬇️  Pulling latest changes from $REMOTE/$BRANCH...${NC}"
    if git pull "$REMOTE" "$BRANCH"; then
        echo -e "${GREEN}✅ Successfully pulled changes${NC}"
        log "INFO" "Successfully pulled from $REMOTE/$BRANCH"
    else
        log "ERROR" "Failed to pull from $REMOTE/$BRANCH"
        echo -e "${RED}❌ Error: Failed to pull changes. Please resolve conflicts manually.${NC}"
        exit 1
    fi
fi

# Check if there are changes to commit
if [ "$STATUS_LINES" -eq 0 ] && [ -z "$COMMIT_MESSAGE" ]; then
    log "INFO" "No changes to commit"
    echo -e "${YELLOW}📭 No changes to commit. Use --pull to fetch latest changes.${NC}"
    exit 0
fi

# Get commit message if not provided
if [ -z "$COMMIT_MESSAGE" ]; then
    echo ""
    echo -e "${YELLOW}📝 Please provide a commit message:${NC}"
    read -p "   Commit message: " COMMIT_MESSAGE

    if [ -z "$COMMIT_MESSAGE" ]; then
        log "ERROR" "Empty commit message"
        echo -e "${RED}❌ Error: Commit message cannot be empty${NC}"
        exit 1
    fi
fi

# Validate commit message format
if [[ $COMMIT_MESSAGE =~ ^[[:space:]]*$ ]]; then
    log "ERROR" "Invalid commit message format"
    echo -e "${RED}❌ Error: Invalid commit message format${NC}"
    exit 1
fi

log "INFO" "Using commit message: $COMMIT_MESSAGE"

# Stage all changes
echo ""
echo -e "${BLUE}📦 Staging all changes...${NC}"
if git add .; then
    echo -e "${GREEN}✅ Changes staged successfully${NC}"
    log "INFO" "Changes staged successfully"
else
    log "ERROR" "Failed to stage changes"
    echo -e "${RED}❌ Error: Failed to stage changes${NC}"
    exit 1
fi

# Commit changes
echo ""
echo -e "${PURPLE}💾 Committing changes...${NC}"
COMMIT_OUTPUT=$(git commit -m "$COMMIT_MESSAGE" 2>&1)
COMMIT_EXIT_CODE=$?

if [ $COMMIT_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Changes committed successfully${NC}"
    log "INFO" "Changes committed: $COMMIT_MESSAGE"

    # Show commit details
    COMMIT_HASH=$(git rev-parse HEAD)
    echo -e "${CYAN}📋 Commit: $COMMIT_HASH${NC}"
    echo "$COMMIT_OUTPUT" | grep -E "([0-9]+ file(s)? changed|[0-9]+ insertion(s)?|[0-9]+ deletion(s)?)" || true
else
    # Check if there were no changes to commit
    if echo "$COMMIT_OUTPUT" | grep -q "nothing to commit"; then
        echo -e "${YELLOW}📭 Nothing to commit - working tree is clean${NC}"
        log "INFO" "Nothing to commit - working tree clean"
        exit 0
    else
        log "ERROR" "Failed to commit changes: $COMMIT_OUTPUT"
        echo -e "${RED}❌ Error: Failed to commit changes${NC}"
        echo "$COMMIT_OUTPUT"
        exit 1
    fi
fi

# Push changes
echo ""
if [ "$FORCE_PUSH" = true ]; then
    echo -e "${RED}🚨 Force pushing to $REMOTE/$BRANCH...${NC}"
    PUSH_COMMAND="git push --force-with-lease $REMOTE $BRANCH"
else
    echo -e "${BLUE}⬆️  Pushing to $REMOTE/$BRANCH...${NC}"
    PUSH_COMMAND="git push $REMOTE $BRANCH"
fi

if eval "$PUSH_COMMAND"; then
    echo -e "${GREEN}✅ Successfully pushed to $REMOTE/$BRANCH${NC}"
    log "INFO" "Successfully pushed to $REMOTE/$BRANCH"

    # Show remote repository URL if available
    REMOTE_URL=$(git remote get-url "$REMOTE" 2>/dev/null || echo "unknown")
    if [ "$REMOTE_URL" != "unknown" ]; then
        echo -e "${CYAN}🔗 Remote URL: $REMOTE_URL${NC}"
    fi
else
    log "ERROR" "Failed to push to $REMOTE/$BRANCH"
    echo -e "${RED}❌ Error: Failed to push changes${NC}"
    echo -e "${YELLOW}💡 Possible causes:${NC}"
    echo "   - No internet connection"
    echo "   - Remote repository doesn't exist"
    echo "   - Authentication required (setup SSH keys or login to Git)"
    echo "   - Branch protection rules"
    exit 1
fi

# Show final status
echo ""
echo -e "${GREEN}🎉 Git operations completed successfully!${NC}"
echo -e "${PURPLE}📋 Summary:${NC}"
echo "   ✅ Branch: $BRANCH"
echo "   ✅ Remote: $REMOTE"
echo "   ✅ Commit: $(git rev-parse --short HEAD)"
echo "   ✅ Message: $COMMIT_MESSAGE"

# Show recent commits
echo ""
echo -e "${BLUE}📜 Recent commits:${NC}"
git log --oneline -5

log "INFO" "Git push script completed successfully"
echo ""
echo -e "${GREEN}✨ Push script completed! Your changes are now on GitHub.${NC}"
