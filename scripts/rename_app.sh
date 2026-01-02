#!/bin/bash
#
# iOS App Rename Script
# Renames an iOS app (folders, files, and all internal references)
# WITHOUT changing bundle identifiers
#
# Usage: ./scripts/rename_app.sh OLD_NAME NEW_NAME
# Example: ./scripts/rename_app.sh OldAppName NewAppName
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

usage() {
    echo "Usage: $0 OLD_NAME NEW_NAME"
    echo ""
    echo "Renames an iOS app throughout the codebase while preserving bundle identifiers."
    echo ""
    echo "Arguments:"
    echo "  OLD_NAME    Current app name (e.g., OldAppName)"
    echo "  NEW_NAME    New app name (e.g., iOSJumpstart)"
    echo ""
    echo "Example:"
    echo "  $0 OldAppName NewAppName"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

OLD_NAME="$1"
NEW_NAME="$2"

# Validate names (alphanumeric, starting with letter)
if [[ ! "$OLD_NAME" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
    log_error "OLD_NAME must be alphanumeric and start with a letter: $OLD_NAME"
    exit 1
fi
if [[ ! "$NEW_NAME" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
    log_error "NEW_NAME must be alphanumeric and start with a letter: $NEW_NAME"
    exit 1
fi

if [[ "$OLD_NAME" == "$NEW_NAME" ]]; then
    log_error "OLD_NAME and NEW_NAME cannot be the same"
    exit 1
fi

# Navigate to project root (parent of scripts directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

log_info "====================================="
log_info "iOS App Rename Script"
log_info "====================================="
log_info "Renaming: $OLD_NAME -> $NEW_NAME"
log_info "Project root: $PROJECT_ROOT"
echo ""

# Pre-flight checks
log_step "Running pre-flight checks..."

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    log_error "Not in a git repository"
    exit 1
fi

if [[ -n $(git status -s) ]]; then
    log_warn "Working directory has uncommitted changes"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if [[ ! -d "${OLD_NAME}.xcworkspace" ]]; then
    log_error "Workspace not found: ${OLD_NAME}.xcworkspace"
    log_error "Make sure you're running from the project root and the app name is correct"
    exit 1
fi

# Close Xcode
log_step "Closing Xcode..."
pkill -x Xcode 2>/dev/null || true
pkill -x Simulator 2>/dev/null || true
sleep 1

# Create backup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.ios-rename-backups/${OLD_NAME}-to-${NEW_NAME}-${TIMESTAMP}"
log_step "Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
git bundle create "$BACKUP_DIR/project.bundle" --all 2>/dev/null || true
echo "$PROJECT_ROOT" > "$BACKUP_DIR/project_path.txt"

# ==========================================
# PHASE 1: Update file contents
# ==========================================
log_step "Phase 1: Updating file contents..."

# 1.1 Update .pbxproj files
log_info "  Updating project.pbxproj files..."
find . -name "*.pbxproj" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "$OLD_NAME" "$file" 2>/dev/null; then
        log_info "    Processing: $file"
        sed -i '' \
            -e "s/remoteInfo = ${OLD_NAME};/remoteInfo = ${NEW_NAME};/g" \
            -e "s/remoteInfo = ${OLD_NAME}Tests;/remoteInfo = ${NEW_NAME}Tests;/g" \
            -e "s/remoteInfo = ${OLD_NAME}UITests;/remoteInfo = ${NEW_NAME}UITests;/g" \
            -e "s/${OLD_NAME}\.app/${NEW_NAME}.app/g" \
            -e "s/${OLD_NAME}Tests\.xctest/${NEW_NAME}Tests.xctest/g" \
            -e "s/${OLD_NAME}UITests\.xctest/${NEW_NAME}UITests.xctest/g" \
            -e "s/name = ${OLD_NAME};/name = ${NEW_NAME};/g" \
            -e "s/name = ${OLD_NAME}Tests;/name = ${NEW_NAME}Tests;/g" \
            -e "s/name = ${OLD_NAME}UITests;/name = ${NEW_NAME}UITests;/g" \
            -e "s/productName = ${OLD_NAME};/productName = ${NEW_NAME};/g" \
            -e "s/productName = ${OLD_NAME}Tests;/productName = ${NEW_NAME}Tests;/g" \
            -e "s/productName = ${OLD_NAME}UITests;/productName = ${NEW_NAME}UITests;/g" \
            -e "s|path = ${OLD_NAME};|path = ${NEW_NAME};|g" \
            -e "s|path = ${OLD_NAME}/|path = ${NEW_NAME}/|g" \
            -e "s|CODE_SIGN_ENTITLEMENTS = ${OLD_NAME}/${OLD_NAME}\.entitlements|CODE_SIGN_ENTITLEMENTS = ${NEW_NAME}/${NEW_NAME}.entitlements|g" \
            -e "s|DEVELOPMENT_ASSET_PATHS = \"\\\"${OLD_NAME}/Preview Content\\\"\"|DEVELOPMENT_ASSET_PATHS = \"\\\"${NEW_NAME}/Preview Content\\\"\"|g" \
            -e "s|INFOPLIST_FILE = ${OLD_NAME}/Info\.plist|INFOPLIST_FILE = ${NEW_NAME}/Info.plist|g" \
            -e "s|TEST_TARGET_NAME = ${OLD_NAME};|TEST_TARGET_NAME = ${NEW_NAME};|g" \
            -e "s|/\\* ${OLD_NAME} \\*/|/* ${NEW_NAME} */|g" \
            -e "s|/\\* ${OLD_NAME}Tests \\*/|/* ${NEW_NAME}Tests */|g" \
            -e "s|/\\* ${OLD_NAME}UITests \\*/|/* ${NEW_NAME}UITests */|g" \
            -e "s|\"${OLD_NAME}\"|\"${NEW_NAME}\"|g" \
            -e "s|\"${OLD_NAME}Tests\"|\"${NEW_NAME}Tests\"|g" \
            -e "s|\"${OLD_NAME}UITests\"|\"${NEW_NAME}UITests\"|g" \
            -e "s|${OLD_NAME}\.xcodeproj|${NEW_NAME}.xcodeproj|g" \
            "$file"
    fi
done

# 1.2 Update scheme files
log_info "  Updating scheme files..."
find . -name "*.xcscheme" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "$OLD_NAME" "$file" 2>/dev/null; then
        log_info "    Processing: $file"
        sed -i '' \
            -e "s/BuildableName = \"${OLD_NAME}\.app\"/BuildableName = \"${NEW_NAME}.app\"/g" \
            -e "s/BuildableName = \"${OLD_NAME}Tests\.xctest\"/BuildableName = \"${NEW_NAME}Tests.xctest\"/g" \
            -e "s/BuildableName = \"${OLD_NAME}UITests\.xctest\"/BuildableName = \"${NEW_NAME}UITests.xctest\"/g" \
            -e "s/BlueprintName = \"${OLD_NAME}\"/BlueprintName = \"${NEW_NAME}\"/g" \
            -e "s/BlueprintName = \"${OLD_NAME}Tests\"/BlueprintName = \"${NEW_NAME}Tests\"/g" \
            -e "s/BlueprintName = \"${OLD_NAME}UITests\"/BlueprintName = \"${NEW_NAME}UITests\"/g" \
            -e "s/ReferencedContainer = \"container:${OLD_NAME}\.xcodeproj\"/ReferencedContainer = \"container:${NEW_NAME}.xcodeproj\"/g" \
            "$file"
    fi
done

# 1.3 Update workspace
log_info "  Updating workspace..."
WORKSPACE_FILE="${OLD_NAME}.xcworkspace/contents.xcworkspacedata"
if [[ -f "$WORKSPACE_FILE" ]]; then
    sed -i '' "s|group:${OLD_NAME}/${OLD_NAME}\.xcodeproj|group:${NEW_NAME}/${NEW_NAME}.xcodeproj|g" "$WORKSPACE_FILE"
fi

# 1.4 Update Swift entry point
log_info "  Updating Swift entry point..."
SWIFT_APP_FILE="Src/${OLD_NAME}/${OLD_NAME}/Main/${OLD_NAME}App.swift"
if [[ -f "$SWIFT_APP_FILE" ]]; then
    sed -i '' \
        -e "s/struct ${OLD_NAME}App/struct ${NEW_NAME}App/g" \
        -e "s|//  ${OLD_NAME}App.swift|//  ${NEW_NAME}App.swift|g" \
        -e "s|//  ${OLD_NAME}$|//  ${NEW_NAME}|g" \
        "$SWIFT_APP_FILE"
fi

# 1.5 Update CI workflow
log_info "  Updating CI workflow..."
CI_FILE=".github/workflows/ios.yml"
if [[ -f "$CI_FILE" ]]; then
    sed -i '' \
        -e "s/echo \"${OLD_NAME}\"/echo \"${NEW_NAME}\"/g" \
        -e "s/Using default scheme: ${OLD_NAME}/Using default scheme: ${NEW_NAME}/g" \
        "$CI_FILE"
fi

# ==========================================
# PHASE 2: Rename files and folders
# ==========================================
log_step "Phase 2: Renaming files and folders..."

safe_git_mv() {
    local src="$1"
    local dst="$2"
    if [[ -e "$src" ]]; then
        git mv "$src" "$dst" 2>/dev/null || mv "$src" "$dst"
        log_info "    Renamed: $(basename "$src") -> $(basename "$dst")"
    fi
}

# 2.1 Rename Swift entry point
log_info "  Renaming Swift entry point..."
safe_git_mv "Src/${OLD_NAME}/${OLD_NAME}/Main/${OLD_NAME}App.swift" "Src/${OLD_NAME}/${OLD_NAME}/Main/${NEW_NAME}App.swift"

# 2.2 Rename entitlements
log_info "  Renaming entitlements..."
safe_git_mv "Src/${OLD_NAME}/${OLD_NAME}/${OLD_NAME}.entitlements" "Src/${OLD_NAME}/${OLD_NAME}/${NEW_NAME}.entitlements"

# 2.3 Rename scheme files
log_info "  Renaming scheme files..."
SCHEMES_DIR="Src/${OLD_NAME}/${OLD_NAME}.xcodeproj/xcshareddata/xcschemes"
if [[ -d "$SCHEMES_DIR" ]]; then
    for scheme in "$SCHEMES_DIR"/*.xcscheme; do
        if [[ -f "$scheme" ]]; then
            base_name=$(basename "$scheme")
            new_name="${base_name//$OLD_NAME/$NEW_NAME}"
            if [[ "$base_name" != "$new_name" ]]; then
                safe_git_mv "$scheme" "$SCHEMES_DIR/$new_name"
            fi
        fi
    done
fi

# 2.4 Rename inner app folder
log_info "  Renaming app source folder..."
safe_git_mv "Src/${OLD_NAME}/${OLD_NAME}" "Src/${OLD_NAME}/${NEW_NAME}"

# 2.5 Rename xcodeproj
log_info "  Renaming xcodeproj..."
safe_git_mv "Src/${OLD_NAME}/${OLD_NAME}.xcodeproj" "Src/${OLD_NAME}/${NEW_NAME}.xcodeproj"

# 2.6 Rename outer folder
log_info "  Renaming outer folder..."
safe_git_mv "Src/${OLD_NAME}" "Src/${NEW_NAME}"

# 2.7 Rename workspace
log_info "  Renaming workspace..."
safe_git_mv "${OLD_NAME}.xcworkspace" "${NEW_NAME}.xcworkspace"

# ==========================================
# PHASE 3: Cleanup
# ==========================================
log_step "Phase 3: Cleanup..."

# Clear derived data
log_info "  Clearing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true

# Remove backup pbxproj if exists
BACKUP_PBXPROJ="Src/${NEW_NAME}/${NEW_NAME}.xcodeproj/project.pbxproj.backup"
if [[ -f "$BACKUP_PBXPROJ" ]]; then
    rm -f "$BACKUP_PBXPROJ"
    log_info "  Removed backup pbxproj"
fi

# ==========================================
# DONE
# ==========================================
echo ""
log_info "====================================="
log_info "Rename complete: $OLD_NAME -> $NEW_NAME"
log_info "====================================="
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Stage changes:  git add -A"
echo "  3. Commit:         git commit -m 'refactor: Rename app from $OLD_NAME to $NEW_NAME'"
echo "  4. Open workspace: open ${NEW_NAME}.xcworkspace"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
log_warn "Note: Bundle identifiers were NOT changed. Use change_bundle_id.sh if needed."
