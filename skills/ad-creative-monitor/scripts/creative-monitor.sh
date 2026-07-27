#!/usr/bin/env bash
# Compatibility wrapper for creative-health commands.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CMD="${1:-fatigue-check}"
shift || true

case "$CMD" in
  fatigue|fatigue-check|weekly|weekly-report)
    exec "$ROOT_DIR/scripts/meta-kit.sh" fatigue "$@"
    ;;
  track-ad|track)
    echo "track-ad is not implemented in the official CLI adapter yet; use ./run.sh fatigue for account-level fatigue." >&2
    exit 2
    ;;
  *)
    exec "$ROOT_DIR/scripts/meta-kit.sh" "$CMD" "$@"
    ;;
esac
