# Git Pre-Commit Hooks for Data Engineering

A comprehensive guide to setting up pre-commit hooks for Python, SQL, dbt, YAML, and Snowflake workflows. These hooks run **before** each commit to catch errors early and prevent bad code from entering your repository.

---

## Table of Contents

1. [Top 5 Pre-Commit Hooks](#top-5-pre-commit-hooks)
2. [Use Cases](#use-cases)
3. [Hook Scripts](#hook-scripts)
4. [Recommended Linters](#recommended-linters)
5. [Installation Guide](#installation-guide)
6. [Combined Hook Example](#combined-hook-example)

---

## Top 5 Pre-Commit Hooks

### 1. Secrets Detection ⚠️ (CRITICAL)

**Purpose:** Prevent accidental commits of Snowflake credentials, API keys, passwords, and other sensitive data.

**Why it matters for your stack:**
- Data engineering teams handle Snowflake credentials constantly
- One accidental commit of a password leaks your entire data warehouse
- Secrets in git history are nearly impossible to fully remove

**What it detects:**
- `password=`, `token=`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ACCOUNT`
- AWS keys, API keys, private tokens
- `.env` files and `.secrets/` directories

**Impact:** 🛑 Blocks commit if secrets found

---

### 2. YAML Validation (dbt-focused)

**Purpose:** Catch malformed `dbt_project.yml`, `sources.yml`, `schema.yml` before they break pipelines.

**Why it matters for your stack:**
- dbt configuration lives entirely in YAML
- A single indentation error breaks the entire dbt project
- Errors only surface when dbt runs (too late!)
- Common mistakes: missing colons, inconsistent indentation, invalid refs

**What it validates:**
- YAML syntax (colons, dashes, indentation)
- Required fields in dbt_project.yml (version, profile, name)
- Valid Jinja2 expressions in YAML

**Impact:** ✋ Blocks commit if YAML syntax is invalid

---

### 3. Python Linting (flake8/pylint)

**Purpose:** Validate Python syntax and style in dbt macros, custom transformations, and utility scripts.

**Why it matters for your stack:**
- dbt uses Jinja macros (which can include Python context)
- Python syntax errors in dbt only surface at runtime
- Catches unused imports, undefined variables, style violations
- Reduces debugging time by hours

**What it catches:**
- Syntax errors (`def foo(` without closing paren)
- Unused imports and variables
- Line length violations (>79 chars)
- Naming convention issues

**Impact:** ✋ Blocks commit if linting fails (can auto-fix with black)

---

### 4. dbt Parse Validation

**Purpose:** Run `dbt parse` to validate all dbt models, configs, and Jinja expressions **in context**.

**Why it matters for your stack:**
- Only validator that understands dbt's context (refs, sources, variables, macros)
- Catches circular dependencies, invalid refs, broken model chains
- Validates Jinja syntax WITH knowledge of what `ref()` and `source()` are
- Prevents pipeline breakage before deployment

**What it validates:**
- All `.sql` models parse without errors
- `ref()` and `source()` calls reference valid objects
- No circular dependencies between models
- YAML configuration is valid and complete
- Jinja expressions are valid

**Impact:** 🛑 Blocks commit if dbt parse fails

---

### 5. Large File Prevention

**Purpose:** Prevent committing large binary files (CSV, Parquet, Excel) that bloat the repository.

**Why it matters for your stack:**
- dbt projects should never store raw data (defeats the purpose of data engineering!)
- Git repos become massive and slow with binary files
- CI/CD pipelines become slow if they clone large data
- Test data should be small, generated on-the-fly, or use fixtures

**What it blocks:**
- Files >5MB with extensions: `.csv`, `.parquet`, `.xlsx`, `.pkl`, `.tar`, `.gz`

**Impact:** 🛑 Blocks commit if large files detected

---

## Use Cases

| Hook | When It Helps | Example Scenario |
|------|---------------|------------------|
| **Secrets** | Data engineer accidentally commits `.secrets/snowflake.env` with password | Prevents data warehouse breach |
| **YAML** | Someone fat-fingers indentation in `dbt_project.yml` | Catches before CI runs and fails later |
| **Python** | Analytics engineer writes Python UDF for dbt, has syntax error | Catches `def my_udf(` without closing paren |
| **dbt Parse** | Someone renames a table but forgets to update `ref()` calls | Catches broken model dependencies |
| **Large Files** | Analyst commits 500MB CSV of test data by accident | Prevents repo bloat and slow clones |

---

## Hook Scripts

### Script 1: Secrets Detection

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit-secrets.sh
# Detects and blocks commits containing credentials and API keys

set -euo pipefail

echo "🔐 Checking for secrets..."

# Get list of staged files
files=$(git diff --cached --name-only --diff-filter=ACM | grep -vE '\.git|node_modules' || true)

if [ -z "$files" ]; then
  exit 0
fi

# Patterns that indicate secrets (case-insensitive)
secret_patterns=(
  "password\s*=\s*['\"]"
  "token\s*=\s*['\"]"
  "SNOWFLAKE_PASSWORD"
  "SNOWFLAKE_ACCOUNT"
  "SNOWFLAKE_USER"
  "AWS_SECRET"
  "AWS_ACCESS_KEY"
  "api_key\s*=\s*['\"]"
  "secret\s*=\s*['\"]"
  "private_key"
)

found_secrets=0
for file in $files; do
  # Skip binary files
  if file "$file" | grep -q "binary"; then
    continue
  fi
  
  for pattern in "${secret_patterns[@]}"; do
    if grep -iE "$pattern" "$file" > /dev/null 2>&1; then
      echo "❌ BLOCKED: Found secret pattern '$pattern' in $file"
      found_secrets=$((found_secrets + 1))
    fi
  done
done

if [ $found_secrets -gt 0 ]; then
  echo ""
  echo "⚠️  $found_secrets potential secret(s) found."
  echo "   Remove credentials before committing."
  echo "   Use .gitignore or .secrets/ directory for sensitive files."
  exit 1
fi

echo "✅ No secrets detected"
exit 0
```

**How to test it:**
```bash
echo "SNOWFLAKE_PASSWORD=my_secret_pass" > test.sql
git add test.sql
git commit -m "test"  # Will be blocked!
```

---

### Script 2: YAML Validation

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit-yaml.sh
# Validates YAML syntax for dbt configuration files

set -euo pipefail

echo "📋 Validating YAML files..."

# Get staged YAML files
yaml_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yml|yaml)$' || true)

if [ -z "$yaml_files" ]; then
  echo "✅ No YAML files to check"
  exit 0
fi

# Check if Python is available
if ! command -v python -v &> /dev/null && ! command -v python3 -v &> /dev/null; then
  echo "⚠️  Python not found. Skipping YAML validation."
  exit 0
fi

failed=0
for file in $yaml_files; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # Use Python to validate YAML syntax
  if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
    echo "❌ Invalid YAML syntax: $file"
    failed=$((failed + 1))
  fi
done

if [ $failed -gt 0 ]; then
  echo ""
  echo "⚠️  $failed YAML file(s) have syntax errors."
  echo "   Check indentation and colons."
  exit 1
fi

echo "✅ All YAML files are valid"
exit 0
```

**What it catches:**
- Missing colons: `version 1.0` (missing `:`)
- Bad indentation: `  sources:` with inconsistent spacing
- Invalid lists: Missing `-` for list items
- Unclosed quotes: `name: "table`

---

### Script 3: Python Linting (flake8)

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit-python.sh
# Lints Python code for syntax errors, unused imports, and style violations

set -euo pipefail

echo "🐍 Checking Python files..."

# Get staged Python files
py_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.py$' || true)

if [ -z "$py_files" ]; then
  echo "✅ No Python files to check"
  exit 0
fi

# Check if flake8 is installed
if ! command -v flake8 &> /dev/null; then
  echo "⚠️  flake8 not installed."
  echo "   Install with: pip install flake8"
  echo "   Skipping Python linting."
  exit 0
fi

# Run flake8 on staged files
if ! flake8 $py_files --max-line-length=100; then
  echo ""
  echo "❌ Python linting failed."
  echo "   Fix issues above or use: black $py_files"
  exit 1
fi

echo "✅ Python files passed linting"
exit 0
```

**What flake8 catches:**
- Undefined variables: `print(undefined_var)`
- Unused imports: `import os` but never used
- Syntax errors: `def foo(` without closing paren
- Style violations: Lines >79 chars, trailing whitespace
- Logic errors: `except:` (bare except), shadowed builtins

**To auto-fix with black:**
```bash
pip install black
black models/
```

---

### Script 4: dbt Parse Validation

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit-dbt.sh
# Validates dbt models parse correctly without breaking refs or sources

set -euo pipefail

echo "🎯 Validating dbt models..."

# Only run if dbt files changed
dbt_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E 'models/|dbt_project\.yml|profiles\.yml' || true)

if [ -z "$dbt_files" ]; then
  echo "✅ No dbt files to check"
  exit 0
fi

# Check if dbt is installed
if ! command -v dbt &> /dev/null; then
  echo "⚠️  dbt not installed."
  echo "   Install with: pip install dbt-snowflake"
  echo "   Skipping dbt validation."
  exit 0
fi

# Run dbt parse (validates all models without executing them)
# Adjust --profiles-dir to match your setup
echo "Running: dbt parse --profiles-dir ~/.dbt"
if ! dbt parse --profiles-dir ~/.dbt > /dev/null 2>&1; then
  echo ""
  echo "❌ dbt parse failed."
  echo "   Check dbt_project.yml and model syntax."
  echo "   Run 'dbt parse --profiles-dir ~/.dbt' for details."
  exit 1
fi

echo "✅ dbt models are valid"
exit 0
```

**What it validates:**
- All `.sql` files are valid Jinja2 templates
- All `ref()` calls reference valid models
- All `source()` calls reference valid sources
- No circular dependencies between models
- All variables and configs are defined
- dbt_project.yml is valid

**Note:** Requires a valid `profiles.yml` and dbt project setup.

---

### Script 5: Large File Prevention

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit-large-files.sh
# Blocks commits of large binary files (CSV, Parquet, etc.)

set -euo pipefail

echo "📦 Checking file sizes..."

# Max size in bytes: 5MB = 5242880, 10MB = 10485760
MAX_SIZE=5242880

# Get staged files
files=$(git diff --cached --name-only --diff-filter=ACM || true)

if [ -z "$files" ]; then
  exit 0
fi

# File extensions to monitor (data files)
large_extensions=("csv" "parquet" "xlsx" "xls" "pkl" "tar" "gz" "zip")

failed=0
for file in $files; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # Get file extension
  ext="${file##*.}"
  ext="${ext,,}"  # Convert to lowercase
  
  # Check if extension is in the monitored list
  for large_ext in "${large_extensions[@]}"; do
    if [ "$ext" = "$large_ext" ]; then
      # Get file size (works on macOS and Linux)
      if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f%z "$file" 2>/dev/null || echo 0)
      else
        size=$(stat -c%s "$file" 2>/dev/null || echo 0)
      fi
      
      if [ "$size" -gt "$MAX_SIZE" ]; then
        size_mb=$((size / 1024 / 1024))
        echo "❌ File too large: $file ($size_mb MB)"
        failed=$((failed + 1))
      fi
    fi
  done
done

if [ $failed -gt 0 ]; then
  echo ""
  echo "⚠️  $failed file(s) exceed 5MB size limit."
  echo "   Reason: dbt projects should not store raw data."
  echo "   Solutions:"
  echo "   1. Remove the file: git reset $file"
  echo "   2. Add to .gitignore: echo '$file' >> .gitignore"
  echo "   3. Use git-lfs for binary files (if approved)"
  exit 1
fi

echo "✅ All file sizes are acceptable"
exit 0
```

**Why this matters:**
- Git is not a data storage system
- Large files slow down clones, CI/CD, and development
- dbt should pull data from Snowflake, not from git

---

## Recommended Linters

### SQL Linting with sqlfluff (Snowflake-aware)

**Why sqlfluff for your stack:**
- Understands Snowflake SQL dialect
- Validates SQL **with Jinja2 interpolation**
- Can auto-fix formatting issues
- Catches common SQL errors before Snowflake

**Install:**
```bash
pip install sqlfluff sqlfluff-templater-jinja
```

**Usage:**
```bash
# Lint all SQL files with Snowflake dialect
sqlfluff lint models/ --dialect snowflake

# Auto-fix formatting
sqlfluff fix models/ --dialect snowflake

# Check specific file
sqlfluff lint models/staging/stg_customers.sql --dialect snowflake
```

**Configuration (.sqlfluff):**
```ini
[sqlfluff]
dialect = snowflake
max_line_length = 100

[sqlfluff:rules]
L003 = false  # Disable indentation rules if too strict
L009 = false  # Disable keyword case rules
```

**Example violations caught:**
```sql
-- ❌ Bad: Missing space after SELECT
SELECT*FROM table

-- ❌ Bad: Inconsistent indentation
SELECT
  col1,
    col2,
      col3
FROM table

-- ✅ Good: Proper spacing
SELECT
    col1,
    col2,
    col3
FROM table
```

**Faster alternative — sqruff:**

sqlfluff is Python-based and can be slow on large repos. [sqruff](https://github.com/quarylabs/sqruff) is a Rust reimplementation of sqlfluff that aims for rule/config compatibility, supports the Jinja2 templater, and includes a Snowflake dialect — often 10-40x faster for linting and formatting. It's a drop-in replacement worth trying if pre-commit hook speed becomes a pain point.

**Install (pick one):**
```bash
# pip (prebuilt wheel, no Rust toolchain needed)
pip install sqruff

# pipx (isolated install, recommended if you don't want it in your main env)
pipx install sqruff

# cargo (if you have Rust installed)
cargo install sqruff
```

Note: unlike sqlfluff, sqruff has **no `--dialect` CLI flag**. The dialect is set via a `.sqruff` config file in the repo root:
```ini
[sqruff]
dialect = snowflake
templater = jinja
```

```bash
# Usage (dialect comes from .sqruff)
sqruff lint models/
sqruff fix models/
```

**Pre-commit hook for sqlfluff:**
```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit-sqlfluff.sh

echo "🔍 Linting SQL with sqlfluff..."

sql_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.sql$' || true)

if [ -z "$sql_files" ]; then
  exit 0
fi

if ! command -v sqlfluff &> /dev/null; then
  echo "⚠️  sqlfluff not installed. Install with: pip install sqlfluff"
  exit 0
fi

if ! sqlfluff lint $sql_files --dialect snowflake; then
  echo ""
  echo "❌ SQL linting failed."
  echo "   Auto-fix with: sqlfluff fix $sql_files --dialect snowflake"
  exit 1
fi

echo "✅ SQL files are valid"
exit 0
```

---

### Python Linting Best Practices

**Recommended setup:**
```bash
pip install flake8 black pylint
```

**Tools explained:**

| Tool | Purpose | Example |
|------|---------|---------|
| **flake8** | Fast syntax & style checker | Catches undefined vars, unused imports |
| **black** | Auto-formatter | Fixes indentation, spacing, line length |
| **pylint** | Deep code analysis | Catches logic errors, complexity issues |

**Pre-commit flow:**
1. `black` auto-formats (--write flag)
2. `flake8` checks for remaining issues (if any)
3. If both pass, commit is allowed

**Configuration (.flake8):**
```ini
[flake8]
max-line-length = 100
ignore = E203, W503
exclude = .git,__pycache__,.venv
```

**Black configuration (pyproject.toml):**
```toml
[tool.black]
line-length = 100
target-version = ['py39']
```

---

## Installation Guide

### Step 1: Prepare Your Git Hooks Directory

```bash
# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Make hooks executable
chmod +x .git/hooks/*
```

### Step 2: Create Individual Hook Scripts

Save each script above as a separate file in `.git/hooks/`:
- `.git/hooks/pre-commit-secrets.sh`
- `.git/hooks/pre-commit-yaml.sh`
- `.git/hooks/pre-commit-python.sh`
- `.git/hooks/pre-commit-dbt.sh`
- `.git/hooks/pre-commit-large-files.sh`

Make them executable:
```bash
chmod +x .git/hooks/pre-commit-*.sh
```

### Step 3: Create Main Pre-Commit Hook

Create `.git/hooks/pre-commit` (main entry point):

```bash
#!/usr/bin/env bash
set -euo pipefail

# Main pre-commit hook that calls all validation scripts

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Array of hook scripts to run (in order)
hooks=(
  "pre-commit-secrets.sh"
  "pre-commit-yaml.sh"
  "pre-commit-python.sh"
  "pre-commit-sqlfluff.sh"
  "pre-commit-dbt.sh"
  "pre-commit-large-files.sh"
)

echo "🔍 Running pre-commit hooks..."
echo ""

failed_hooks=()

for hook in "${hooks[@]}"; do
  hook_path="$HOOKS_DIR/$hook"
  
  if [ -f "$hook_path" ]; then
    if ! "$hook_path"; then
      failed_hooks+=("$hook")
    fi
  fi
  echo ""
done

if [ ${#failed_hooks[@]} -gt 0 ]; then
  echo "❌ Pre-commit validation failed:"
  for hook in "${failed_hooks[@]}"; do
    echo "   - $hook"
  done
  exit 1
fi

echo "✅ All pre-commit checks passed! Proceeding with commit."
exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Step 4: Install Dependencies

```bash
# For YAML validation (Python included with most systems)
python3 --version  # Should output Python 3.x.x

# For Python linting
pip install flake8 black pylint

# For SQL linting
pip install sqlfluff sqlfluff-templater-jinja

# For dbt validation
pip install dbt-snowflake

# Optional: For easier hook management
pip install pre-commit
```

### Step 5: Test the Hooks

Test each hook manually:
```bash
# Test secrets detection
.git/hooks/pre-commit-secrets.sh

# Test YAML validation
.git/hooks/pre-commit-yaml.sh

# Test Python linting
.git/hooks/pre-commit-python.sh

# Test dbt validation
.git/hooks/pre-commit-dbt.sh

# Test large file check
.git/hooks/pre-commit-large-files.sh

# Run all hooks
.git/hooks/pre-commit
```

---

## Combined Hook Example

Here's a complete, ready-to-use `.git/hooks/pre-commit` that combines all validations:

```bash
#!/usr/bin/env bash
# Complete pre-commit hook for dbt + Python + SQL projects
# Place this at: .git/hooks/pre-commit
# Make executable: chmod +x .git/hooks/pre-commit

set -euo pipefail

echo "════════════════════════════════════════════════════════"
echo "🔍 Running Pre-Commit Validation"
echo "════════════════════════════════════════════════════════"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

failed=0

# ============================================================
# 1. SECRETS DETECTION
# ============================================================
echo "1️⃣  Checking for secrets..."
files=$(git diff --cached --name-only --diff-filter=ACM | grep -vE '\.git|node_modules' || true)

if [ ! -z "$files" ]; then
  secret_patterns=(
    "password\s*=\s*['\"]"
    "SNOWFLAKE_PASSWORD"
    "SNOWFLAKE_ACCOUNT"
    "AWS_SECRET"
    "token\s*=\s*['\"]"
    "api_key"
  )
  
  found_secrets=0
  for file in $files; do
    for pattern in "${secret_patterns[@]}"; do
      if grep -iE "$pattern" "$file" 2>/dev/null | grep -v ".gitignore" > /dev/null; then
        echo "   ❌ Found secret pattern in: $file"
        found_secrets=$((found_secrets + 1))
      fi
    done
  done
  
  if [ $found_secrets -gt 0 ]; then
    failed=$((failed + 1))
  else
    echo "   ✅ No secrets detected"
  fi
else
  echo "   ✅ No files to check"
fi
echo ""

# ============================================================
# 2. YAML VALIDATION
# ============================================================
echo "2️⃣  Validating YAML files..."
yaml_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yml|yaml)$' || true)

if [ ! -z "$yaml_files" ]; then
  yaml_failed=0
  for file in $yaml_files; do
    if [ -f "$file" ]; then
      if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        echo "   ❌ Invalid YAML: $file"
        yaml_failed=$((yaml_failed + 1))
      fi
    fi
  done
  
  if [ $yaml_failed -gt 0 ]; then
    failed=$((failed + 1))
  else
    echo "   ✅ All YAML files valid"
  fi
else
  echo "   ✅ No YAML files to check"
fi
echo ""

# ============================================================
# 3. PYTHON LINTING (flake8)
# ============================================================
echo "3️⃣  Checking Python files..."
py_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.py$' || true)

if [ ! -z "$py_files" ]; then
  if command -v flake8 &> /dev/null; then
    if ! flake8 $py_files --max-line-length=100 2>/dev/null; then
      failed=$((failed + 1))
    else
      echo "   ✅ Python files passed linting"
    fi
  else
    echo "   ⚠️  flake8 not installed (skipping)"
  fi
else
  echo "   ✅ No Python files to check"
fi
echo ""

# ============================================================
# 4. SQL LINTING (sqlfluff)
# ============================================================
echo "4️⃣  Linting SQL files..."
sql_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.sql$' || true)

if [ ! -z "$sql_files" ]; then
  if command -v sqlfluff &> /dev/null; then
    if ! sqlfluff lint $sql_files --dialect snowflake 2>/dev/null; then
      failed=$((failed + 1))
    else
      echo "   ✅ SQL files passed linting"
    fi
  else
    echo "   ⚠️  sqlfluff not installed (skipping)"
  fi
else
  echo "   ✅ No SQL files to check"
fi
echo ""

# ============================================================
# 5. dbt PARSE VALIDATION
# ============================================================
echo "5️⃣  Validating dbt models..."
dbt_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E 'models/|dbt_project\.yml' || true)

if [ ! -z "$dbt_files" ]; then
  if command -v dbt &> /dev/null; then
    if ! dbt parse --profiles-dir ~/.dbt > /dev/null 2>&1; then
      echo "   ❌ dbt parse failed"
      failed=$((failed + 1))
    else
      echo "   ✅ dbt models are valid"
    fi
  else
    echo "   ⚠️  dbt not installed (skipping)"
  fi
else
  echo "   ✅ No dbt files to check"
fi
echo ""

# ============================================================
# 6. LARGE FILE PREVENTION
# ============================================================
echo "6️⃣  Checking file sizes..."
files=$(git diff --cached --name-only --diff-filter=ACM || true)
MAX_SIZE=5242880

if [ ! -z "$files" ]; then
  large_extensions=("csv" "parquet" "xlsx" "xls" "pkl")
  large_failed=0
  
  for file in $files; do
    if [ -f "$file" ]; then
      ext="${file##*.}"
      ext="${ext,,}"
      
      for large_ext in "${large_extensions[@]}"; do
        if [ "$ext" = "$large_ext" ]; then
          size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
          if [ "$size" -gt "$MAX_SIZE" ]; then
            size_mb=$((size / 1024 / 1024))
            echo "   ❌ File too large: $file ($size_mb MB)"
            large_failed=$((large_failed + 1))
          fi
        fi
      done
    fi
  done
  
  if [ $large_failed -gt 0 ]; then
    failed=$((failed + 1))
  else
    echo "   ✅ File sizes OK"
  fi
else
  echo "   ✅ No files to check"
fi
echo ""

# ============================================================
# FINAL RESULT
# ============================================================
echo "════════════════════════════════════════════════════════"

if [ $failed -eq 0 ]; then
  echo -e "${GREEN}✅ All pre-commit checks passed!${NC}"
  echo "════════════════════════════════════════════════════════"
  exit 0
else
  echo -e "${RED}❌ Pre-commit validation failed ($failed check(s) failed)${NC}"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "Fix the issues above and try again:"
  echo "  git add <fixed-files>"
  echo "  git commit <message>"
  exit 1
fi
```

---

## Troubleshooting

### Hook not running?
```bash
# Check if hook is executable
ls -la .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit

# Test it manually
.git/hooks/pre-commit
```

### Bypass hooks (only when necessary)
```bash
# Skip all hooks
git commit --no-verify -m "message"

# Not recommended! Only for emergencies.
```

### Update hook after creation
```bash
# Edit the hook
nano .git/hooks/pre-commit

# Make sure it's executable
chmod +x .git/hooks/pre-commit

# Test it
.git/hooks/pre-commit
```

---

## Summary: Our Recommendations

| Check | Priority | Tool | Install |
|-------|----------|------|---------|
| **Secrets** | 🔴 Critical | bash grep | Built-in |
| **YAML** | 🟠 High | Python yaml | `pip install pyyaml` |
| **Python** | 🟡 Medium | flake8 | `pip install flake8` |
| **SQL** | 🟡 Medium | sqlfluff | `pip install sqlfluff` |
| **dbt Parse** | 🟢 Optional | dbt | `pip install dbt-snowflake` |

**Start with:** Secrets + YAML + dbt Parse (most important for dbt projects)

**Then add:** Python linting + sqlfluff (as you scale)

---

## Quick Start

1. Copy the combined hook script above to `.git/hooks/pre-commit`
2. Make it executable: `chmod +x .git/hooks/pre-commit`
3. Install dependencies: `pip install flake8 sqlfluff dbt-snowflake pyyaml`
4. Test: `.git/hooks/pre-commit`
5. Make a commit: `git commit -m "test"`

Hooks will run automatically before each commit! 🚀
