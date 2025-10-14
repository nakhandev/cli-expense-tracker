#!/bin/bash

# CLI Expense Tracker - Enhanced Git Push Script with Advanced Features
# This script provides comprehensive git operations with professional project management features

set -e  # Exit on any error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="logs/git-enhanced.log"
CREATE_LOG_DIR=true
DEFAULT_BRANCH="main"
REMOTE_NAME="origin"
BACKUP_DIR="backup/pre-push"
ENABLE_BACKUP=true

# Create necessary directories
if [ "$CREATE_LOG_DIR" = true ] && [ ! -d "logs" ]; then
    mkdir -p logs
fi
if [ "$ENABLE_BACKUP" = true ] && [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Enhanced logging function
log() {
    local level=$1
    shift
    local message=$@
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [$level] $message" | tee -a "$LOG_FILE"
}

# Print enhanced banner
print_banner() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            📤 CLI Expense Tracker v2.0 - Enhanced            ║"
    echo "║             Advanced Git Push Script with Pro Features       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Enhanced help function
show_help() {
    echo -e "${BLUE}Enhanced Git Push Script - Professional Features${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS] [MESSAGE]"
    echo ""
    echo -e "${YELLOW}Core Options:${NC}"
    echo "  -h, --help          Show this help message"
    echo "  -b, --branch BRANCH Specify branch (default: main)"
    echo "  -r, --remote REMOTE Specify remote (default: origin)"
    echo "  -p, --pull          Pull changes before pushing"
    echo "  -f, --force         Force push (use with caution)"
    echo "  -s, --status        Show git status only"
    echo "  -d, --debug         Enable debug mode with verbose output"
    echo "  --no-log           Disable logging to file"
    echo ""
    echo -e "${GREEN}Enhanced Features:${NC}"
    echo "  -t, --tag           Create version tag automatically"
    echo "  -v, --version VER   Specify version for tagging (e.g., v2.0.0)"
    echo "  -c, --changelog     Generate changelog from commits"
    echo "  -k, --backup        Create backup before operations"
    echo "  -u, --validate      Run pre-push validation checks"
    echo "  -m, --maven         Validate Maven build before pushing"
    echo "  --release           Create GitHub release"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0 \"🚀 Release v2.0.0\"                           # Basic push"
    echo "  $0 --tag --version v2.0.0 \"Major release\"       # Push with tag"
    echo "  $0 --validate --maven \"Bug fixes\"                # Push with validation"
    echo "  $0 --backup --changelog \"Feature update\"         # Push with backup & changelog"
    echo "  $0 --release --tag \"Production release\"          # Full release workflow"
}

# Parse command line arguments
BRANCH="$DEFAULT_BRANCH"
REMOTE="$REMOTE_NAME"
PULL_FIRST=false
FORCE_PUSH=false
STATUS_ONLY=false
DEBUG_MODE=false
ENABLE_LOGGING=true
CREATE_TAG=false
SPECIFIED_VERSION=""
GENERATE_CHANGELOG=false
CREATE_BACKUP=false
RUN_VALIDATION=false
VALIDATE_MAVEN=false
CREATE_RELEASE=false
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
        -t|--tag)
            CREATE_TAG=true
            shift
            ;;
        -v|--version)
            SPECIFIED_VERSION="$2"
            CREATE_TAG=true
            shift 2
            ;;
        -c|--changelog)
            GENERATE_CHANGELOG=true
            shift
            ;;
        -k|--backup)
            CREATE_BACKUP=true
            shift
            ;;
        -u|--validate)
            RUN_VALIDATION=true
            shift
            ;;
        -m|--maven)
            VALIDATE_MAVEN=true
            shift
            ;;
        --release)
            CREATE_RELEASE=true
            CREATE_TAG=true
            GENERATE_CHANGELOG=true
            CREATE_BACKUP=true
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
log "INFO" "Enhanced git push script started from $(pwd)"

# Function to create backup
create_backup() {
    if [ "$CREATE_BACKUP" = true ]; then
        echo ""
        echo -e "${BLUE}💾 Creating pre-push backup...${NC}"
        local backup_file="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"

        # Backup important directories and files
        tar -czf "$backup_file" \
            src/ \
            pom.xml \
            README.md \
            .env.example \
            logs/ \
            2>/dev/null || true

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Backup created: $backup_file${NC}"
            log "INFO" "Backup created: $backup_file"
        else
            echo -e "${YELLOW}⚠️  Backup creation warning (some files may be missing)${NC}"
            log "WARNING" "Backup created with warnings"
        fi
    fi
}

