#!/usr/bin/env bash
set -euo pipefail

GNUPGHOME="$HOME/.gnupg"
AGENT_CONF="$GNUPGHOME/gpg-agent.conf"
SSHCONTROL="$GNUPGHOME/sshcontrol"

if ! command -v gpg &> /dev/null; then
  echo "GnuPG not found, installing..."
  brew install gnupg
fi

if ! command -v pinentry-mac &> /dev/null; then
  echo "pinentry-mac not found, installing..."
  brew install pinentry-mac
fi

if ! command -v ykpersonalize &> /dev/null; then
  echo "yubikey-personalization not found, installing..."
  brew install yubikey-personalization
fi

if ! command -v ykman &> /dev/null; then
  echo "ykman not found, installing..."
  brew install ykman
fi

if ! command -v wget &> /dev/null; then
  echo "wget not found, installing..."
  brew install wget
fi

mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"
touch "$AGENT_CONF" "$SSHCONTROL"

add_conf_line() {
  local key="${1%% *}"
  if grep -q "^$key " "$AGENT_CONF"; then
    sed -i '' "s|^$key .*|$1|" "$AGENT_CONF"   # note the space after $key
  else
    echo "$1" >> "$AGENT_CONF"
  fi
}

add_conf_line "enable-ssh-support"
add_conf_line "pinentry-program $(brew --prefix pinentry-mac)/bin/pinentry-mac"
add_conf_line "default-cache-ttl 60"
add_conf_line "max-cache-ttl 120"

# Given a key fingerprint, prints the keygrip of its first authentication-capable subkey.
find_auth_keygrip() {
  gpg -K --with-keygrip --with-colons "$1" | awk -F: '
    $1 == "ssb" && $12 ~ /[aA]/ { want=1; next }
    want && $1 == "grp" { print $10; exit }
  '
}

add_keygrip_to_sshcontrol() {
  grep -qxF "$1" "$SSHCONTROL" || echo "$1" >> "$SSHCONTROL"
  echo "Added keygrip $1 to $SSHCONTROL"
}

if CARD_STATUS="$(gpg --card-status 2>/dev/null)"; then
  echo "Yubikey detected, configuring card authentication key for SSH..."
  FINGERPRINT="$(echo "$CARD_STATUS" | awk -F': ' '/^Authentication key/ {gsub(/ /,"",$2); print $2}')"
  if [ -z "$FINGERPRINT" ]; then
    echo "No authentication key found on the card." >&2
    exit 1
  fi
else
  KEY_FILE="${1:-}"
  if [ -z "$KEY_FILE" ]; then
    echo "No Yubikey detected. Pass the path to an armored private key file to import:" >&2
    echo "  $0 /path/to/private-key.asc" >&2
    exit 1
  fi
  echo "Importing private key from $KEY_FILE..."
  gpg --import "$KEY_FILE"
  FINGERPRINT="$(gpg --show-keys --with-colons "$KEY_FILE" | awk -F: '$1 == "fpr" {print $10; exit}')"
fi

KEYGRIP="$(find_auth_keygrip "$FINGERPRINT")"
if [ -z "$KEYGRIP" ]; then
  echo "Could not find an authentication-capable subkey for $FINGERPRINT." >&2
  exit 1
fi
add_keygrip_to_sshcontrol "$KEYGRIP"

gpgconf --kill gpg-agent
echo "Done. Verify with: ssh-add -L"
