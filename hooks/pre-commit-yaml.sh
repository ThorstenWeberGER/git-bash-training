#!/usr/bin/env bash
# Pre-commit hook: YAML Validation
# Validates YAML syntax for dbt configuration files and other YAML files
#
# Catches:
# - Missing colons
# - Inconsistent indentation
# - Invalid list syntax
# - Unclosed quotes

set -euo pipefail

echo "📋 Validating YAML files..."

# Get staged YAML files
yaml_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yml|yaml)$' || true)

if [ -z "$yaml_files" ]; then
  echo "✅ No YAML files to check"
  exit 0
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
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
