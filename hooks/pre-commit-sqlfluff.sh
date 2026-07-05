#!/usr/bin/env bash
# Pre-commit hook: SQL Linting with sqlfluff
# Lints SQL files with Snowflake dialect and Jinja2 support
#
# Catches:
# - SQL syntax errors
# - Formatting issues
# - Jinja2 template errors
# - Snowflake-specific violations

set -euo pipefail

echo "🔍 Linting SQL with sqlfluff..."

# Get staged SQL files
sql_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.sql$' || true)

if [ -z "$sql_files" ]; then
  echo "✅ No SQL files to check"
  exit 0
fi

# Check if sqlfluff is installed
if ! command -v sqlfluff &> /dev/null; then
  echo "⚠️  sqlfluff not installed."
  echo "   Install with: pip install sqlfluff"
  echo "   Skipping SQL linting."
  exit 0
fi

# Run sqlfluff with Snowflake dialect
if ! sqlfluff lint $sql_files --dialect snowflake 2>/dev/null; then
  echo ""
  echo "❌ SQL linting failed."
  echo "   Auto-fix with: sqlfluff fix $sql_files --dialect snowflake"
  exit 1
fi

echo "✅ SQL files are valid"
exit 0
