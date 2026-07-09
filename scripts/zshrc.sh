#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_DIR/zshrc/.zshrc"
TARGET="$HOME/.zshrc"

if ! command -v zsh &> /dev/null; then
  echo "zsh not found, installing..."
  brew install zsh
fi

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "$TARGET.bak"
  echo "Backed up existing $TARGET to $TARGET.bak"
fi

ln -sf "$SOURCE" "$TARGET"
echo "Linked $TARGET -> $SOURCE"
