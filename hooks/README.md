# Git Pre-Commit Hooks

Complete collection of pre-commit hooks for Python, SQL, dbt, YAML, and Snowflake workflows.

## Quick Start

### Option 1: Install Globally (Recommended) ⭐

Install hooks **once** for ALL repositories on your machine:

```bash
bash hooks/install-hooks-global.sh
```

This:
- Creates `~/.git-hooks/` directory
- Copies all hooks there
- Configures git globally with `core.hooksPath`
- Applies to every repository automatically
- No per-repo installation needed!

### Option 2: Install Locally (Per Repository)

Install hooks **only** for this repository:

```bash
bash hooks/install-hooks.sh
```

This copies all hooks from `hooks/` to `.git/hooks/` and makes them executable.

### 2. Install Dependencies

```bash
# YAML validation (Python included with most systems)
python3 --version

# Python linting
pip install flake8 black pylint

# SQL linting
pip install sqlfluff

# dbt validation
pip install dbt-snowflake
```

### 3. Test the Hooks

```bash
# Test all hooks
.git/hooks/pre-commit

# Make an empty commit to verify hooks run
git commit --allow-empty -m "test"
```

---

## What's Included

### 🔐 Secrets Detection (`pre-commit-secrets.sh`)

**Detects:** Passwords, API keys, credentials, tokens

**Patterns:**
- `password=`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ACCOUNT`
- `token=`, `api_key=`, `AWS_SECRET`
- Any sensitive credentials

**Blocks commit if:** Any secret patterns are found

---

### 📋 YAML Validation (`pre-commit-yaml.sh`)

**Validates:** dbt YAML files, config files

**Checks:**
- Syntax errors (missing colons, bad indentation)
- Valid YAML structure
- All `.yml` and `.yaml` files

**Blocks commit if:** YAML syntax is invalid

---

### 🐍 Python Linting (`pre-commit-python.sh`)

**Tool:** flake8

**Checks:**
- Syntax errors
- Undefined variables
- Unused imports
- Style violations (line length, naming)
- PEP 8 compliance

**Blocks commit if:** Linting fails

**Auto-fix with:**
```bash
black models/  # Auto-format
```

---

### 🔍 SQL Linting (`pre-commit-sqlfluff.sh`)

**Tool:** sqlfluff with Snowflake dialect

**Checks:**
- SQL syntax errors
- Formatting issues
- Jinja2 template validation
- Snowflake-specific rules

**Blocks commit if:** SQL linting fails

**Auto-fix with:**
```bash
sqlfluff fix models/ --dialect snowflake
```

---

### 🎯 dbt Parse Validation (`pre-commit-dbt.sh`)

**Validates:** dbt models and configuration

**Checks:**
- All `.sql` files parse correctly
- Valid `ref()` and `source()` calls
- No circular dependencies
- Valid dbt_project.yml
- Jinja2 expressions in context

**Blocks commit if:** dbt parse fails

**Note:** Requires valid `~/.dbt/profiles.yml`

---

### 📦 Large File Prevention (`pre-commit-large-files.sh`)

**Blocks:** Files >5MB with data extensions

**Extensions monitored:**
- `.csv`, `.parquet`, `.xlsx`, `.xls`
- `.pkl`, `.tar`, `.gz`, `.zip`

**Why:** dbt projects should not store raw data

**Solutions:**
```bash
# Option 1: Remove the file
git reset data.csv
rm data.csv

# Option 2: Add to .gitignore
echo "data.csv" >> .gitignore

# Option 3: Use git-lfs (if approved)
git lfs track "*.csv"
```

---

## File Structure

```
hooks/
├── pre-commit                    # Main hook (orchestrates all checks)
├── pre-commit-secrets.sh         # Secrets detection
├── pre-commit-yaml.sh            # YAML validation
├── pre-commit-python.sh          # Python linting
├── pre-commit-sqlfluff.sh        # SQL linting
├── pre-commit-dbt.sh             # dbt validation
├── pre-commit-large-files.sh     # File size check
├── install-hooks.sh              # Local installation (per-repo)
├── install-hooks-global.sh       # Global installation (all repos)
└── README.md                     # This file
```

**Installation Scripts:**
- `install-hooks.sh` — Installs to `.git/hooks/` (this repo only)
- `install-hooks-global.sh` — Installs to `~/.git-hooks/` (all repos on machine)

---

## Global vs Local Installation

### Global Installation (`install-hooks-global.sh`)

**Best for:** Multiple repositories, consistent standards across all projects

**What it does:**
1. Creates `~/.git-hooks/` directory in your home folder
2. Copies all hooks there
3. Sets `git config --global core.hooksPath ~/.git-hooks`
4. Git automatically uses these hooks in every repository

**Benefits:**
- ✅ Install once, use everywhere
- ✅ Consistent standards across all projects
- ✅ Automatic for all new repos you clone
- ✅ Easy to update in one place
- ✅ Shared by all team members on same machine

**After installation:**
```bash
# Verify global config
git config --global core.hooksPath
# Output: /home/user/.git-hooks
```

### Local Installation (`install-hooks.sh`)

**Best for:** Single repository, custom hooks, offline environments

**What it does:**
1. Copies hooks to `.git/hooks/` in this repository only
2. Only applies to this repository

**Benefits:**
- ✅ Repository-specific customization
- ✅ Hooks checked into version control
- ✅ Works in cloned repositories

---

## Configuration

### Customize Max File Size

Edit `pre-commit-large-files.sh`:

```bash
# Change this line (size in bytes)
MAX_SIZE=5242880  # 5MB, change to 10485760 for 10MB
```

### Disable Specific Hooks

Edit `.git/hooks/pre-commit` and comment out hooks you don't need:

```bash
# hooks=(
#   "pre-commit-secrets.sh"
#   # "pre-commit-yaml.sh"  # Disabled
#   "pre-commit-python.sh"
#   ...
# )
```

### Configure sqlfluff

Create `.sqlfluff` in repo root:

```ini
[sqlfluff]
dialect = snowflake
max_line_length = 100

