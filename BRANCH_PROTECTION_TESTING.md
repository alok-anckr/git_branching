# Branch Protection Testing Guide

This document provides comprehensive testing procedures to verify branch protection rules and automated workflows are working correctly.

## Table of Contents

1. [Testing Overview](#testing-overview)
2. [Pre-Testing Checklist](#pre-testing-checklist)
3. [Unit Tests for Branch Protection](#unit-tests-for-branch-protection)
4. [GitHub Actions Workflow Testing](#github-actions-workflow-testing)
5. [Integration Testing](#integration-testing)
6. [Test Scenarios](#test-scenarios)
7. [Automated Test Scripts](#automated-test-scripts)
8. [Verification Checklist](#verification-checklist)

---

## Testing Overview

### Objectives

- ✅ Verify branch protection rules prevent direct commits
- ✅ Validate PR requirements are enforced
- ✅ Confirm CI/CD workflows trigger correctly
- ✅ Test merge restrictions and approval requirements
- ✅ Validate code review enforcement

### Testing Approach

1. **Unit Testing**: Individual protection rule verification
2. **Integration Testing**: End-to-end workflow validation
3. **Negative Testing**: Attempt prohibited actions
4. **Positive Testing**: Verify allowed actions work correctly

---

## Pre-Testing Checklist

Before starting tests, ensure:

- [ ] All branches created (`main`, `staging`, `develop`)
- [ ] Branch protection rules configured
- [ ] GitHub Actions workflows committed
- [ ] At least one successful workflow run completed
- [ ] GitHub environments configured
- [ ] Required status checks added to branch protection
- [ ] Test repository or branch available

---

## Unit Tests for Branch Protection

### Test 1: Direct Commit Prevention

**Objective:** Verify direct commits to protected branches are blocked.

#### Test Case 1.1: Direct Push to `main`

```bash
# Setup
git checkout main
git pull origin main

# Test Action
echo "unauthorized change" >> test-file.txt
git add test-file.txt
git commit -m "test: attempt direct commit to main"
git push origin main
```

**Expected Result:**
```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Changes must be made through a pull request.
To https://github.com/username/repo.git
 ! [remote rejected] main -> main (protected branch hook declined)
error: failed to push some refs to 'https://github.com/username/repo.git'
```

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 1.2: Direct Push to `staging`

```bash
# Setup
git checkout staging
git pull origin staging

# Test Action
echo "unauthorized change" >> test-file.txt
git add test-file.txt
git commit -m "test: attempt direct commit to staging"
git push origin staging
```

**Expected Result:** Push rejected with branch protection error

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 1.3: Direct Push to `develop`

```bash
# Setup
git checkout develop
git pull origin develop

# Test Action
echo "unauthorized change" >> test-file.txt
git add test-file.txt
git commit -m "test: attempt direct commit to develop"
git push origin develop
```

**Expected Result:** Push rejected with branch protection error

**Status:** ✅ PASS / ❌ FAIL

---

### Test 2: Force Push Prevention

**Objective:** Verify force pushes are blocked on protected branches.

#### Test Case 2.1: Force Push to `main`

```bash
# Setup
git checkout main
git pull origin main
git reset --hard HEAD~1

# Test Action
git push --force origin main
```

**Expected Result:**
```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Cannot force-push to this branch
```

**Status:** ✅ PASS / ❌ FAIL

---

### Test 3: Branch Deletion Prevention

**Objective:** Verify protected branches cannot be deleted.

#### Test Case 3.1: Delete Protected Branch

```bash
# Test Action
git push origin --delete main
```

**Expected Result:**
```
remote: error: GH006: Protected branch deletion failed for refs/heads/main.
```

**Status:** ✅ PASS / ❌ FAIL

---

### Test 4: PR Approval Requirements

**Objective:** Verify approval requirements are enforced.

#### Test Case 4.1: Merge Without Approval (develop)

1. Create test branch:
   ```bash
   git checkout develop
   git checkout -b test/approval-required
   echo "test" >> test.txt
   git add test.txt
   git commit -m "test: PR approval requirement"
   git push origin test/approval-required
   ```

2. Create PR to `develop`
3. Wait for CI checks to pass
4. Attempt to merge without approval

**Expected Result:**
- Merge button disabled
- Message: "Review required - At least 1 approving review is required"

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 4.2: Merge Without Sufficient Approvals (main)

1. Create PR to `main` (from `staging`)
2. Get 1 approval
3. Attempt to merge

**Expected Result:**
- Merge button disabled
- Message: "Review required - At least 2 approving reviews are required"

**Status:** ✅ PASS / ❌ FAIL

---

### Test 5: Stale Review Dismissal

**Objective:** Verify stale reviews are dismissed on new commits.

#### Test Case 5.1: New Commit After Approval

1. Create PR to `develop`
2. Get approval
3. Push new commit
4. Check PR status

**Expected Result:**
- Previous approval dismissed
- New approval required
- Merge button disabled

**Status:** ✅ PASS / ❌ FAIL

---

## GitHub Actions Workflow Testing

### Test 6: CI Workflow Triggers

**Objective:** Verify CI workflows trigger on appropriate events.

#### Test Case 6.1: CI Triggers on PR to `develop`

```bash
# Create feature branch and PR
git checkout develop
git checkout -b test/ci-trigger-develop
echo "test" >> test.txt
git add test.txt
git commit -m "test: CI trigger on develop PR"
git push origin test/ci-trigger-develop
# Create PR via GitHub
```

**Expected Result:**
- CI workflow starts automatically
- Jobs run: lint, typecheck, test, build
- Status checks appear on PR

**Verification:**
```bash
gh pr checks
```

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 6.2: CI Triggers on PR to `staging`

```bash
# Create PR from develop to staging
# Via GitHub UI or CLI
```

**Expected Result:**
- CI workflow starts automatically
- All jobs run successfully

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 6.3: CI Triggers on PR to `main`

```bash
# Create PR from staging to main
```

**Expected Result:**
- CI workflow starts automatically
- All jobs run successfully

**Status:** ✅ PASS / ❌ FAIL

---

### Test 7: Linting Enforcement

**Objective:** Verify linting checks prevent merge.

#### Test Case 7.1: Failed Lint Check

1. Create branch with linting error:
   ```bash
   git checkout develop
   git checkout -b test/lint-failure
   # Add file with linting errors
   echo "const x = 1    // extra spaces" >> test.js
   git add test.js
   git commit -m "test: lint failure"
   git push origin test/lint-failure
   ```

2. Create PR to `develop`

**Expected Result:**
- Lint check fails
- Merge button disabled
- Error displayed in PR checks

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 7.2: Fix and Rerun

1. Fix linting errors:
   ```bash
   git checkout test/lint-failure
   # Fix linting errors
   pnpm lint:fix
   git add .
   git commit -m "fix: resolve lint errors"
   git push origin test/lint-failure
   ```

**Expected Result:**
- CI re-runs automatically
- Lint check passes
- Merge button enabled (after approval)

**Status:** ✅ PASS / ❌ FAIL

---

### Test 8: Type Check Enforcement

**Objective:** Verify TypeScript type checking prevents merge.

#### Test Case 8.1: Failed Type Check

1. Create branch with type error:
   ```bash
   git checkout develop
   git checkout -b test/type-failure
   # Add file with type error
   echo "const x: string = 123;" >> test.ts
   git add test.ts
   git commit -m "test: type error"
   git push origin test/type-failure
   ```

2. Create PR to `develop`

**Expected Result:**
- Type check fails
- Merge button disabled

**Status:** ✅ PASS / ❌ FAIL

---

### Test 9: Test Enforcement

**Objective:** Verify failing tests prevent merge.

#### Test Case 9.1: Failed Test

1. Create branch with failing test
2. Create PR

**Expected Result:**
- Test job fails
- Merge button disabled

**Status:** ✅ PASS / ❌ FAIL

---

### Test 10: Build Verification

**Objective:** Verify build failures prevent merge.

#### Test Case 10.1: Build Failure

1. Create branch that breaks build
2. Create PR

**Expected Result:**
- Build job fails
- Merge button disabled

**Status:** ✅ PASS / ❌ FAIL

---

### Test 11: Deployment Workflows

**Objective:** Verify deployment workflows trigger on merge.

#### Test Case 11.1: Deploy to Development

1. Merge PR to `develop`

**Expected Result:**
- Deploy to Development workflow triggers
- Deployment completes successfully
- E2E tests run on development environment

**Verification:**
```bash
gh run list --workflow="deploy-develop.yml"
```

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 11.2: Deploy to Staging

1. Merge PR from `develop` to `staging`

**Expected Result:**
- Deploy to Staging workflow triggers
- Deployment completes
- E2E and smoke tests run

**Status:** ✅ PASS / ❌ FAIL

---

#### Test Case 11.3: Deploy to Production

1. Merge PR from `staging` to `main`

**Expected Result:**
- Deploy to Production workflow triggers
- Deployment completes
- Smoke tests run
- GitHub release created

**Status:** ✅ PASS / ❌ FAIL

---

## Integration Testing

### Test 12: Complete Feature Workflow

**Objective:** Test entire workflow from feature to production.

#### Test Case 12.1: Feature to Production Flow

1. **Create Feature Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/TEST-001-complete-workflow
   ```

2. **Implement Feature**
   ```bash
   echo "new feature" >> feature.txt
   git add feature.txt
   git commit -m "feat(test): add complete workflow test"
   git push origin feature/TEST-001-complete-workflow
   ```

3. **Create PR to develop**
   - Verify CI runs
   - Get approval
   - Merge (squash)

4. **Create PR to staging**
   - Verify CI runs
   - Verify deployment to staging
   - Get approval
   - Merge

5. **Create PR to main**
   - Verify CI runs
   - Verify staging tests passed
   - Get 2 approvals
   - Merge

6. **Verify Production**
   - Deployment completes
   - Smoke tests pass
   - Release created

**Status:** ✅ PASS / ❌ FAIL

---

### Test 13: Hotfix Workflow

**Objective:** Test critical bug fix workflow.

#### Test Case 13.1: Hotfix Flow

1. **Create Hotfix Branch**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/TEST-999-critical-fix
   ```

2. **Implement Fix**
   ```bash
   echo "hotfix" >> fix.txt
   git add fix.txt
   git commit -m "fix(critical): emergency production fix"
   git push origin hotfix/TEST-999-critical-fix
   ```

3. **Create PR to main**
   - Verify CI runs
   - Get 2 approvals
   - Merge

4. **Backport to develop**
   ```bash
   git checkout develop
   git merge hotfix/TEST-999-critical-fix
   git push origin develop
   ```

5. **Verify**
   - Production deployed
   - develop updated

**Status:** ✅ PASS / ❌ FAIL

---

## Test Scenarios

### Scenario 1: Unauthorized Merge Attempt

**Setup:** User without approval rights tries to merge

**Steps:**
1. Create PR
2. User attempts to merge without approval

**Expected:** Merge blocked

**Status:** ✅ PASS / ❌ FAIL

---

### Scenario 2: Concurrent PRs

**Setup:** Multiple PRs to same branch

**Steps:**
1. Create two PRs to develop
2. Merge first PR
3. Second PR becomes outdated
4. Attempt to merge second PR

**Expected:** Must update branch first

**Status:** ✅ PASS / ❌ FAIL

---

### Scenario 3: Failed CI Recovery

**Setup:** PR with failed CI

**Steps:**
1. Create PR with failing tests
2. Fix tests
3. Push fix
4. Wait for CI

**Expected:** CI reruns and passes

**Status:** ✅ PASS / ❌ FAIL

---

## Automated Test Scripts

### Script 1: Branch Protection Test Suite

Create file: `scripts/test-branch-protection.sh`

```bash
#!/bin/bash

echo "🔍 Testing Branch Protection Rules..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_protection() {
    local branch=$1
    local test_name=$2
    
    echo -e "\n${YELLOW}Testing: ${test_name}${NC}"
    
    git checkout ${branch} 2>/dev/null
    git pull origin ${branch} 2>/dev/null
    
    echo "test" >> .test-protection-file
    git add .test-protection-file
    git commit -m "test: protection check" 2>/dev/null
    
    if git push origin ${branch} 2>&1 | grep -q "protected branch"; then
        echo -e "${GREEN}✓ PASS: ${test_name}${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL: ${test_name}${NC}"
        ((TESTS_FAILED++))
    fi
    
    # Cleanup
    git reset --hard HEAD~1 2>/dev/null
    rm -f .test-protection-file
}

# Run tests
test_protection "main" "Main branch protection"
test_protection "staging" "Staging branch protection"
test_protection "develop" "Develop branch protection"

# Summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"

if [ ${TESTS_FAILED} -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed! ✗${NC}"
    exit 1
fi
```

### Script 2: Workflow Trigger Test

Create file: `scripts/test-workflow-trigger.sh`

```bash
#!/bin/bash

echo "🚀 Testing Workflow Triggers..."

# Create test branch
BRANCH_NAME="test/workflow-trigger-$(date +%s)"

git checkout develop
git pull origin develop
git checkout -b ${BRANCH_NAME}

# Make change
echo "test: workflow trigger" >> test-workflow.txt
git add test-workflow.txt
git commit -m "test: trigger workflow"
git push origin ${BRANCH_NAME}

# Create PR using GitHub CLI
gh pr create --base develop --head ${BRANCH_NAME} --title "Test: Workflow Trigger" --body "Automated test for workflow triggers"

# Wait for checks
echo "⏳ Waiting for CI checks..."
sleep 30

# Check status
gh pr checks

# Cleanup
gh pr close ${BRANCH_NAME} --delete-branch

echo "✓ Workflow trigger test complete"
```

---

## Verification Checklist

### Branch Protection Rules

- [ ] **Main Branch**
  - [ ] Direct commits blocked
  - [ ] Force pushes blocked
  - [ ] Requires 2 approvals
  - [ ] Status checks required
  - [ ] Conversation resolution required
  - [ ] Linear history enforced

- [ ] **Staging Branch**
  - [ ] Direct commits blocked
  - [ ] Force pushes blocked
  - [ ] Requires 1 approval
  - [ ] Status checks required
  - [ ] Conversation resolution required

- [ ] **Develop Branch**
  - [ ] Direct commits blocked
  - [ ] Force pushes blocked
  - [ ] Requires 1 approval
  - [ ] Status checks required

### CI/CD Workflows

- [ ] **CI Workflow**
  - [ ] Triggers on PR to develop
  - [ ] Triggers on PR to staging
  - [ ] Triggers on PR to main
  - [ ] Lint job runs
  - [ ] Type check job runs
  - [ ] Test job runs
  - [ ] Build job runs

- [ ] **Deployment Workflows**
  - [ ] Deploy to development on merge to develop
  - [ ] Deploy to staging on merge to staging
  - [ ] Deploy to production on merge to main
  - [ ] E2E tests run after deployment
  - [ ] Smoke tests run in appropriate environments

### Merge Restrictions

- [ ] Cannot merge without approval
- [ ] Cannot merge with failing checks
- [ ] Cannot merge with unresolved comments
- [ ] Can only use squash/rebase merge (not merge commit) for feature branches
- [ ] Stale approvals dismissed on new commits

### Code Review Enforcement

- [ ] Self-approval prevented (if configured)
- [ ] Required reviewers enforced
- [ ] Code owners approval required (for main)
- [ ] Review comments must be addressed

---

## Test Results Template

### Test Execution Date: _____________

### Tester: _____________

### Results

| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| 1.1 | Direct Push to main | ⬜ PASS / ⬜ FAIL | |
| 1.2 | Direct Push to staging | ⬜ PASS / ⬜ FAIL | |
| 1.3 | Direct Push to develop | ⬜ PASS / ⬜ FAIL | |
| 2.1 | Force Push Prevention | ⬜ PASS / ⬜ FAIL | |
| 3.1 | Branch Deletion Prevention | ⬜ PASS / ⬜ FAIL | |
| 4.1 | Approval Required (develop) | ⬜ PASS / ⬜ FAIL | |
| 4.2 | 2 Approvals Required (main) | ⬜ PASS / ⬜ FAIL | |
| 5.1 | Stale Review Dismissal | ⬜ PASS / ⬜ FAIL | |
| 6.1 | CI Trigger (develop) | ⬜ PASS / ⬜ FAIL | |
| 6.2 | CI Trigger (staging) | ⬜ PASS / ⬜ FAIL | |
| 6.3 | CI Trigger (main) | ⬜ PASS / ⬜ FAIL | |
| 7.1 | Lint Enforcement | ⬜ PASS / ⬜ FAIL | |
| 8.1 | Type Check Enforcement | ⬜ PASS / ⬜ FAIL | |
| 9.1 | Test Enforcement | ⬜ PASS / ⬜ FAIL | |
| 10.1 | Build Enforcement | ⬜ PASS / ⬜ FAIL | |
| 11.1 | Deploy to Development | ⬜ PASS / ⬜ FAIL | |
| 11.2 | Deploy to Staging | ⬜ PASS / ⬜ FAIL | |
| 11.3 | Deploy to Production | ⬜ PASS / ⬜ FAIL | |
| 12.1 | Complete Feature Flow | ⬜ PASS / ⬜ FAIL | |
| 13.1 | Hotfix Flow | ⬜ PASS / ⬜ FAIL | |

### Overall Status: ⬜ PASSED / ⬜ FAILED

### Issues Found:


### Recommendations:


---

**Document Version:** 1.0.0  
**Last Updated:** October 31, 2025  
**Maintained By:** QA Team

