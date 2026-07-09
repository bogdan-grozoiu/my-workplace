#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "/Applications/Obsidian.app" ]; then
  echo "Obsidian not found, installing..."
  brew install --cask obsidian
fi
