# Git Branching Strategy

## Overview

This document defines the Git branching strategy for the project, including branch naming conventions, protection rules, merge policies, and workflow guidelines.

## Branch Structure

### Core Branches

#### 1. `main` (Production)
- **Purpose**: Production-ready code
- **Deployment**: Automatically deployed to production environment
- **Source**: Receives merges from `staging` only
- **Protection**: Highest level of protection
- **Naming**: `main`

#### 2. `staging` (Pre-Production)
- **Purpose**: Pre-production testing and QA validation
- **Deployment**: Automatically deployed to staging environment
- **Source**: Receives merges from `develop` only
- **Protection**: High level of protection
- **Naming**: `staging`

#### 3. `develop` (Development)
- **Purpose**: Integration branch for ongoing development
- **Deployment**: Automatically deployed to development environment
- **Source**: Receives merges from feature branches
- **Protection**: Moderate protection
- **Naming**: `develop`

### Supporting Branches

#### Feature Branches
- **Purpose**: Development of new features
- **Naming Convention**: `feature/<ticket-id>-<short-description>`
  - Examples: 
    - `feature/TASK-123-user-authentication`
    - `feature/TASK-456-payment-integration`
- **Source**: Created from `develop`
- **Merge Target**: `develop`
- **Lifecycle**: Deleted after merge

#### Bugfix Branches
- **Purpose**: Bug fixes for issues found in development
- **Naming Convention**: `bugfix/<ticket-id>-<short-description>`
  - Examples:
    - `bugfix/TASK-789-login-error`
    - `bugfix/TASK-101-typo-fix`
- **Source**: Created from `develop`
- **Merge Target**: `develop`
- **Lifecycle**: Deleted after merge

#### Hotfix Branches
- **Purpose**: Critical production bug fixes
- **Naming Convention**: `hotfix/<ticket-id>-<short-description>`
  - Examples:
    - `hotfix/TASK-999-payment-critical-fix`
    - `hotfix/TASK-888-security-patch`
- **Source**: Created from `main`
- **Merge Target**: `main` AND `develop` (to keep changes synchronized)
- **Lifecycle**: Deleted after merge

#### Release Branches (Optional)
- **Purpose**: Preparation for a new production release
- **Naming Convention**: `release/<version>`
  - Examples:
    - `release/1.2.0`
    - `release/2.0.0-beta`
- **Source**: Created from `develop`
- **Merge Target**: `main` and `develop`
- **Lifecycle**: Deleted after merge

## Branching Flow

```
main (production)
  ↑
  └── staging (pre-production)
        ↑
        └── develop (development)
              ↑
              ├── feature/TASK-123-new-feature
              ├── feature/TASK-456-another-feature
              └── bugfix/TASK-789-fix-bug

hotfix/TASK-999-critical-fix → main → develop
```

## Branch Protection Rules

### `main` Branch Protection

**Required Settings:**
- ✅ Require pull request reviews before merging
  - Required approvals: 2
  - Dismiss stale pull request approvals when new commits are pushed
  - Require review from Code Owners
- ✅ Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Required checks:
    - `lint`
    - `typecheck`
    - `test`
    - `build`
- ✅ Require conversation resolution before merging
- ✅ Require signed commits
- ✅ Require linear history (no merge commits)
- ✅ Do not allow bypassing the above settings
- ✅ Restrict who can push to matching branches (Admins only)
- ✅ Allow force pushes: Disabled
- ✅ Allow deletions: Disabled

### `staging` Branch Protection

**Required Settings:**
- ✅ Require pull request reviews before merging
  - Required approvals: 1
  - Dismiss stale pull request approvals when new commits are pushed
- ✅ Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Required checks:
    - `lint`
    - `typecheck`
    - `test`
    - `build`
- ✅ Require conversation resolution before merging
- ✅ Require linear history (no merge commits)
- ✅ Restrict who can push to matching branches (Developers and Admins)
- ✅ Allow force pushes: Disabled
- ✅ Allow deletions: Disabled

### `develop` Branch Protection

**Required Settings:**
- ✅ Require pull request reviews before merging
  - Required approvals: 1
- ✅ Require status checks to pass before merging
  - Required checks:
    - `lint`
    - `typecheck`
    - `test`
    - `build`
- ✅ Require conversation resolution before merging
- ✅ Allow force pushes: Disabled
- ✅ Allow deletions: Disabled

## Merge Strategy

### Pull Request Requirements

All merges to protected branches (`main`, `staging`, `develop`) must be done via Pull Requests with the following requirements:

1. **Code Review**: At least one approval required (two for `main`)
2. **CI/CD Checks**: All automated checks must pass
3. **Conversation Resolution**: All comments must be resolved
4. **Up-to-date Branch**: Branch must be current with target branch

### Merge Methods

#### Squash Merge (Recommended for Feature Branches)
- **Use for**: `feature/*`, `bugfix/*` → `develop`
- **Benefits**: 
  - Keeps commit history clean
  - Consolidates all feature commits into one
  - Easy to revert if needed
- **Format**: `<type>(<scope>): <description> (#PR-number)`
  - Example: `feat(auth): add OAuth authentication (#123)`

#### Merge Commit (For Branch-to-Branch)
- **Use for**: `develop` → `staging`, `staging` → `main`
- **Benefits**:
  - Preserves complete history
  - Shows merge points clearly
  - Maintains traceability

#### Rebase and Merge (Alternative)
- **Use for**: Small, atomic commits that tell a story
- **Benefits**:
  - Linear history
  - Clean commit log
- **Requirement**: All commits must be meaningful and well-formatted

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

