# CI/CD Pipeline Status & Next Steps

## Current State

### ✅ What's Already Set Up

1. **Application Deployed**
   - Digital Ocean droplet: 161.35.142.103
   - Puma + Nginx running
   - PostgreSQL + Redis configured
   - Application is live and working

2. **CI Pipeline Exists**
   - `.github/workflows/ci.yml` - Runs tests on push/PR
   - Tests: RSpec, RuboCop
   - Security: Brakeman, bundler-audit
   - **Status:** Active but NO deployment

3. **New CD Workflows Created**
   - `.github/workflows/deploy.yml` - Standalone deployment
   - `.github/workflows/ci-cd.yml` - Integrated CI/CD (recommended)
   - **Status:** Ready to use but needs configuration

### ❌ What's NOT Connected Yet

**The CI/CD pipeline is NOT orchestrated with deployment yet because:**

1. GitHub Secrets are not configured
2. Workflows are created but not active
3. Need to choose which workflow to use

## The Answer to Your Question

**"Does the CI/CD pipeline work with deployment? Is everything orchestrated together?"**

**Current Answer: NO** 
- Tests run automatically on push ✓
- Deployment is still manual ✗
- They are NOT connected yet

**After Setup Answer: YES**
- Tests will run automatically ✓
- If tests pass, deployment happens automatically ✓
- Fully orchestrated pipeline ✓

## How to Make Them Work Together

### Option 1: Quick Manual Check (See if it works)

Run the setup script to see what secrets are needed:
```bash
./scripts/setup-github-secrets.sh
```

### Option 2: Complete Setup (Recommended)

Follow these steps to enable full CI/CD:

#### Step 1: Add GitHub Secrets

Go to: https://github.com/fassousa/currency-converter-ruby/settings/secrets/actions

Add these 3 secrets:

1. **DEPLOY_HOST**
   ```
   161.35.142.103
   ```

2. **DEPLOY_USER**
   ```
   root
   ```

3. **DEPLOY_SSH_KEY**
   ```
   [Content of ~/.ssh/digitalocean_deploy]
   ```
   
   To get the key:
   ```bash
   cat ~/.ssh/digitalocean_deploy
   ```
   Copy everything including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`

#### Step 2: Choose Your Workflow

You have 3 options:

**A) Full CI/CD (Recommended) - `ci-cd.yml`**
- Runs tests on every push
- Deploys to production when merging to `main`
- Security scans before deployment
- Automatic rollback capability

**B) Separate CI and Deploy - `ci.yml` + `deploy.yml`**
- CI runs on all branches
- Deploy is manual trigger only
- More control, less automation

**C) Keep Current CI - `ci.yml` only**
- No automatic deployment
- Deploy manually via SSH (current state)

**Recommendation:** Use option A (ci-cd.yml)

#### Step 3: Enable the CI/CD Workflow

If choosing option A (recommended):

```bash
# Disable the old CI workflow to avoid duplication
git mv .github/workflows/ci.yml .github/workflows/ci.yml.backup

# Remove the standalone deploy workflow (ci-cd has it integrated)
rm .github/workflows/deploy.yml

# Keep only ci-cd.yml
git add .github/workflows/

# Commit
git commit -m "Enable integrated CI/CD pipeline with automatic deployment"

# Push
git push origin fagnner_sousa
```

#### Step 4: Test the Pipeline

**Test on feature branch first:**
```bash
# Make a small change
echo "# CI/CD Test" >> README.md

# Commit and push
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin fagnner_sousa

# Go to GitHub Actions to watch it run
# https://github.com/fassousa/currency-converter-ruby/actions
```

**This will:**
- ✅ Run tests
- ✅ Run security scans
- ❌ NOT deploy (because you're not on `main` branch)

**Deploy to production:**
```bash
# Merge to main (after PR approval)
git checkout main
git pull origin main
git merge fagnner_sousa
git push origin main

# Go to GitHub Actions to watch deployment
# https://github.com/fassousa/currency-converter-ruby/actions
```

**This will:**
- ✅ Run tests
- ✅ Run security scans
- ✅ Deploy to production automatically
- ✅ Run health check
- ✅ Notify success/failure

#### Step 5: Set Up Branch Protection (Optional but Recommended)

1. Go to: https://github.com/fassousa/currency-converter-ruby/settings/branches
2. Add rule for `main` branch:
   - ✅ Require pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Select: `test` and `security` checks
   - ✅ Require branches to be up to date

This ensures:
- No direct pushes to production
- Tests must pass before deployment
- Code review required

## What Happens in the Orchestrated Pipeline

### Full Flow Diagram

```
Developer pushes code to fagnner_sousa branch
                    ↓
        GitHub Actions Triggered
                    ↓
    ┌───────────────────────────────┐
    │   Job 1: Test & Lint          │
    │   - Setup PostgreSQL & Redis  │
    │   - Install dependencies      │
    │   - Run RuboCop               │
    │   - Run RSpec tests           │
    │   - Upload coverage           │
    └───────────────┬───────────────┘
                    ↓
              Tests Pass? ──No──→ ❌ Stop (notify failure)
                    ↓
                   Yes
                    ↓
    ┌───────────────────────────────┐
    │   Job 2: Security Scan        │
    │   - Run Brakeman              │
    │   - Run bundler-audit         │
    └───────────────┬───────────────┘
                    ↓
           Security OK? ──No──→ ❌ Stop (notify failure)
                    ↓
                   Yes
                    ↓
            Is this main branch? ──No──→ ✅ Done (ready to merge)
                    ↓
                   Yes
                    ↓
    ┌───────────────────────────────┐
    │   Job 3: Deploy               │
    │   - SSH to server             │
    │   - Pull latest code          │
    │   - Install dependencies      │
    │   - Run migrations            │
    │   - Restart Puma              │
    │   - Health check              │
    └───────────────┬───────────────┘
                    ↓
          Health check OK? ──No──→ ❌ Deployment failed
                    ↓
                   Yes
                    ↓
        🎉 Successfully deployed to production!
