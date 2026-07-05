#!/usr/bin/env bash
# Install Git Pre-Commit Hooks Globally
# Sets up hooks that apply to ALL repositories on this machine
#
# How it works:
# 1. Creates ~/.git-hooks/ directory
# 2. Copies all hook scripts there
# 3. Configures git globally to use these hooks
#
# After installation, ALL git repos will use these hooks automatically
# No per-repo installation needed!
#
# Usage: bash hooks/install-hooks-global.sh

set -euo pipefail

# Get the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_SRC_DIR="$REPO_ROOT/hooks"

# Global hooks directory (in user's home)
GLOBAL_HOOKS_DIR="$HOME/.git-hooks"

echo ""
echo "════════════════════════════════════════════════════════"
echo "🌍 Installing Git Hooks Globally"
echo "════════════════════════════════════════════════════════"
echo ""
echo "This will:"
echo "1. Create $GLOBAL_HOOKS_DIR"
echo "2. Copy all hooks there"
echo "3. Configure git to use them globally"
echo "4. Apply to ALL repositories on this machine"
echo ""

# Confirm action
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Installation cancelled."
  exit 0
fi

echo ""

# Create global hooks directory
if [ ! -d "$GLOBAL_HOOKS_DIR" ]; then
  echo "📁 Creating $GLOBAL_HOOKS_DIR..."
  mkdir -p "$GLOBAL_HOOKS_DIR"
  echo "✅ Created"
else
  echo "✅ Directory already exists: $GLOBAL_HOOKS_DIR"
fi

echo ""

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

echo "📋 Copying hooks..."
for hook in "${hooks_to_install[@]}"; do
  src="$HOOKS_SRC_DIR/$hook"
  dst="$GLOBAL_HOOKS_DIR/$hook"

  if [ ! -f "$src" ]; then
    echo "⚠️  Source not found: $hook"
    failed=$((failed + 1))
    continue
  fi

  # Copy the hook
  if ! cp "$src" "$dst" 2>/dev/null; then
    echo "❌ Failed to copy: $hook"
    failed=$((failed + 1))
    continue
  fi

  # Make it executable
  if ! chmod +x "$dst" 2>/dev/null; then
    echo "❌ Failed to make executable: $hook"
    failed=$((failed + 1))
    continue
  fi

  echo "✅ $hook"
  installed=$((installed + 1))
done

echo ""

# Configure git to use the global hooks directory
echo "🔧 Configuring git to use global hooks..."
if git config --global core.hooksPath "$GLOBAL_HOOKS_DIR"; then
  echo "✅ Git configured: core.hooksPath = $GLOBAL_HOOKS_DIR"
else
  echo "❌ Failed to configure git"
  failed=$((failed + 1))
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "📊 Installation Summary"
echo "════════════════════════════════════════════════════════"
echo "✅ Installed: $installed hooks"
echo "❌ Failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
  echo "✅ Global hooks installed successfully!"
  echo ""
  echo "📍 Location: $GLOBAL_HOOKS_DIR"
  echo ""
  echo "The following hooks are now active GLOBALLY:"
  echo "  • Secrets Detection"
  echo "  • YAML Validation"
  echo "  • Python Linting (flake8)"
  echo "  • SQL Linting (sqlfluff)"
  echo "  • dbt Parse Validation"
  echo "  • Large File Prevention"
  echo ""
  echo "These hooks will run in:"
  echo "  • This repository ✅"
  echo "  • All other local repositories ✅"
  echo "  • Any future repositories you clone ✅"
  echo ""
  echo "Configuration saved in: ~/.gitconfig"
  echo "To view: git config --global core.hooksPath"
  echo ""
  echo "To test in a repo: git commit --allow-empty -m 'test'"
  echo ""
  exit 0
else
  echo "⚠️  Some hooks failed to install"
  exit 1
fi
