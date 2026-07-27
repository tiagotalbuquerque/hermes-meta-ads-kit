#!/usr/bin/env bash
# Compatibility wrapper for budget optimizer commands.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CMD="${1:-efficiency}"
shift || true

case "$CMD" in
  budget) CMD="efficiency" ;;
  optimize) CMD="recommend" ;;
esac

exec "$ROOT_DIR/scripts/meta-kit.sh" "$CMD" "$@"
