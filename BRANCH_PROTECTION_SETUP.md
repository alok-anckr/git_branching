# Branch Protection Rules Setup Guide

This guide provides step-by-step instructions for configuring branch protection rules in GitHub to enforce the branching strategy.

## Prerequisites

- Admin access to the GitHub repository
- Branches created: `main`, `staging`, `develop`
- GitHub Actions workflows configured

## Table of Contents

1. [Create Required Branches](#create-required-branches)
2. [Configure Branch Protection for `main`](#configure-branch-protection-for-main)
3. [Configure Branch Protection for `staging`](#configure-branch-protection-for-staging)
4. [Configure Branch Protection for `develop`](#configure-branch-protection-for-develop)
5. [Setup GitHub Environments](#setup-github-environments)
6. [Configure Status Checks](#configure-status-checks)
7. [Verification Steps](#verification-steps)

---

## Create Required Branches

### Step 1: Create `develop` Branch

```bash
# From your local repository
git checkout -b develop
git push origin develop
```

### Step 2: Create `staging` Branch

```bash
git checkout -b staging
git push origin staging
```

### Step 3: Verify Branches

```bash
git branch -a
# You should see:
# * main
#   develop
#   staging
```

---

## Configure Branch Protection for `main`

### Navigate to Settings

1. Go to your GitHub repository
2. Click **Settings** tab
3. In the left sidebar, click **Branches**
4. Click **Add branch protection rule**

### Configure Protection Settings

#### Branch Name Pattern
```
main
```

#### Settings to Enable

**Protect matching branches:**

✅ **Require a pull request before merging**
- ☑️ Require approvals: `2`
- ☑️ Dismiss stale pull request approvals when new commits are pushed
- ☑️ Require review from Code Owners
- ☑️ Require approval of the most recent reviewable push

✅ **Require status checks to pass before merging**
- ☑️ Require branches to be up to date before merging
- Add required status checks:
  - `lint`
  - `typecheck`
  - `test`
  - `build`
  - `ci-success`

✅ **Require conversation resolution before merging**

✅ **Require signed commits** (Recommended)

✅ **Require linear history**
- This prevents merge commits and requires squash or rebase

✅ **Require deployments to succeed before merging** (Optional)
- Select environment: `production`

✅ **Lock branch** (Optional)
- Makes branch read-only

**Rules applied to everyone including administrators:**
- ☑️ Do not allow bypassing the above settings

**Restrict who can push to matching branches:**
- ☑️ Enable
- Add: Repository administrators only

✅ **Allow force pushes**
- ☐ Disable (Unchecked)

✅ **Allow deletions**
- ☐ Disable (Unchecked)

### Save Changes

Click **Create** or **Save changes**

---

## Configure Branch Protection for `staging`

### Navigate to Settings

1. Follow the same steps as above
2. Click **Add branch protection rule**

### Configure Protection Settings

#### Branch Name Pattern
```
staging
```

#### Settings to Enable

**Protect matching branches:**

✅ **Require a pull request before merging**
- ☑️ Require approvals: `1`
- ☑️ Dismiss stale pull request approvals when new commits are pushed
- ☐ Require review from Code Owners (Optional)

✅ **Require status checks to pass before merging**
- ☑️ Require branches to be up to date before merging
- Add required status checks:
  - `lint`
  - `typecheck`
  - `test`
  - `build`
  - `ci-success`

✅ **Require conversation resolution before merging**

✅ **Require linear history**

**Restrict who can push to matching branches:**
- ☑️ Enable
- Add: Developers team and administrators

✅ **Allow force pushes**
- ☐ Disable (Unchecked)

✅ **Allow deletions**
- ☐ Disable (Unchecked)

### Save Changes

Click **Create** or **Save changes**

---

## Configure Branch Protection for `develop`

### Navigate to Settings

1. Follow the same steps as above
2. Click **Add branch protection rule**

### Configure Protection Settings

#### Branch Name Pattern
```
develop
```

#### Settings to Enable

**Protect matching branches:**

✅ **Require a pull request before merging**
- ☑️ Require approvals: `1`

✅ **Require status checks to pass before merging**
- ☑️ Require branches to be up to date before merging
- Add required status checks:
  - `lint`
  - `typecheck`
  - `test`
  - `build`
  - `ci-success`

✅ **Require conversation resolution before merging**

**Restrict who can push to matching branches:**
- ☐ Disable (Allow all developers)

✅ **Allow force pushes**
- ☐ Disable (Unchecked)

✅ **Allow deletions**
- ☐ Disable (Unchecked)

### Save Changes

Click **Create** or **Save changes**

---

## Setup GitHub Environments

GitHub Environments provide deployment protection rules and secrets management.

### Create Development Environment

1. Go to **Settings** > **Environments**
2. Click **New environment**
3. Name: `development`
4. Configure:
   - ☐ Required reviewers: None
   - ☑️ Wait timer: 0 minutes
   - ☑️ Deployment branches: `develop` only
5. Add environment secrets:
   - `DEPLOY_TOKEN`
   - Any other environment-specific secrets
6. Click **Save protection rules**

### Create Staging Environment

1. Click **New environment**
2. Name: `staging`
3. Configure:
   - ☑️ Required reviewers: 1 reviewer
   - ☑️ Wait timer: 0 minutes
   - ☑️ Deployment branches: `staging` only
4. Add environment secrets
5. Click **Save protection rules**

### Create Production Environment

1. Click **New environment**
2. Name: `production`
3. Configure:
   - ☑️ Required reviewers: 2 reviewers
   - ☑️ Wait timer: 5 minutes (Optional safety delay)
   - ☑️ Deployment branches: `main` only
4. Add environment secrets
5. Click **Save protection rules**

---

## Configure Status Checks

### Enable GitHub Actions

1. Go to **Settings** > **Actions** > **General**
2. **Actions permissions:**
   - ☑️ Allow all actions and reusable workflows
3. **Workflow permissions:**
   - ☑️ Read and write permissions
   - ☑️ Allow GitHub Actions to create and approve pull requests
4. Click **Save**

### Verify Workflows

1. Go to **Actions** tab
2. Verify that workflows are enabled:
   - CI - Lint, Type Check, Test, Build
   - Deploy to Development
   - Deploy to Staging
   - Deploy to Production

### Add Status Checks to Branch Protection

After the first PR runs successfully:

1. Go to **Settings** > **Branches**
2. Edit each branch protection rule
3. Under "Require status checks to pass before merging":
   - Click **Add checks**
   - Select:
     - `lint`
     - `typecheck`
     - `test`
     - `build`
     - `ci-success`
4. Click **Save changes**

**Note:** Status checks only appear in the list after they've run at least once.

---

## Verification Steps

### Test Branch Protection

Follow these steps to verify the configuration:

#### 1. Test Direct Commit Block

```bash
# Try to push directly to main (should fail)
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test: direct commit"
git push origin main
```

**Expected Result:** Push should be rejected with an error message about branch protection.

#### 2. Test PR Requirements

1. Create a test feature branch:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b test/branch-protection
   echo "test" >> test.txt
   git add test.txt
   git commit -m "test: verify branch protection"
   git push origin test/branch-protection
   ```

2. Create a Pull Request to `develop`
3. Verify:
   - ✅ CI checks automatically run
   - ✅ Cannot merge until checks pass
   - ✅ Cannot merge until approved
   - ✅ Cannot merge with unresolved comments

#### 3. Test Status Check Enforcement

1. Create a PR with intentional linting errors
2. Verify:
   - ✅ Lint check fails
   - ✅ Merge button is disabled
   - ✅ Error is clearly shown

3. Fix the linting errors
4. Push changes
5. Verify:
   - ✅ CI re-runs automatically
   - ✅ Checks pass
   - ✅ Merge button becomes enabled (after approval)

#### 4. Test Approval Requirements

1. Create a PR to `main`
2. Verify:
   - ✅ Requires 2 approvals
   - ✅ Cannot self-approve (if configured)
   - ✅ Stale reviews dismissed on new commits

3. Create a PR to `staging`
4. Verify:
   - ✅ Requires 1 approval

5. Create a PR to `develop`
6. Verify:
   - ✅ Requires 1 approval

#### 5. Test Linear History

1. Try to merge using "Create a merge commit"
2. Verify:
   - ✅ Only "Squash and merge" or "Rebase and merge" available
   - ✅ "Create a merge commit" is disabled

---

## Troubleshooting

### Status Checks Not Appearing

**Problem:** Required status checks don't appear in the list.

**Solution:**
1. Trigger the workflow at least once by creating a PR
2. Wait for the workflow to complete
3. Go back to branch protection settings
4. The checks should now appear in the list

### Can't Add Required Reviewers

**Problem:** Team or user not available in reviewer list.

**Solution:**
1. Ensure the team/user has repository access
2. Go to **Settings** > **Collaborators and teams**
3. Add the required teams/users
4. Return to branch protection settings

### Workflow Not Running

**Problem:** GitHub Actions workflow doesn't trigger.

**Solution:**
1. Check **Actions** tab permissions
2. Verify workflow YAML syntax
3. Check if workflows are enabled for the repository
4. Ensure the branch pattern matches the trigger

### Force Push Still Works

**Problem:** Can still force push despite protection.

**Solution:**
1. Verify "Allow force pushes" is unchecked
2. Check if "Do not allow bypassing" is enabled
3. Verify you're not an administrator (they may bypass by default)

---

## Maintenance

### Regular Reviews

Review branch protection settings:
- **Quarterly:** Check if rules still align with team needs
- **After incidents:** Update rules if protection gaps are discovered
- **Team changes:** Update required reviewers and team access

### Updates

When updating branch protection:
1. Document changes in this file
2. Notify the team
3. Update any related documentation
4. Test the changes with a test PR

### Audit

Track these metrics:
- Number of direct push attempts blocked
- PR approval times
- Failed CI checks ratio
- Bypass requests (if any)

---

## Additional Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

---

## Quick Reference Commands

### View Branch Protection Status
```bash
gh api repos/:owner/:repo/branches/main/protection
```

### List Protected Branches
```bash
gh api repos/:owner/:repo/branches --jq '.[] | select(.protected == true) | .name'
```

### Check PR Status
```bash
gh pr checks
```

### View Required Status Checks
```bash
gh api repos/:owner/:repo/branches/main/protection/required_status_checks
```

---

**Document Version:** 1.0.0  
**Last Updated:** October 31, 2025  
**Maintained By:** DevOps Team

