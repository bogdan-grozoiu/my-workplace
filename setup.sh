#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Order of execution - edit this list to change the order
SCRIPTS=(
  claude.sh
  zshrc.sh
)

for script in "${SCRIPTS[@]}"; do
  echo "Running $script"
  bash "$REPO_DIR/scripts/$script"
done