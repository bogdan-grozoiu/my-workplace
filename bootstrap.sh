#!/usr/bin/env bash
set -euo pipefail

ORG="bogdan-grozoiu"
REPO="waas"
REPO_URL="https://github.com/$ORG/$REPO.git"
TARGET_DIR="$HOME/git/github/$ORG/$REPO"

if [ -d "$TARGET_DIR/.git" ]; then
  git -C "$TARGET_DIR" pull --ff-only
else
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

"$TARGET_DIR/setup.sh"
