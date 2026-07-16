#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$REPO_DIR/claude"
TARGET_DIR="$HOME/.claude"

if ! command -v claude &> /dev/null; then
  echo "Claude Code not found, installing..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

mkdir -p "$TARGET_DIR"

# Mirror the repo's claude/ directory structure into ~/.claude, recreating
# subdirectories and symlinking each file so edits in the repo take effect
# immediately. Existing real files are backed up before being replaced; other
# files already present in ~/.claude (e.g. unrelated skills) are left untouched.
while IFS= read -r -d '' src; do
  rel="${src#"$SOURCE_DIR"/}"
  dest="$TARGET_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
    echo "Backed up existing $dest to $dest.bak"
  fi
  ln -sf "$src" "$dest"
  echo "Linked $dest -> $src"
done < <(find "$SOURCE_DIR" -type f -print0)
