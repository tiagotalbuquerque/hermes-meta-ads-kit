#!/usr/bin/env bash

mk_fixture_file() {
  local name="$1"
  printf '%s\n' "${META_KIT_ROOT_DIR}/scripts/fixtures/${name}"
}

mk_fixture_json() {
  local name="$1"
  local file
  file="$(mk_fixture_file "$name")"

  if [[ ! -f "$file" ]]; then
    echo "ERROR: missing mock fixture: $file" >&2
    return 1
  fi

  cat "$file"
}
