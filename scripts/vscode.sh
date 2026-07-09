#!/usr/bin/env bash
set -euo pipefail

APP_PATH="/Applications/Visual Studio Code.app"
CODE_BIN="$APP_PATH/Contents/Resources/app/bin/code"
TARGET="$HOME/.local/bin/code"

if [ ! -d "$APP_PATH" ]; then
  echo "Visual Studio Code not found, installing..."
  brew install --cask visual-studio-code
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$CODE_BIN" "$TARGET"
echo "Linked $TARGET -> $CODE_BIN"