# Function to run pre-push validation
run_validation() {
    if [ "$RUN_VALIDATION" = true ]; then
        echo ""
        echo -e "${BLUE}🔍 Running pre-push validation...${NC}"

        local validation_passed=true

        # Check if README.md exists and is not empty
        if [ ! -f "README.md" ] || [ ! -s "README.md" ]; then
            echo -e "${RED}❌ README.md is missing or empty${NC}"
            validation_passed=false
        else
            echo -e "${GREEN}✅ README.md exists${NC}"
        fi

        # Check if pom.xml exists and is valid
        if [ ! -f "pom.xml" ]; then
            echo -e "${RED}❌ pom.xml is missing${NC}"
            validation_passed=false
        else
            echo -e "${GREEN}✅ pom.xml exists${NC}"
        fi

        # Check if main class exists
        if [ ! -f "src/main/java/org/expense/tracker/app/MainApp.java" ]; then
            echo -e "${RED}❌ Main application class is missing${NC}"
            validation_passed=false
        else
            echo -e "${GREEN}✅ Main application class exists${NC}"
        fi

        if [ "$validation_passed" = false ]; then
            echo -e "${RED}❌ Validation failed. Please fix the issues above.${NC}"
            log "ERROR" "Pre-push validation failed"
            exit 1
        else
            echo -e "${GREEN}✅ All validations passed${NC}"
            log "INFO" "Pre-push validation successful"
        fi
    fi
}

# Function to validate Maven build
validate_maven() {
    if [ "$VALIDATE_MAVEN" = true ]; then
        echo ""
        echo -e "${BLUE}📦 Validating Maven build...${NC}"

        # Check if Maven is available
        if ! command -v mvn &> /dev/null; then
            echo -e "${RED}❌ Maven is not installed${NC}"
            log "ERROR" "Maven not found"
            exit 1
        fi

        # Test compilation
        if mvn compile -q > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Maven compilation successful${NC}"
            log "INFO" "Maven compilation validated"
        else
            echo -e "${RED}❌ Maven compilation failed${NC}"
            log "ERROR" "Maven compilation failed"
            exit 1
        fi

        # Test if main class can be found
        if [ -f "target/classes/org/expense/tracker/app/MainApp.class" ]; then
            echo -e "${GREEN}✅ Main class compiled successfully${NC}"
        else
            echo -e "${RED}❌ Main class compilation failed${NC}"
            exit 1
        fi
    fi
}

# Function to generate changelog
generate_changelog() {
    if [ "$GENERATE_CHANGELOG" = true ]; then
        echo ""
        echo -e "${BLUE}📝 Generating changelog...${NC}"

        local changelog_file="CHANGELOG.md"
        local temp_changelog="temp_changelog.md"

        # Get the last 10 commits for changelog
        echo -e "${CYAN}📋 Recent Changes:${NC}" > "$temp_changelog"
        echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$temp_changelog"
        echo "----------------------------------------" >> "$temp_changelog"
        git log --oneline -10 >> "$temp_changelog"
        echo "" >> "$temp_changelog"

        # Prepend to existing changelog or create new one
        if [ -f "$changelog_file" ]; then
            echo "" >> "$temp_changelog"
            cat "$changelog_file" >> "$temp_changelog"
        fi

        mv "$temp_changelog" "$changelog_file"
        echo -e "${GREEN}✅ Changelog updated: $changelog_file${NC}"
        log "INFO" "Changelog generated: $changelog_file"
    fi
}

# Function to create version tag
create_version_tag() {
    if [ "$CREATE_TAG" = true ]; then
        echo ""
        echo -e "${BLUE}🏷️  Creating version tag...${NC}"

        local tag_name
        if [ -n "$SPECIFIED_VERSION" ]; then
            tag_name="$SPECIFIED_VERSION"
        else
            # Auto-generate version tag based on current version in pom.xml
            tag_name="v$(grep -o '<version>[^<]*</version>' pom.xml | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo '2.0.0')"
        fi

        # Check if tag already exists
        if git tag | grep -q "^$tag_name$"; then
            echo -e "${YELLOW}⚠️  Tag $tag_name already exists${NC}"
            read -p "   Overwrite existing tag? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}⏭️  Skipping tag creation${NC}"
                return 0
            fi
        fi

        # Create annotated tag
        if git tag -a "$tag_name" -m "Release $tag_name

$(date '+%Y-%m-%d %H:%M:%S')
CLI Expense Tracker $tag_name

$COMMIT_MESSAGE"; then
            echo -e "${GREEN}✅ Created tag: $tag_name${NC}"
            log "INFO" "Created tag: $tag_name"

            # Push tag to remote
            if git push "$REMOTE" "$tag_name"; then
                echo -e "${GREEN}✅ Pushed tag to remote: $tag_name${NC}"
                log "INFO" "Pushed tag to remote: $tag_name"
            else
                echo -e "${YELLOW}⚠️  Failed to push tag to remote${NC}"
                log "WARNING" "Failed to push tag to remote"
            fi
        else
            echo -e "${RED}❌ Failed to create tag${NC}"
            log "ERROR" "Failed to create tag"
        fi
    fi
}

