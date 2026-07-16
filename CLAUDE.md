# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

"Workplace as code": a macOS provisioning setup that installs apps and configures a dev
environment from scratch. It is a collection of idempotent Bash scripts — there is no
build system, package manifest, or test framework.

## Commands

- **Full setup:** `./setup.sh` — runs every core script in order, then prompts (y/N) for each optional one.
- **One-liner bootstrap:** the README's `curl … | bash` clones the repo to `~/git/github/bogdan-grozoiu/my-workplace` and runs `setup.sh`.
- **Run a single component:** `bash scripts/<name>.sh` — every script is standalone and idempotent, safe to re-run on its own.
- **Verify a script after editing:** `bash -n scripts/<name>.sh` (syntax check). There are no unit tests; validation is running the script and confirming it converges.

## Architecture

**`bootstrap.sh` → `setup.sh` → `scripts/*.sh`.** `bootstrap.sh` clones/updates the repo
and hands off to `setup.sh`. `setup.sh` holds two ordered lists — `CORE_SCRIPTS` (always
run) and `OPTIONAL_SCRIPTS` (prompted, default No) — and executes each via `bash`. To add
a component, write `scripts/<name>.sh` and add it to the appropriate list; to make one
optional, move its line between the two lists.

**Every script follows the same contract:** starts with `set -euo pipefail`, guards work
behind existence checks (`command -v <tool>` or `[ -d /Applications/<App>.app ]`) so
re-runs are no-ops, installs missing pieces via Homebrew, and prints what it did. Match
this shape when adding scripts.

**The `claude/` directory is deployed config, not repo tooling.** `scripts/claude.sh`
mirrors `claude/` into `~/.claude` by symlinking each file (backing up any pre-existing
real file to `*.bak`), so edits in the repo take effect live. This is why `claude/CLAUDE.md`,
`claude/rules/`, and `claude/skills/` exist — they are the user's global Claude Code config
under version control, unrelated to how Claude should behave *inside this repo*.

**Symlink-and-backup is the standard pattern** for config files (`claude.sh`, `zshrc.sh`,
`vscode.sh`): link the repo copy into the home location, moving any existing real file to
`.bak` first. Prefer this over copying so the repo stays the source of truth.

## Interactive prompts under `curl | bash`

`setup.sh`'s `confirm` reads from `/dev/tty`, not stdin, because under the piped bootstrap
stdin is the script itself. When no terminal is attached (fully headless), prompts default
to No/skip. Preserve this when touching prompt logic — reading from stdin would consume the
piped script.

## Secrets and local state

Machine-specific secrets stay local and gitignored: `scripts/git-identities.conf` (per-org
committer name/email; copy from `.conf.example`) and `.claude/settings.local.json`. Never
commit real identities or move these out of `.gitignore`.

- **`git-identity.sh`** generates per-org `~/.gitconfig.d/id-*.gitconfig` files plus a
  managed `includeIf` map, regenerated from scratch each run.
- **`gpg.sh`** resolves a signing/SSH-auth key in priority order: a present YubiKey
  (OpenPGP card) → an existing local GPG key → an armored key file the user points to. It
  also writes an auto-selecting pinentry wrapper (curses in a terminal, GUI otherwise).
