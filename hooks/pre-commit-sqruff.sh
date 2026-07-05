#!/usr/bin/env bash
# Pre-commit hook: SQL Linting with sqruff
# Lints SQL files with Snowflake dialect and Jinja2 support
#
# Catches:
# - SQL syntax errors
# - Formatting issues
# - Jinja2 template errors
# - Snowflake-specific violations
#
# Note: sqruff reads the dialect from a .sqruff config file in the repo
# root (it has no --dialect flag). Create one with:
#   [sqruff]
#   dialect = snowflake

set -euo pipefail

echo "🔍 Linting SQL with sqruff..."

# Get staged SQL files
sql_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.sql$' || true)

if [ -z "$sql_files" ]; then
  echo "✅ No SQL files to check"
  exit 0
fi

# Check if sqruff is installed
if ! command -v sqruff &> /dev/null; then
  echo "⚠️  sqruff not installed."
  echo "   Install with: pip install sqruff"
  echo "   Skipping SQL linting."
  exit 0
fi

# Run sqruff (dialect comes from .sqruff config file)
if ! sqruff lint $sql_files 2>/dev/null; then
  echo ""
  echo "❌ SQL linting failed."
  echo "   Auto-fix with: sqruff fix $sql_files"
  exit 1
fi

echo "✅ SQL files are valid"
exit 0
