#!/bin/bash

#############################################
# Setup GitHub Actions Workflows Script
# 
# This script commits and pushes all workflow
# files to the repository
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Setup GitHub Actions Workflows          ║${NC}"
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
# Check for workflow directory
#############################################

if [ ! -d ".github/workflows" ]; then
    echo -e "${YELLOW}⚠ .github/workflows directory not found${NC}"
    echo -e "${YELLOW}  Creating directory...${NC}"
    mkdir -p .github/workflows
fi

echo -e "${GREEN}✓ Workflow directory exists${NC}"

#############################################
# Check for workflow files
#############################################

echo -e "\n${BLUE}Checking workflow files...${NC}\n"

WORKFLOW_FILES=(
    ".github/workflows/ci.yml"
    ".github/workflows/deploy-develop.yml"
    ".github/workflows/deploy-staging.yml"
    ".github/workflows/deploy-production.yml"
)

MISSING_FILES=0

for file in "${WORKFLOW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ Found: $file${NC}"
    else
        echo -e "${RED}✗ Missing: $file${NC}"
        ((MISSING_FILES++))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo -e "\n${RED}Error: $MISSING_FILES workflow file(s) missing${NC}"
    echo -e "${YELLOW}Please ensure all workflow files are created before running this script${NC}"
    exit 1
fi

#############################################
# Commit workflow files
#############################################

echo -e "\n${BLUE}Committing workflow files...${NC}"

git checkout main
git pull origin main

# Check if there are changes to commit
if git diff --quiet .github/workflows/ && git diff --cached --quiet .github/workflows/; then
    echo -e "${YELLOW}⚠ No changes to commit${NC}"
    echo -e "${YELLOW}  Workflows may already be committed${NC}"
else
    git add .github/workflows/
    git commit -m "ci: add GitHub Actions workflows for branching strategy

- Add CI workflow (lint, typecheck, test, build)
- Add deployment workflows (develop, staging, production)
- Configure automated checks and deployments"
    git push origin main
    echo -e "${GREEN}✓ Workflows committed to main${NC}"
fi

#############################################
# Sync to other branches
#############################################

echo -e "\n${BLUE}Syncing workflows to other branches...${NC}"

# Sync to develop
if git rev-parse --verify develop >/dev/null 2>&1; then
    echo -e "\n${YELLOW}Syncing to develop...${NC}"
    git checkout develop
    git pull origin develop
    git merge main --no-edit
    git push origin develop
    echo -e "${GREEN}✓ Synced to develop${NC}"
else
    echo -e "${YELLOW}⚠ Branch 'develop' not found, skipping${NC}"
fi

# Sync to staging
if git rev-parse --verify staging >/dev/null 2>&1; then
    echo -e "\n${YELLOW}Syncing to staging...${NC}"
    git checkout staging
    git pull origin staging
    git merge main --no-edit
    git push origin staging
    echo -e "${GREEN}✓ Synced to staging${NC}"
else
    echo -e "${YELLOW}⚠ Branch 'staging' not found, skipping${NC}"
fi

# Return to main
git checkout main

#############################################
# Summary
#############################################

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Workflows setup complete! ✓             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "Workflow files committed:"
for file in "${WORKFLOW_FILES[@]}"; do
    echo -e "  • ${BLUE}${file}${NC}"
done
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Go to GitHub > Actions tab"
echo -e "  2. Verify workflows are visible"
echo -e "  3. Create a test PR to trigger CI"
echo -e "  4. Configure branch protection rules with required status checks"
echo ""

