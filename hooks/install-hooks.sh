#!/usr/bin/env bash
# Install Git Pre-Commit Hooks
# This script copies the hook scripts from the repo to .git/hooks/
# and makes them executable
#
# Usage: bash hooks/install-hooks.sh

set -euo pipefail

# Get the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_SRC_DIR="$REPO_ROOT/hooks"
HOOKS_DST_DIR="$REPO_ROOT/.git/hooks"

echo "📦 Installing Git Pre-Commit Hooks"
echo ""
echo "Source: $HOOKS_SRC_DIR"
echo "Destination: $HOOKS_DST_DIR"
echo ""

# Check if hooks directory exists in repo
if [ ! -d "$HOOKS_SRC_DIR" ]; then
  echo "❌ Error: hooks directory not found at $HOOKS_SRC_DIR"
  exit 1
fi

# Check if .git directory exists
if [ ! -d "$HOOKS_DST_DIR" ]; then
  echo "❌ Error: .git/hooks directory not found"
  echo "   Are you in a git repository?"
  exit 1
fi

# Hook scripts to install
hooks_to_install=(
  "pre-commit"
  "pre-commit-secrets.sh"
  "pre-commit-yaml.sh"
  "pre-commit-python.sh"
  "pre-commit-sqlfluff.sh"
  "pre-commit-dbt.sh"
  "pre-commit-large-files.sh"
)

installed=0
failed=0

for hook in "${hooks_to_install[@]}"; do
  src="$HOOKS_SRC_DIR/$hook"
  dst="$HOOKS_DST_DIR/$hook"

  if [ ! -f "$src" ]; then
    echo "⚠️  Source not found: $hook"
    failed=$((failed + 1))
    continue
  fi

  # Copy the hook
  cp "$src" "$dst" 2>/dev/null || {
    echo "❌ Failed to copy: $hook"
    failed=$((failed + 1))
    continue
  }

  # Make it executable
  chmod +x "$dst" 2>/dev/null || {
    echo "❌ Failed to make executable: $hook"
    failed=$((failed + 1))
    continue
  }

  echo "✅ Installed: $hook"
  installed=$((installed + 1))
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "📊 Installation Summary"
echo "════════════════════════════════════════════════════════"
echo "✅ Installed: $installed"
echo "❌ Failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
  echo "✅ All hooks installed successfully!"
  echo ""
  echo "The following hooks are now active:"
  echo "  • Secrets Detection"
  echo "  • YAML Validation"
  echo "  • Python Linting (flake8)"
  echo "  • SQL Linting (sqlfluff)"
  echo "  • dbt Parse Validation"
  echo "  • Large File Prevention"
  echo ""
  echo "They will run automatically on 'git commit'"
  echo ""
  echo "To test: git commit --allow-empty -m 'test'"
  exit 0
else
  echo "⚠️  Some hooks failed to install"
  exit 1
fi
