#!/usr/bin/env bash
# Pre-commit hook: Secrets Detection
# Detects and blocks commits containing credentials and API keys
#
# Patterns detected:
# - password=, token=, SNOWFLAKE_PASSWORD, SNOWFLAKE_ACCOUNT
# - AWS_SECRET, API keys, private keys
# - Sensitive environment variables

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
  if file "$file" | grep -q "binary" 2>/dev/null; then
    continue
  fi

  # Skip documentation and hook script files
  if [[ "$file" =~ \.(md|txt|rst|doc|docx|sh)$ ]]; then
    continue
  fi

  # Skip config examples and comments
  if [[ "$file" =~ (example|sample|template|\.config|\.ini|\.cfg|hooks/) ]]; then
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
