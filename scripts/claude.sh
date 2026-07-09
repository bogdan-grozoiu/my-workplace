#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_DIR/claude/CLAUDE.md"
TARGET="$HOME/.claude/CLAUDE.md"

if ! command -v claude &> /dev/null; then
  echo "Claude Code not found, installing..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

mkdir -p "$HOME/.claude"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "$TARGET.bak"
  echo "Backed up existing $TARGET to $TARGET.bak"
fi

ln -sf "$SOURCE" "$TARGET"
echo "Linked $TARGET -> $SOURCE"
