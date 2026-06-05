#!/usr/bin/env bash
# Install this repository's multi-skill pack into the active Hermes profile.
# Safe by default: refuses to overwrite existing skill directories unless --force is passed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HERMES_HOME_DIR="${HERMES_HOME:-$HOME/.hermes}"
CATEGORY="${HERMES_SKILL_CATEGORY:-marketing}"
DEST="$HERMES_HOME_DIR/skills/$CATEGORY"
FORCE=0

usage() {
  cat <<'USAGE'
Usage: scripts/install-hermes-skills.sh [--force] [--category marketing]

Copies all skills/*/SKILL.md directories from this repository into:
  ${HERMES_HOME:-~/.hermes}/skills/<category>/

Options:
  --force              Overwrite existing destination skill directories
  --category NAME      Destination Hermes skill category (default: marketing)
  -h, --help           Show this help

After installing, start a new Hermes session or run /reset so the skill list refreshes.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --category) CATEGORY="${2:?missing category}"; DEST="$HERMES_HOME_DIR/skills/$CATEGORY"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

mkdir -p "$DEST"

installed=0
skipped=0
for skill_dir in "$REPO_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue
  name="$(basename "$skill_dir")"
  target="$DEST/$name"

  if [ -e "$target" ] && [ "$FORCE" -ne 1 ]; then
    echo "SKIP $name -> $target already exists (use --force to replace)"
    skipped=$((skipped + 1))
    continue
  fi

  if [ -e "$target" ]; then
    rm -rf "$target"
  fi
  cp -a "$skill_dir" "$target"
  echo "OK   $name -> $target"
  installed=$((installed + 1))
done

cat <<EOF

Installed: $installed
Skipped:   $skipped
Category:  $CATEGORY

Next steps:
  hermes skills list
  hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer

If Hermes was already running, use /reset or start a new session to refresh available skills.
EOF
