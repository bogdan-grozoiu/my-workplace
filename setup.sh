#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Order of execution - edit this list to change the order
SCRIPTS=(
  brew.sh
  claude.sh
  gpg.sh
  zshrc.sh
  spotify.sh
)

for script in "${SCRIPTS[@]}"; do
  echo "Running $script"
  bash "$REPO_DIR/scripts/$script"
done