**Examples:**
```
feat(auth): add two-factor authentication

Implement TOTP-based 2FA for user accounts.
Includes SMS and authenticator app support.

Closes #456

---

fix(billing): correct subscription renewal logic

The subscription renewal date was incorrectly calculated
for annual plans. This fix ensures proper date handling.

Fixes #789
```

## Workflow Guidelines

### Feature Development Workflow

1. **Create Feature Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/TASK-123-feature-name
   ```

2. **Develop and Commit**
   ```bash
   # Make changes
   git add .
   git commit -m "feat(module): add new feature"
   ```

3. **Keep Branch Updated**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/TASK-123-feature-name
   git rebase develop
   ```

4. **Push and Create PR**
   ```bash
   git push origin feature/TASK-123-feature-name
   # Create Pull Request to develop
   ```

5. **After Merge**
   ```bash
   git checkout develop
   git pull origin develop
   git branch -d feature/TASK-123-feature-name
   ```

### Release to Staging Workflow

1. **Create PR from develop to staging**
   ```bash
   # On GitHub: Create Pull Request
   # Base: staging
   # Compare: develop
   ```

2. **Review and Merge**
   - Ensure all tests pass
   - Get required approvals
   - Merge using merge commit

3. **Verify Staging Deployment**
   - Check staging environment
   - Run smoke tests
   - QA validation

### Production Release Workflow

1. **Create PR from staging to main**
   ```bash
   # On GitHub: Create Pull Request
   # Base: main
   # Compare: staging
   ```

2. **Final Review and Merge**
   - Ensure all staging tests passed
   - Get required approvals (2 reviewers)
   - Merge using merge commit

3. **Tag Release**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.2.0 -m "Release version 1.2.0"
   git push origin v1.2.0
   ```

4. **Verify Production Deployment**
   - Monitor production deployment
   - Run smoke tests
   - Monitor error tracking

### Hotfix Workflow

1. **Create Hotfix Branch**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/TASK-999-critical-fix
   ```

2. **Develop and Commit Fix**
   ```bash
   # Make changes
   git add .
   git commit -m "fix(critical): resolve production issue"
   ```

3. **Create PR to main**
   ```bash
   git push origin hotfix/TASK-999-critical-fix
   # Create Pull Request to main
   ```

4. **After Merge to main**
   ```bash
   # Also merge to develop to keep in sync
   git checkout develop
   git pull origin develop
   git merge hotfix/TASK-999-critical-fix
   git push origin develop
   ```

5. **Tag and Deploy**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.2.1 -m "Hotfix version 1.2.1"
   git push origin v1.2.1
   ```

## CI/CD Integration

### GitHub Actions Workflows

The following GitHub Actions workflows are triggered based on branch activity:

#### On All PRs and Pushes
- **Lint**: ESLint and Prettier checks
- **Type Check**: TypeScript compilation
- **Test**: Unit and integration tests
- **Build**: Verify application builds successfully

#### On Merge to `develop`
- Deploy to Development environment
- Run E2E tests

#### On Merge to `staging`
- Deploy to Staging environment
- Run E2E tests
- Run smoke tests

#### On Merge to `main`
- Deploy to Production environment
- Run smoke tests
- Create GitHub Release
- Send deployment notifications

## Best Practices

### Do's ✅

- ✅ Always work in feature branches
- ✅ Keep feature branches small and focused
- ✅ Write meaningful commit messages
- ✅ Pull latest changes frequently
- ✅ Rebase feature branches before creating PR
- ✅ Run tests locally before pushing
- ✅ Review your own code before requesting review
- ✅ Resolve all PR comments before merging
- ✅ Delete branches after merging
- ✅ Tag all production releases

### Don'ts ❌

- ❌ Never commit directly to `main`, `staging`, or `develop`
- ❌ Never force push to protected branches
- ❌ Never merge without CI passing
- ❌ Never merge without required approvals
- ❌ Never commit sensitive data or credentials
- ❌ Never use generic commit messages ("fix", "update", "wip")
- ❌ Never merge with unresolved comments
- ❌ Never skip code review
- ❌ Never merge without testing
- ❌ Never merge broken code

## Emergency Procedures

### Rollback Production

If a critical issue is discovered in production:

1. **Identify Last Good Release**
   ```bash
   git tag --list
   ```

2. **Revert to Previous Version**
   ```bash
   git checkout main
   git revert <bad-commit-hash>
   git push origin main
   ```

3. **Or Deploy Previous Tag**
   ```bash
   git checkout v1.2.0
   # Trigger deployment
   ```

### Fix Failed Merge

If a merge causes issues:

1. **Revert the Merge**
   ```bash
   git revert -m 1 <merge-commit-hash>
   git push origin <branch>
   ```

2. **Fix in New Branch**
   ```bash
   git checkout -b fix/revert-merge-issue
   # Fix the issues
   # Create new PR
   ```

## Monitoring and Metrics

Track the following metrics to ensure branching strategy effectiveness:

- **PR Merge Time**: Average time from PR creation to merge
- **Build Success Rate**: Percentage of successful builds
- **Deployment Frequency**: Number of deployments per week
- **Rollback Rate**: Percentage of deployments requiring rollback
- **Code Review Time**: Average time for code review
- **Branch Lifetime**: Average age of feature branches

## Review and Updates

This branching strategy should be reviewed quarterly or when:
- Team size changes significantly
- Project complexity increases
- Deployment frequency changes
- Issues with current strategy are identified

---

**Document Version**: 1.0.0  
**Last Updated**: October 31, 2025  
**Next Review Date**: January 31, 2026  
**Maintained By**: Engineering Team

#Fake Pr at staging branch



