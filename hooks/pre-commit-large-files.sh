#!/usr/bin/env bash
# Pre-commit hook: Large File Prevention
# Blocks commits of large binary files (CSV, Parquet, Excel, etc.)
#
# Why: dbt projects should not store raw data in git
# - Bloats repository size
# - Slows down clones and CI/CD
# - Data should live in Snowflake, not in git

set -euo pipefail

echo "📦 Checking file sizes..."

# Max size in bytes: 5MB = 5242880
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
