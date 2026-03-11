#!/usr/bin/env bash
set -euo pipefail

allow_mock_fallback() {
  local flag="${ALLOW_MOCK_FALLBACK:-true}"
  [[ "$flag" == "true" ]]
}

write_mode() {
  local output_dir="$1"
  local phase="$2"
  local mode="$3"
  echo "$mode" > "$output_dir/phase-${phase}-execution-mode.txt"
}

run_with_fallback() {
  local provider="$1"; shift
  local role="$1"; shift
  local phase="$1"; shift
  local prompt_file="$1"; shift
  local output_dir="$1"; shift
  local transcript="$1"; shift
  local mock_script="$1"; shift
  local -a cmd=("$@")

  if command -v "${cmd[0]}" >/dev/null 2>&1; then
    echo "attempting real provider execution: ${cmd[*]}" >> "$transcript"
    if "${cmd[@]}" >> "$transcript" 2>&1; then
      echo "provider execution mode: real" >> "$transcript"
      write_mode "$output_dir" "$phase" "real"
      return 0
    fi
    rc=$?
    echo "real provider command failed with exit code $rc" >> "$transcript"
  else
    rc=127
    echo "provider CLI unavailable: ${cmd[0]}" >> "$transcript"
  fi

  if allow_mock_fallback; then
    echo "provider execution mode: mock_fallback" >> "$transcript"
    "$mock_script" "$provider" "$role" "$phase" "$prompt_file" "$output_dir" >> "$transcript" 2>&1
    write_mode "$output_dir" "$phase" "mock_fallback"
    return 0
  fi

  echo "mock fallback disabled (ALLOW_MOCK_FALLBACK=false); failing." >> "$transcript"
  write_mode "$output_dir" "$phase" "real_failed"
  return "$rc"
}
