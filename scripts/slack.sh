#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "/Applications/Slack.app" ]; then
  echo "Slack not found, installing..."
  brew install --cask slack
fi
