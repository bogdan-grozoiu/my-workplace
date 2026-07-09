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
  if [ "$1" = "$key" ]; then
    # value-less flag (e.g. enable-ssh-support): match the whole line
    grep -qxF "$1" "$AGENT_CONF" || echo "$1" >> "$AGENT_CONF"
  elif grep -q "^$key " "$AGENT_CONF"; then
    # key with a value: replace it (space anchor avoids matching key-* variants)
    sed -i '' "s|^$key .*|$1|" "$AGENT_CONF"
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

# Prints the keygrip gpg-agent has registered for the card's authentication slot (OPENPGP.3).
# Works even if the auth subkey's public key was never imported locally, since it queries the
# agent's card stub directly instead of looking the key up by fingerprint.
find_card_auth_keygrip() {
  gpg-connect-agent 'KEYINFO --list' /bye 2>/dev/null | awk '$1 == "S" && $2 == "KEYINFO" && $6 == "OPENPGP.3" { print $3; exit }'
}

add_keygrip_to_sshcontrol() {
  grep -qxF "$1" "$SSHCONTROL" || echo "$1" >> "$SSHCONTROL"
  echo "Added keygrip $1 to $SSHCONTROL"
}

if gpg --card-status &>/dev/null; then
  echo "Yubikey detected, configuring card authentication key for SSH..."
  KEYGRIP="$(find_card_auth_keygrip)"
  if [ -z "$KEYGRIP" ]; then
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
  KEYGRIP="$(find_auth_keygrip "$FINGERPRINT")"
  if [ -z "$KEYGRIP" ]; then
    echo "Could not find an authentication-capable subkey for $FINGERPRINT." >&2
    exit 1
  fi
fi

add_keygrip_to_sshcontrol "$KEYGRIP"

gpgconf --kill gpg-agent
echo "Done. Verify with: ssh-add -L"
