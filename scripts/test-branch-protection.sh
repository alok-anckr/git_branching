#!/bin/bash

#############################################
# Branch Protection Test Script
# 
# This script tests branch protection rules
# by attempting prohibited actions
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Temp file for testing
TEST_FILE=".test-branch-protection-temp"

# Store original branch
ORIGINAL_BRANCH=$(git branch --show-current)

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Branch Protection Test Suite           ║${NC}"
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo ""

#############################################
# Helper Functions
#############################################

test_start() {
    ((TESTS_TOTAL++))
    echo -e "\n${YELLOW}[TEST $TESTS_TOTAL] $1${NC}"
}

test_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓ PASS: $1${NC}"
}

test_fail() {
    ((TESTS_FAILED++))
    echo -e "${RED}✗ FAIL: $1${NC}"
}

cleanup() {
    # Remove test file
    rm -f "$TEST_FILE"
    
    # Reset any uncommitted changes
    git reset --hard HEAD 2>/dev/null || true
    
    # Return to original branch
    git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
}

# Trap to ensure cleanup runs
trap cleanup EXIT

#############################################
# Test Functions
#############################################

test_branch_protection() {
    local branch=$1
    local branch_display=$2
    
    test_start "Direct commit prevention: $branch_display"
    
    # Checkout branch
    if ! git checkout "$branch" 2>/dev/null; then
        test_fail "Branch $branch does not exist"
        return
    fi
    
    # Pull latest
    git pull origin "$branch" 2>/dev/null || true
    
    # Create test file
    echo "test" > "$TEST_FILE"
    git add "$TEST_FILE"
    git commit -m "test: branch protection check" 2>/dev/null || true
    
    # Attempt to push
    if git push origin "$branch" 2>&1 | grep -q -E "(protected branch|pre-receive hook declined|cannot push)"; then
        test_pass "Direct commits to $branch_display blocked"
        cleanup
    else
        test_fail "Direct commits to $branch_display NOT blocked"
        # Try to revert the push
        git push origin ":$branch" 2>/dev/null || true
        cleanup
    fi
}

test_force_push() {
    local branch=$1
    local branch_display=$2
    
    test_start "Force push prevention: $branch_display"
    
    # Checkout branch
    git checkout "$branch" 2>/dev/null || return
    git pull origin "$branch" 2>/dev/null || true
    
    # Create a commit
    echo "test" > "$TEST_FILE"
    git add "$TEST_FILE"
    git commit -m "test: force push prevention" 2>/dev/null || true
    
    # Reset to previous commit
    git reset --hard HEAD~1 2>/dev/null || true
    
    # Attempt force push
    if git push --force origin "$branch" 2>&1 | grep -q -E "(protected branch|cannot force-update|pre-receive hook declined)"; then
        test_pass "Force push to $branch_display blocked"
    else
        test_fail "Force push to $branch_display NOT blocked"
    fi
    
    cleanup
}

test_status_checks() {
    local branch=$1
    local branch_display=$2
    
    test_start "Status check configuration: $branch_display"
    
    # Use GitHub CLI if available
    if command -v gh &> /dev/null; then
        local protection_info=$(gh api "repos/:owner/:repo/branches/$branch/protection" 2>/dev/null || echo "{}")
        
        if echo "$protection_info" | grep -q "required_status_checks"; then
            test_pass "Status checks configured for $branch_display"
        else
            test_fail "Status checks NOT configured for $branch_display"
        fi
    else
        echo -e "${YELLOW}  ⚠ GitHub CLI not installed, skipping API check${NC}"
        echo -e "${YELLOW}  ℹ Please verify status checks manually in GitHub settings${NC}"
    fi
}

#############################################
# Run Tests
#############################################

echo -e "${BLUE}Running branch protection tests...${NC}\n"

# Test main branch
if git rev-parse --verify main >/dev/null 2>&1; then
    test_branch_protection "main" "main"
    test_force_push "main" "main"
    test_status_checks "main" "main"
else
    echo -e "${YELLOW}⚠ Branch 'main' not found, skipping tests${NC}"
fi

# Test staging branch
if git rev-parse --verify staging >/dev/null 2>&1; then
    test_branch_protection "staging" "staging"
    test_force_push "staging" "staging"
    test_status_checks "staging" "staging"
else
    echo -e "${YELLOW}⚠ Branch 'staging' not found, skipping tests${NC}"
fi

# Test develop branch
if git rev-parse --verify develop >/dev/null 2>&1; then
    test_branch_protection "develop" "develop"
    test_force_push "develop" "develop"
    test_status_checks "develop" "develop"
else
    echo -e "${YELLOW}⚠ Branch 'develop' not found, skipping tests${NC}"
fi

#############################################
# Summary
#############################################

echo -e "\n${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            Test Summary                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total Tests:  ${TESTS_TOTAL}"
echo -e "${GREEN}Passed:       ${TESTS_PASSED}${NC}"
echo -e "${RED}Failed:       ${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  All tests passed! ✓                    ║${NC}"
    echo -e "${GREEN}║  Branch protection is working correctly ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  Some tests failed! ✗                   ║${NC}"
    echo -e "${RED}║  Please review branch protection rules  ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════╝${NC}"
    exit 1
fi

