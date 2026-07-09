#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Order of execution - edit this list to change the order
SCRIPTS=(
  brew.sh
  claude.sh
  gpg.sh
  git-identity.sh
  zshrc.sh
  spotify.sh
  slack.sh
  vscode.sh
  obsidian.sh
)

for script in "${SCRIPTS[@]}"; do
  echo "Running $script"
  bash "$REPO_DIR/scripts/$script"
done