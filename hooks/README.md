# Git Pre-Commit Hooks

Complete collection of pre-commit hooks for Python, SQL, dbt, YAML, and Snowflake workflows.

## Quick Start

### 1. Install Hooks

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
├── pre-commit              # Main hook (orchestrates all checks)
├── pre-commit-secrets.sh   # Secrets detection
├── pre-commit-yaml.sh      # YAML validation
├── pre-commit-python.sh    # Python linting
├── pre-commit-sqlfluff.sh  # SQL linting
├── pre-commit-dbt.sh       # dbt validation
├── pre-commit-large-files.sh  # File size check
├── install-hooks.sh        # Installation script
└── README.md              # This file
```

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

## Troubleshooting

### Hooks not running?

Check if they're executable:
```bash
ls -la .git/hooks/
```

Make executable:
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

These hooks run locally before commit. For CI/CD pipelines, consider:

1. **Running hooks in CI** — catch issues before they're pushed
2. **Enforcing branch rules** — require passing checks before merge
3. **Pre-commit framework** — `pip install pre-commit` for easier management

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