```

### Timeline Example

```
0:00 - Push to main branch
0:01 - GitHub Actions starts
0:02 - Installing dependencies
0:04 - Running tests (129 tests)
0:06 - Tests passed ✓
0:06 - Running security scans
0:07 - Security scans passed ✓
0:07 - Starting deployment
0:08 - SSH to server
0:09 - Pulling code
0:10 - Installing gems
0:12 - Running migrations
0:13 - Restarting Puma
0:14 - Health check
0:15 - Deployment successful! 🎉
```

## Monitoring & Verification

### Check if CI/CD is Working

```bash
# 1. Check if secrets are configured
# Go to: https://github.com/fassousa/currency-converter-ruby/settings/secrets/actions
# You should see: DEPLOY_HOST, DEPLOY_USER, DEPLOY_SSH_KEY

# 2. Check if workflow is enabled
# Go to: https://github.com/fassousa/currency-converter-ruby/actions
# You should see workflows listed

# 3. Trigger a test run
git commit --allow-empty -m "Test CI/CD pipeline"
git push origin fagnner_sousa

# 4. Watch it run
# Go to: https://github.com/fassousa/currency-converter-ruby/actions
```

### Verify Deployment

After a successful deployment:

```bash
# Check health endpoint
curl -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     http://161.35.142.103/api/v1/health

# Should return:
# {"status":"healthy", ...}
```

## Comparison: Before vs After

### Before (Current State)

```
Developer Workflow:
1. Write code
2. Commit and push
3. GitHub Actions runs tests ✓
4. Tests pass ✓
5. Developer manually SSHs to server
6. Developer manually pulls code
7. Developer manually restarts services
8. Developer manually verifies deployment
```

**Deployment time:** 10-15 minutes (manual)
**Risk:** Human error in deployment steps

### After (With CI/CD Orchestration)

```
Developer Workflow:
1. Write code
2. Create PR to main
3. GitHub Actions runs tests ✓
4. Review and merge PR
5. 🤖 Everything else is automatic:
   - Tests run
   - Security scans
   - Deployment
   - Health check
   - Notification
```

**Deployment time:** 5-7 minutes (automated)
**Risk:** Minimal - standardized process

## Rollback Strategy

If deployment fails or issues are found:

### Automatic Rollback (Built-in)

The pipeline stores the previous commit. If health check fails, you can trigger rollback:

```bash
# Go to GitHub Actions
# Select "CI/CD Pipeline"
# Click "Run workflow"
# Select the rollback job
```

### Manual Rollback

```bash
# SSH to server
ssh -i ~/.ssh/digitalocean_deploy root@161.35.142.103

# Switch to rails user
su - rails
cd currency-converter-ruby/backend

# View commit history
git log --oneline -5

# Rollback to previous commit
git checkout <previous-commit-hash>

# Reinstall and restart
export $(grep -v "^#" .env.production | grep -v "^$" | xargs)
RAILS_ENV=production bundle install
exit

sudo systemctl restart puma
```

## Cost Analysis

### GitHub Actions Free Tier

- **Included:** 2,000 minutes/month
- **Per deployment:** ~5 minutes
- **Estimated capacity:** ~400 deployments/month
- **Your likely usage:** 20-50 deployments/month
- **Cost:** $0/month (within free tier)

### Time Savings

- **Manual deployment:** 10-15 minutes each
- **Automated deployment:** 0 minutes (hands-off)
- **Deployments per month:** ~20
- **Time saved:** 3-5 hours/month

## Troubleshooting

### Issue: "Secrets not found"

**Solution:** Add the 3 secrets to GitHub (see Step 1 above)

### Issue: "Permission denied (publickey)"

**Solution:** 
- Verify SSH key is correct in secrets
- Test SSH connection manually:
  ```bash
  ssh -i ~/.ssh/digitalocean_deploy root@161.35.142.103
  ```

### Issue: "Health check failed"

**Solution:**
- Check Puma logs: `sudo journalctl -u puma -n 100`
- Check if migration failed
- Manually restart Puma: `sudo systemctl restart puma`

### Issue: "Deployment runs on every push"

**Expected behavior:** 
- Tests run on every push ✓
- Deployment only on `main` branch ✓

If deploying on other branches, check the workflow file:
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

## Next Steps

### Immediate (Required for CI/CD)

- [ ] Add 3 GitHub secrets
- [ ] Choose workflow strategy
- [ ] Enable chosen workflow
- [ ] Test with a small change
- [ ] Monitor first deployment

### Short-term (Recommended)

- [ ] Set up branch protection
- [ ] Add Slack/email notifications
- [ ] Document deployment process for team
- [ ] Set up staging environment
- [ ] Add deployment approvals

### Long-term (Nice to have)

- [ ] Add deployment metrics/monitoring
- [ ] Set up blue-green deployment
- [ ] Add performance testing in pipeline
- [ ] Set up automated backups before deployment
- [ ] Add deployment frequency metrics

## Summary

**Current State:** CI exists but NOT connected to deployment

**To Connect Them:** 
1. Add GitHub secrets (5 minutes)
2. Enable ci-cd.yml workflow (2 minutes)
3. Test with a push to main (7 minutes)

**Total Setup Time:** ~15 minutes

**Result:** Fully automated deployment pipeline where every merge to `main` automatically deploys to production after passing tests and security scans.

---

**Ready to set it up?** Run: `./scripts/setup-github-secrets.sh`
