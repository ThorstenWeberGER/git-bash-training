#!/usr/bin/env bash
# Git Pre-Commit Hooks Installer
# Interactive script to install hooks globally or locally
#
# This script offers two installation modes:
# 1. GLOBAL: Install for ALL repositories on your machine (~/.git-hooks/)
# 2. LOCAL: Install for only this repository (.git/hooks/)
#
# Usage: bash hooks/install-hooks.sh

set -euo pipefail

# Get the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_SRC_DIR="$REPO_ROOT/hooks"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo ""
echo "════════════════════════════════════════════════════════"
echo -e "${BLUE}🎯 Git Pre-Commit Hooks Installer${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
echo "This script installs 6 pre-commit hooks to validate:"
echo "  🔐 Secrets (passwords, API keys)"
echo "  📋 YAML files (dbt configs)"
echo "  🐍 Python code (flake8)"
echo "  🔍 SQL files (sqruff + Snowflake)"
echo "  🎯 dbt models (parse validation)"
echo "  📦 File sizes (prevent data bloat)"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

# Ask user which mode they prefer
echo "Choose an installation mode:"
echo ""
echo -e "${GREEN}OPTION 1: GLOBAL (Recommended)${NC}"
echo "  Location: ~/.git-hooks/"
echo "  Scope: ALL repositories on this machine"
echo "  Benefits:"
echo "    ✅ Install once, use everywhere"
echo "    ✅ Automatic for all new repos"
echo "    ✅ Easy to update in one place"
echo "    ✅ Consistent standards across projects"
echo ""
echo -e "${BLUE}OPTION 2: LOCAL${NC}"
echo "  Location: .git/hooks/ (this repo only)"
echo "  Scope: Only this repository"
echo "  Benefits:"
echo "    ✅ Repository-specific customization"
echo "    ✅ Checks into version control"
echo "    ✅ Works when repo is cloned"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

# GLOBAL INSTALLATION FUNCTION
install_global() {
  echo "════════════════════════════════════════════════════════"
  echo -e "${GREEN}🌍 Installing Globally${NC}"
  echo "════════════════════════════════════════════════════════"
  echo ""

  # Global hooks directory
  GLOBAL_HOOKS_DIR="$HOME/.git-hooks"

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
    "pre-commit-sqruff.sh"
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

    if ! cp "$src" "$dst" 2>/dev/null; then
      echo "❌ Failed to copy: $hook"
      failed=$((failed + 1))
      continue
    fi

    if ! chmod +x "$dst" 2>/dev/null; then
      echo "❌ Failed to make executable: $hook"
      failed=$((failed + 1))
      continue
    fi

    echo "✅ $hook"
    installed=$((installed + 1))
  done

  echo ""

  # Configure git
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
    echo -e "${GREEN}✅ Global hooks installed successfully!${NC}"
    echo ""
    echo "📍 Location: $GLOBAL_HOOKS_DIR"
    echo ""
    echo "These hooks are now active GLOBALLY:"
    echo "  • This repository ✅"
    echo "  • All other local repositories ✅"
    echo "  • Any future repositories you clone ✅"
    echo ""
    echo "To test: cd any git repo && git commit --allow-empty -m 'test'"
    echo ""
    echo "Next steps:"
    echo "1. Install Python dependencies:"
    echo "   pip install flake8 sqruff dbt-snowflake"
    echo "2. Make a test commit to verify hooks run"
    echo ""
    exit 0
  else
    echo -e "${RED}⚠️  Some hooks failed to install${NC}"
    exit 1
  fi
}

# LOCAL INSTALLATION FUNCTION
install_local() {
  echo "════════════════════════════════════════════════════════"
  echo -e "${BLUE}📂 Installing Locally (This Repository Only)${NC}"
  echo "════════════════════════════════════════════════════════"
  echo ""

  HOOKS_DST_DIR="$REPO_ROOT/.git/hooks"

  echo "This will:"
  echo "1. Copy hooks to $HOOKS_DST_DIR"
  echo "2. Make them executable"
  echo "3. Apply ONLY to this repository"
  echo ""

  # Confirm action
  read -p "Continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
  fi

  echo ""

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
    "pre-commit-sqruff.sh"
    "pre-commit-dbt.sh"
    "pre-commit-large-files.sh"
  )

  installed=0
  failed=0

  echo "📋 Copying hooks to $HOOKS_DST_DIR..."
  for hook in "${hooks_to_install[@]}"; do
    src="$HOOKS_SRC_DIR/$hook"
    dst="$HOOKS_DST_DIR/$hook"

    if [ ! -f "$src" ]; then
      echo "⚠️  Source not found: $hook"
      failed=$((failed + 1))
      continue
    fi

    if ! cp "$src" "$dst" 2>/dev/null; then
      echo "❌ Failed to copy: $hook"
      failed=$((failed + 1))
      continue
    fi

    if ! chmod +x "$dst" 2>/dev/null; then
      echo "❌ Failed to make executable: $hook"
      failed=$((failed + 1))
      continue
    fi

    echo "✅ $hook"
    installed=$((installed + 1))
  done

  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "📊 Installation Summary"
  echo "════════════════════════════════════════════════════════"
  echo "✅ Installed: $installed hooks"
  echo "❌ Failed: $failed"
  echo ""

  if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✅ Local hooks installed successfully!${NC}"
    echo ""
    echo "📍 Location: .git/hooks/"
    echo "   (Local to this repository)"
    echo ""
    echo "These hooks are now active for this repository:"
    echo "  • When you run 'git commit' ✅"
    echo "  • When teammates clone this repo ✅"
    echo ""
    echo "To test: git commit --allow-empty -m 'test'"
    echo ""
    echo "Next steps:"
    echo "1. Install Python dependencies:"
    echo "   pip install flake8 sqruff dbt-snowflake"
    echo "2. Make a test commit to verify hooks run"
    echo ""
    exit 0
  else
    echo -e "${RED}⚠️  Some hooks failed to install${NC}"
    exit 1
  fi
}

# Get user input
while true; do
  read -p "Choose [1=Global, 2=Local, q=Quit]: " choice
  case "$choice" in
    1)
      echo ""
      install_global
      break
      ;;
    2)
      echo ""
      install_local
      break
      ;;
    q|Q)
      echo "Installation cancelled."
      exit 0
      ;;
    *)
      echo "Invalid choice. Please enter 1, 2, or q"
      ;;
  esac
done
