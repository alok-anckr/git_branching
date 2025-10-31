# Quick Start Guide - Git Branching Strategy

This is a condensed guide to get you started quickly with the branching strategy. For detailed information, refer to the comprehensive documentation files.

## 📚 Documentation Index

- **[BRANCHING_STRATEGY.md](BRANCHING_STRATEGY.md)** - Complete branching strategy documentation
- **[BRANCH_PROTECTION_SETUP.md](BRANCH_PROTECTION_SETUP.md)** - Step-by-step setup instructions
- **[BRANCH_PROTECTION_TESTING.md](BRANCH_PROTECTION_TESTING.md)** - Testing procedures and verification
- **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Implementation checklist
- **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** - This file

---

## 🚀 Implementation (30-Minute Setup)

### Step 1: Create Branches (5 minutes)

```bash
# Run the automated script
chmod +x scripts/create-branches.sh
./scripts/create-branches.sh
```

**Or manually:**
```bash
# Create develop branch
git checkout -b develop
git push -u origin develop

# Create staging branch
git checkout main
git checkout -b staging
git push -u origin staging
```

---

### Step 2: Setup GitHub Actions (5 minutes)

```bash
# Commit workflow files (already created in .github/workflows/)
chmod +x scripts/setup-workflows.sh
./scripts/setup-workflows.sh
```

**Or manually:**
```bash
git checkout main
git add .github/workflows/
git commit -m "ci: add GitHub Actions workflows"
git push origin main

# Sync to other branches
git checkout develop && git merge main && git push
git checkout staging && git merge main && git push
```

---

### Step 3: Configure Branch Protection (15 minutes)

#### For `main` branch:

1. Go to GitHub: **Settings > Branches > Add rule**
2. Branch name pattern: `main`
3. Enable:
   - ☑️ Require pull request (2 approvals)
   - ☑️ Require status checks: `lint`, `typecheck`, `test`, `build`, `ci-success`
   - ☑️ Require conversation resolution
   - ☑️ Require linear history
   - ☑️ Restrict push access
4. Click **Create**

#### For `staging` branch:

- Same as `main` but with **1 approval** required

#### For `develop` branch:

- Same as `staging` but without push restrictions

**Note:** Status checks only appear after running once. Create a test PR first!

---

### Step 4: Configure Environments (5 minutes)

Go to **Settings > Environments** and create:

1. **development**
   - No reviewers
   - Deployment: `develop` only

2. **staging**
   - 1 reviewer required
   - Deployment: `staging` only

3. **production**
   - 2 reviewers required
   - Deployment: `main` only

---

### Step 5: Test Everything (10 minutes)

```bash
# Run automated tests
chmod +x scripts/test-branch-protection.sh
./scripts/test-branch-protection.sh
```

**Manual verification:**
```bash
# This should fail (protected branch)
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test"
git push origin main  # Should be rejected ✓
```

---

## 🌿 Daily Workflow

### Working on a Feature

```bash
# 1. Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/TASK-123-feature-name

# 2. Make changes and commit
git add .
git commit -m "feat(module): add new feature"

# 3. Push and create PR
git push origin feature/TASK-123-feature-name

# 4. Create PR via GitHub to 'develop'
# 5. Wait for CI checks to pass
# 6. Get approval and merge (squash)
# 7. Delete branch
```

### Releasing to Staging

```bash
# Create PR: develop → staging
# Get approval, merge
# Automatic deployment to staging
```

### Releasing to Production

```bash
# Create PR: staging → main
# Get 2 approvals, merge
# Automatic deployment to production
```

### Emergency Hotfix

```bash
# 1. Create from main
git checkout main
git pull origin main
git checkout -b hotfix/TASK-999-critical-fix

# 2. Fix and commit
git add .
git commit -m "fix(critical): emergency fix"

# 3. PR to main (get 2 approvals)
git push origin hotfix/TASK-999-critical-fix

# 4. After merge, backport to develop
git checkout develop
git merge hotfix/TASK-999-critical-fix
git push origin develop
```

---

## 🎯 Branch Overview

| Branch | Purpose | Protected | Approvals | Deploy To |
|--------|---------|-----------|-----------|-----------|
| `main` | Production | ✅ | 2 | Production |
| `staging` | Pre-production | ✅ | 1 | Staging |
| `develop` | Development | ✅ | 1 | Development |
| `feature/*` | New features | ❌ | - | - |
| `bugfix/*` | Bug fixes | ❌ | - | - |
| `hotfix/*` | Emergency fixes | ❌ | - | - |

---

## 📋 Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

**Examples:**
```bash
git commit -m "feat(auth): add two-factor authentication"
git commit -m "fix(billing): correct subscription renewal date"
git commit -m "docs(readme): update installation instructions"
```

---

## ✅ Checklist for PRs

Before creating a PR:
- [ ] Code follows project style guidelines
- [ ] All tests pass locally (`pnpm test`)
- [ ] Linting passes (`pnpm lint`)
- [ ] Type checking passes (`pnpm typecheck`)
- [ ] Commit messages follow convention
- [ ] Branch is up to date with target branch
- [ ] Self-review completed

---

## 🚨 Common Issues & Solutions

### "Cannot push to protected branch"
**Solution:** This is expected! Create a PR instead.

### "Status checks required"
**Solution:** Wait for CI to complete. All checks must pass.

### "Review required"
**Solution:** Request review from team member(s).

### "Branch is out of date"
**Solution:**
```bash
git checkout your-branch
git fetch origin
git rebase origin/develop  # or target branch
git push --force-with-lease
```

### "Merge conflicts"
**Solution:**
```bash
git checkout your-branch
git fetch origin
git merge origin/develop  # or target branch
# Resolve conflicts
git add .
git commit
git push
```

---

## 📞 Need Help?

- **Documentation:** Check the comprehensive docs in repository root
- **Issues:** Create an issue in GitHub
- **Questions:** Contact DevOps team

---

## 🔗 Useful Commands

```bash
# View all branches
git branch -a

# View branch protection status (requires GitHub CLI)
gh api repos/:owner/:repo/branches/main/protection

# Create PR (requires GitHub CLI)
gh pr create --base develop --head feature/my-feature

# Check PR status
gh pr status

# List workflows
gh workflow list

# View workflow runs
gh run list

# Check current PR checks
gh pr checks
```

---

## 🎓 Learn More

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)

---

**Quick Start Version:** 1.0.0  
**Last Updated:** October 31, 2025

