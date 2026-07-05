#!/usr/bin/env bash
# Pre-commit hook: dbt Parse Validation
# Validates dbt models parse correctly without breaking refs or sources
#
# Catches:
# - Invalid dbt_project.yml
# - Broken ref() calls
# - Invalid source() references
# - Circular dependencies
# - Jinja2 errors in models

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
