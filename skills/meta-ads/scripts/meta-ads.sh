#!/usr/bin/env bash
# Compatibility wrapper for the official Meta Ads CLI adapter.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

exec "$ROOT_DIR/scripts/meta-kit.sh" "${@:-daily-check}"
