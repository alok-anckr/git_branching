#!/bin/bash

#############################################
# Create Core Branches Script
# 
# This script creates the core branches
# (develop, staging) for the branching strategy
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Create Core Branches                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

#############################################
# Check if we're in a git repository
#############################################

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}✗ Error: Not in a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Git repository detected${NC}\n"

#############################################
# Check for main branch
#############################################

if ! git rev-parse --verify main >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Warning: 'main' branch not found${NC}"
    echo -e "${YELLOW}  Creating 'main' branch from current branch${NC}"
    CURRENT_BRANCH=$(git branch --show-current)
    git branch main "$CURRENT_BRANCH"
    git push -u origin main
fi

echo -e "${GREEN}✓ Main branch verified${NC}"

#############################################
# Create develop branch
#############################################

echo -e "\n${BLUE}Creating 'develop' branch...${NC}"

if git rev-parse --verify develop >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Branch 'develop' already exists${NC}"
    echo -e "${YELLOW}  Skipping creation${NC}"
else
    git checkout main
    git pull origin main
    git checkout -b develop
    git push -u origin develop
    echo -e "${GREEN}✓ Branch 'develop' created successfully${NC}"
fi

#############################################
# Create staging branch
#############################################

echo -e "\n${BLUE}Creating 'staging' branch...${NC}"

if git rev-parse --verify staging >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Branch 'staging' already exists${NC}"
    echo -e "${YELLOW}  Skipping creation${NC}"
else
    git checkout main
    git pull origin main
    git checkout -b staging
    git push -u origin staging
    echo -e "${GREEN}✓ Branch 'staging' created successfully${NC}"
fi

#############################################
# Verify branches
#############################################

echo -e "\n${BLUE}Verifying branches...${NC}\n"

git fetch --all

if git rev-parse --verify origin/main >/dev/null 2>&1; then
    echo -e "${GREEN}✓ origin/main exists${NC}"
else
    echo -e "${RED}✗ origin/main NOT found${NC}"
fi

if git rev-parse --verify origin/develop >/dev/null 2>&1; then
    echo -e "${GREEN}✓ origin/develop exists${NC}"
else
    echo -e "${RED}✗ origin/develop NOT found${NC}"
fi

if git rev-parse --verify origin/staging >/dev/null 2>&1; then
    echo -e "${GREEN}✓ origin/staging exists${NC}"
else
    echo -e "${RED}✗ origin/staging NOT found${NC}"
fi

#############################################
# Summary
#############################################

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Core branches created successfully! ✓   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "Available branches:"
echo -e "  • ${BLUE}main${NC}     - Production branch"
echo -e "  • ${BLUE}staging${NC}  - Pre-production branch"
echo -e "  • ${BLUE}develop${NC}  - Development branch"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Configure branch protection rules"
echo -e "  2. Set up GitHub Actions workflows"
echo -e "  3. Configure environments"
echo ""

# Return to main branch
git checkout main