[sqlfluff:rules]
L003 = false  # Disable indentation if too strict
L009 = false  # Disable keyword case
```

### Configure flake8

Create `.flake8` in repo root:

```ini
[flake8]
max-line-length = 100
ignore = E203, W503
exclude = .git,__pycache__,.venv
```

---

## Managing Global Hooks

### View Global Config

```bash
# Check where global hooks are installed
git config --global core.hooksPath

# Should output: /home/user/.git-hooks (or equivalent)
```

### Update Global Hooks

If you update the hooks in this repository, update the global installation:

```bash
bash hooks/install-hooks-global.sh
```

Optionally, just copy specific files:
```bash
cp hooks/pre-commit-secrets.sh ~/.git-hooks/
chmod +x ~/.git-hooks/pre-commit-secrets.sh
```

### Disable Global Hooks Temporarily

```bash
# Temporarily disable
git config --global --unset core.hooksPath

# Re-enable
git config --global core.hooksPath ~/.git-hooks
```

### Remove Global Hooks

```bash
# Remove the global hooks directory
rm -rf ~/.git-hooks

# Remove the git config
git config --global --unset core.hooksPath
```

### Use Both Global and Local Hooks

It's possible to have both:
- Global hooks in `~/.git-hooks/` (for all repos)
- Local hooks in `.git/hooks/` (for this repo only)

Git will run both. Local hooks can override global behavior.

---

## Troubleshooting

### Verify Hooks Are Installed

**For global hooks:**
```bash
# Check config
git config --global core.hooksPath

# Check directory
ls -la ~/.git-hooks/
```

**For local hooks:**
```bash
# Check this repo
ls -la .git/hooks/
```

### Hooks not running?

Check if they're executable:

**Global:**
```bash
ls -la ~/.git-hooks/
# Should show: -rwxr-xr-x (executable)
```

**Local:**
```bash
ls -la .git/hooks/
# Should show: -rwxr-xr-x (executable)
```

Make executable:

**Global:**
```bash
chmod +x ~/.git-hooks/pre-commit
chmod +x ~/.git-hooks/pre-commit-*.sh
```

**Local:**
```bash
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit-*.sh
```

### Bypass hooks (emergency only)

```bash
git commit --no-verify -m "message"
```

⚠️ Not recommended! Only use in emergencies.

### Test a specific hook

```bash
bash .git/hooks/pre-commit-secrets.sh
bash .git/hooks/pre-commit-yaml.sh
# etc.
```

### Check what files will be tested

```bash
git diff --cached --name-only
```

---

## Dependencies

| Hook | Required | Install |
|------|----------|---------|
| Secrets | - | Built-in |
| YAML | Python 3.x | `python3 --version` |
| Python | flake8 | `pip install flake8` |
| SQL | sqlfluff | `pip install sqlfluff` |
| dbt | dbt-snowflake | `pip install dbt-snowflake` |
| Large Files | - | Built-in |

All in one:
```bash
pip install flake8 black sqlfluff dbt-snowflake
```

---

## Best Practices

✅ **Do:**
- Run hooks before important commits
- Fix issues suggested by hooks
- Keep hooks enabled for quality control
- Update dependencies regularly

❌ **Don't:**
- Disable hooks permanently
- Bypass hooks with `--no-verify`
- Commit secrets or large data files
- Ignore hook error messages

---

## Integration with CI/CD

**Note:** These hooks only run locally on developer machines. They do NOT run in CI/CD pipelines.

For CI/CD pipelines, consider:

1. **Running hooks in CI** — catch issues before they're pushed
   - Use the same scripts in your CI pipeline
   - Run before allowing merges to main

2. **Enforcing branch rules** — require passing checks before merge
   - GitHub/GitLab branch protection rules
   - Require status checks to pass

3. **Pre-commit framework** — `pip install pre-commit` for easier management
   - Tracks which hook versions were used
   - Shares configuration across team

**Global hooks are for local development only.** Always enforce the same checks in CI/CD!

---

## Related Documentation

See [GIT_PRECOMMIT_HOOKS.md](../GIT_PRECOMMIT_HOOKS.md) for:
- Complete hook descriptions
- Use case explanations
- Script breakdowns
- Configuration examples

---

## Feedback & Issues

If you encounter:
- **Hooks not running** — Check executable permissions
- **False positives** — Adjust patterns in the relevant hook script
- **Performance issues** — Disable unnecessary hooks or optimize conditions
- **Missing dependencies** — Follow the installation steps above

---

Happy coding! 🚀
