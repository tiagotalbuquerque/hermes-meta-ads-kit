#!/usr/bin/env bash

mk_is_mutation_action() {
  local action="$1"
  case "$action" in
    create*|update*|delete*|pause*|resume*|set-budget*|mutate*|force*) return 0 ;;
    *) return 1 ;;
  esac
}

mk_requires_approval() {
  local mode="$1"
  local action="$2"

  if ! mk_is_mutation_action "$action"; then
    return 1
  fi

  if [[ "${META_KIT_REQUIRE_APPROVAL:-true}" != "true" ]]; then
    return 1
  fi

  if [[ "$mode" != "live-approved" ]]; then
    echo "ERROR: mutation '$action' blocked in mode '$mode'. Set META_KIT_MODE=live-approved after explicit approval." >&2
    return 0
  fi

  if [[ -z "${META_KIT_APPROVAL_ID:-}" ]]; then
    echo "ERROR: mutation '$action' requires META_KIT_APPROVAL_ID in live-approved mode." >&2
    return 0
  fi

  return 1
}

mk_enforce_paused_only() {
  local status="$1"
  if [[ "${META_KIT_FORCE_PAUSED:-true}" != "true" ]]; then
    return 0
  fi

  if [[ -z "$status" ]]; then
    echo "PAUSED"
    return 0
  fi

  if [[ "$status" != "PAUSED" ]]; then
    echo "ERROR: create operations must use status PAUSED. Got: $status" >&2
    return 1
  fi

  echo "$status"
}

mk_write_dry_run_artifact() {
  local action="$1"
  local account="$2"
  local command_preview="$3"
  local payload_path="${4:-}"

  local dry_run_dir ts out
  dry_run_dir="$(mk_dry_run_dir)"
  mkdir -p "$dry_run_dir"
  ts="$(date -u +"%Y-%m-%dT%H%M%SZ")"
  out="${dry_run_dir}/${ts}-${action}.json"

  jq -n \
    --arg timestamp "$ts" \
    --arg account "$account" \
    --arg action "$action" \
    --arg mode "${META_KIT_MODE:-mock}" \
    --arg approval_required "${META_KIT_REQUIRE_APPROVAL:-true}" \
    --arg approval_id "${META_KIT_APPROVAL_ID:-}" \
    --arg command "$command_preview" \
    --arg payload_path "$payload_path" \
    --arg rollback_note "Manual rollback only; deletes unsupported in v1." \
    '{
      timestamp: $timestamp,
      account_id: $account,
      action: $action,
      mode: $mode,
      approval_required: $approval_required,
      approval_id: $approval_id,
      command_preview: $command,
      payload_path: $payload_path,
      expected_risk: "spend-impacting mutation",
      rollback: $rollback_note
    }' > "$out"

  printf '%s\n' "$out"
}
