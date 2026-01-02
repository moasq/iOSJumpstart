#!/bin/bash
#
# iOS Bundle ID Change Script
# Changes bundle identifier prefix across all project files
#
# Usage: ./scripts/change_bundle_id.sh OLD_PREFIX NEW_PREFIX
# Example: ./scripts/change_bundle_id.sh com.mosal com.newcompany
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
    echo "Usage: $0 OLD_PREFIX NEW_PREFIX"
    echo ""
    echo "Changes bundle identifier prefix throughout the iOS project."
    echo ""
    echo "Arguments:"
    echo "  OLD_PREFIX    Current bundle ID prefix (e.g., com.mosal)"
    echo "  NEW_PREFIX    New bundle ID prefix (e.g., com.newcompany)"
    echo ""
    echo "Example:"
    echo "  $0 com.mosal com.newcompany"
    echo ""
    echo "This will change:"
    echo "  com.mosal.MyApp -> com.newcompany.MyApp"
    echo "  com.mosal.MyAppTests -> com.newcompany.MyAppTests"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

OLD_PREFIX="$1"
NEW_PREFIX="$2"

# Validate bundle ID format (reverse domain notation)
validate_bundle_prefix() {
    local prefix="$1"
    if [[ ! "$prefix" =~ ^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)*$ ]]; then
        return 1
    fi
    return 0
}

if ! validate_bundle_prefix "$OLD_PREFIX"; then
    log_error "OLD_PREFIX must be valid reverse domain notation: $OLD_PREFIX"
    log_error "Example: com.company or com.company.division"
    exit 1
fi

if ! validate_bundle_prefix "$NEW_PREFIX"; then
    log_error "NEW_PREFIX must be valid reverse domain notation: $NEW_PREFIX"
    log_error "Example: com.company or com.company.division"
    exit 1
fi

if [[ "$OLD_PREFIX" == "$NEW_PREFIX" ]]; then
    log_error "OLD_PREFIX and NEW_PREFIX cannot be the same"
    exit 1
fi

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

log_info "====================================="
log_info "iOS Bundle ID Change Script"
log_info "====================================="
log_info "Changing: $OLD_PREFIX.* -> $NEW_PREFIX.*"
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

# Close Xcode
log_step "Closing Xcode..."
pkill -x Xcode 2>/dev/null || true
sleep 1

# Create backup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.ios-rename-backups/bundle-id-${TIMESTAMP}"
log_step "Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
git bundle create "$BACKUP_DIR/project.bundle" --all 2>/dev/null || true

# Escape dots for sed
OLD_PREFIX_ESCAPED=$(echo "$OLD_PREFIX" | sed 's/\./\\./g')

# Track changes
CHANGES_MADE=0

# ==========================================
# PHASE 1: Update project.pbxproj files
# ==========================================
log_step "Phase 1: Updating project.pbxproj files..."

find . -name "*.pbxproj" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "PRODUCT_BUNDLE_IDENTIFIER.*${OLD_PREFIX}" "$file" 2>/dev/null; then
        log_info "  Updating: $file"
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = ${OLD_PREFIX_ESCAPED}\./PRODUCT_BUNDLE_IDENTIFIER = ${NEW_PREFIX}./g" "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# ==========================================
# PHASE 2: Update GoogleService-Info.plist
# ==========================================
log_step "Phase 2: Updating GoogleService-Info.plist files..."

find . -name "GoogleService-Info.plist" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "<string>${OLD_PREFIX}" "$file" 2>/dev/null; then
        log_info "  Updating: $file"
        sed -i '' "s|<string>${OLD_PREFIX_ESCAPED}\.|<string>${NEW_PREFIX}.|g" "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# ==========================================
# PHASE 3: Update Bundle.swift files
# ==========================================
log_step "Phase 3: Updating Bundle.swift files..."

find . -name "Bundle.swift" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "\"${OLD_PREFIX}\." "$file" 2>/dev/null; then
        log_info "  Updating: $file"
        sed -i '' "s|\"${OLD_PREFIX_ESCAPED}\.|\"${NEW_PREFIX}.|g" "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# ==========================================
# PHASE 4: Update other Swift files with hardcoded bundle IDs
# ==========================================
log_step "Phase 4: Scanning Swift files for hardcoded bundle IDs..."

find . -name "*.swift" -type f -not -path "*/.git/*" -not -name "Bundle.swift" | while read -r file; do
    if grep -q "\"${OLD_PREFIX}\." "$file" 2>/dev/null; then
        log_info "  Updating: $file"
        sed -i '' "s|\"${OLD_PREFIX_ESCAPED}\.|\"${NEW_PREFIX}.|g" "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# ==========================================
# PHASE 5: Update Info.plist files
# ==========================================
log_step "Phase 5: Scanning Info.plist files..."

find . -name "Info.plist" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "${OLD_PREFIX}\." "$file" 2>/dev/null; then
        log_info "  Updating: $file"
        sed -i '' "s|${OLD_PREFIX_ESCAPED}\.|${NEW_PREFIX}.|g" "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# ==========================================
# PHASE 6: Update entitlements files
# ==========================================
log_step "Phase 6: Scanning entitlements files..."

find . -name "*.entitlements" -type f -not -path "*/.git/*" | while read -r file; do
    if grep -q "${OLD_PREFIX}\." "$file" 2>/dev/null; then
        log_info "  Updating: $file"
        sed -i '' "s|${OLD_PREFIX_ESCAPED}\.|${NEW_PREFIX}.|g" "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# ==========================================
# PHASE 7: Cleanup
# ==========================================
log_step "Phase 7: Cleanup..."

# Clear derived data
log_info "  Clearing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true

# ==========================================
# Validation
# ==========================================
log_step "Validating changes..."

REMAINING=$(grep -r "PRODUCT_BUNDLE_IDENTIFIER.*${OLD_PREFIX}\." --include="*.pbxproj" . 2>/dev/null | wc -l | tr -d ' ')
if [[ "$REMAINING" -gt 0 ]]; then
    log_warn "Found $REMAINING remaining old bundle IDs in pbxproj files"
    log_warn "Manual review recommended"
fi

# ==========================================
# DONE
# ==========================================
echo ""
log_info "====================================="
log_info "Bundle ID change complete"
log_info "====================================="
echo ""
echo "Changed: ${OLD_PREFIX}.* -> ${NEW_PREFIX}.*"
echo ""
log_warn "IMPORTANT - Update these external services manually:"
echo ""
echo "  1. Apple Developer Portal"
echo "     - Create new App IDs with the new bundle identifiers"
echo "     - Update provisioning profiles"
echo "     - URL: https://developer.apple.com/account/resources/identifiers/list"
echo ""
echo "  2. Firebase Console"
echo "     - Update bundle ID in project settings"
echo "     - Download new GoogleService-Info.plist"
echo "     - URL: https://console.firebase.google.com"
echo ""
echo "  3. RevenueCat (if using)"
echo "     - Update app bundle ID"
echo "     - URL: https://app.revenuecat.com"
echo ""
echo "  4. Google Cloud Console (for OAuth)"
echo "     - Update iOS OAuth client bundle ID"
echo "     - URL: https://console.cloud.google.com/apis/credentials"
echo ""
echo "  5. App Store Connect"
echo "     - Note: Bundle ID cannot be changed for existing apps"
echo "     - You may need to create a new app record"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Stage changes:  git add -A"
echo "  3. Commit:         git commit -m 'chore: Change bundle ID from $OLD_PREFIX to $NEW_PREFIX'"
echo ""
echo "Backup location: $BACKUP_DIR"
