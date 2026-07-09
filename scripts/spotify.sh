#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "/Applications/Spotify.app" ]; then
  echo "Spotify not found, installing..."
  brew install --cask spotify
fi