# Function to create GitHub release
create_github_release() {
    if [ "$CREATE_RELEASE" = true ] && [ "$CREATE_TAG" = true ]; then
        echo ""
        echo -e "${BLUE}🚀 Creating GitHub release...${NC}"

        local tag_name
        if [ -n "$SPECIFIED_VERSION" ]; then
            tag_name="$SPECIFIED_VERSION"
        else
            tag_name="v$(grep -o '<version>[^<]*</version>' pom.xml | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo '2.0.0')"
        fi

        # Check if GitHub CLI is available
        if command -v gh &> /dev/null; then
            # Generate release notes from changelog or commit message
            local release_notes="$COMMIT_MESSAGE"
            if [ -f "CHANGELOG.md" ]; then
                release_notes="CLI Expense Tracker $tag_name

$COMMIT_MESSAGE

$(head -20 CHANGELOG.md)"
            fi

            # Create GitHub release
            if gh release create "$tag_name" \
                --title "CLI Expense Tracker $tag_name" \
                --notes "$release_notes" \
                --latest; then
                echo -e "${GREEN}✅ GitHub release created: $tag_name${NC}"
                log "INFO" "GitHub release created: $tag_name"
            else
                echo -e "${YELLOW}⚠️  Failed to create GitHub release${NC}"
                log "WARNING" "Failed to create GitHub release"
            fi
        else
            echo -e "${YELLOW}⚠️  GitHub CLI not available - skipping release creation${NC}"
            log "WARNING" "GitHub CLI not available"
        fi
    fi
}

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

# Run pre-push validation if requested
run_validation

# Validate Maven build if requested
validate_maven

# Create backup if requested
create_backup

# Generate changelog if requested
generate_changelog

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
    echo -e "${CYAN}🔍 Enhanced Git Status:${NC}"
    git status
    echo ""
    echo -e "${BLUE}🌿 Branch Information:${NC}"
    git branch -vv
    echo ""
    echo -e "${PURPLE}📊 Remote Information:${NC}"
    git remote -v
    echo ""
    echo -e "${GREEN}📋 Recent Commits:${NC}"
    git log --oneline -5
    log "INFO" "Enhanced status check completed"
    echo -e "${GREEN}✅ Enhanced status check completed${NC}"
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

# Create version tag if requested
create_version_tag

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

# Create GitHub release if requested
create_github_release

# Show final enhanced status
echo ""
echo -e "${GREEN}🎉 Enhanced git operations completed successfully!${NC}"
echo -e "${PURPLE}📋 Enhanced Summary:${NC}"
echo "   ✅ Branch: $BRANCH"
echo "   ✅ Remote: $REMOTE"
echo "   ✅ Commit: $(git rev-parse --short HEAD)"
echo "   ✅ Message: $COMMIT_MESSAGE"

if [ "$CREATE_TAG" = true ]; then
    if [ -n "$SPECIFIED_VERSION" ]; then
        echo "   ✅ Tag: $SPECIFIED_VERSION"
    else
        echo "   ✅ Tag: Auto-generated"
    fi
fi

if [ "$GENERATE_CHANGELOG" = true ]; then
    echo "   ✅ Changelog: Updated"
fi

if [ "$CREATE_BACKUP" = true ]; then
    echo "   ✅ Backup: Created"
fi

# Show recent commits
echo ""
echo -e "${BLUE}📜 Recent commits:${NC}"
git log --oneline -5

# Show backup information if created
if [ "$CREATE_BACKUP" = true ]; then
    echo ""
    echo -e "${CYAN}💾 Backup Information:${NC}"
    ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -3 || echo "   No backup files found"
fi

log "INFO" "Enhanced git push script completed successfully"
echo ""
echo -e "${GREEN}✨ Enhanced push completed! 🚀${NC}"
echo -e "${YELLOW}💡 Tip: Use --release flag for full release workflow with tags and changelog${NC}"
