#!/usr/bin/env bash
# Pre-commit hook: Python Linting
# Validates Python syntax and style using flake8
#
# Catches:
# - Syntax errors (undefined variables, bad indentation)
# - Unused imports and variables
# - Style violations (line length, naming conventions)

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
