#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Order of execution - edit these lists to change the order.
# CORE_SCRIPTS always run. OPTIONAL_SCRIPTS prompt y/N (default No).
CORE_SCRIPTS=(
  brew.sh
  claude.sh
  gpg.sh
  git-identity.sh
  zshrc.sh
  spotify.sh
  slack.sh
  vscode.sh
)

OPTIONAL_SCRIPTS=(
  obsidian.sh
)

run_script() {
  echo "Running $1"
  bash "$REPO_DIR/scripts/$1"
}

# Ask a y/N question (default No). Reads from /dev/tty so prompts still work
# under `curl … | bash`, where stdin is the piped script rather than the
# keyboard. With no terminal attached (fully headless), defaults to No.
confirm() {
  local reply
  if ! { : < /dev/tty; } 2>/dev/null; then
    echo "$1 [y/N] — no terminal attached, skipping."
    return 1
  fi
  printf '%s [y/N] ' "$1" > /dev/tty
  read -r reply < /dev/tty || return 1
  case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

for script in "${CORE_SCRIPTS[@]}"; do
  run_script "$script"
done

for script in "${OPTIONAL_SCRIPTS[@]}"; do
  name="${script%.sh}"
  if confirm "Install optional component: $name?"; then
    run_script "$script"
  else
    echo "Skipping optional component: $name"
  fi
done