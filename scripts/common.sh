#!/usr/bin/env bash
set -euo pipefail

PROJECT_FILE="docs/project.yaml"
STATUS_FILE="docs/status/phase-status.yaml"
UNKNOWNS_FILE="docs/unknowns/open-questions.yaml"

get_max_runs() {
  awk '/max_agent_runs_per_session:/ {print $2}' "$PROJECT_FILE"
}

get_default_assistant_provider() {
  local provider
  provider=$(awk '/default_assistant_provider:/ {print $2}' "$PROJECT_FILE" | head -n1)
  if [[ -z "${provider:-}" ]]; then
    provider="codex"
  fi
  echo "$provider"
}

validate_assistant_provider() {
  local provider="$1"
  case "$provider" in
    codex|copilot|claude)
      ;;
    *)
      echo "ERROR: unsupported assistant provider '$provider' (supported: codex, copilot, claude)" >&2
      exit 1
      ;;
  esac
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "ERROR: required file missing -> $file" >&2
    exit 1
  fi
}

require_glob_match() {
  local pattern="$1"
  if ! compgen -G "$pattern" >/dev/null; then
    echo "ERROR: required artifact pattern has no matches -> $pattern" >&2
    exit 1
  fi
}

require_nonempty_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "ERROR: required directory missing -> $dir" >&2
    exit 1
  fi
  if [[ -z "$(find "$dir" -mindepth 1 -print -quit)" ]]; then
    echo "ERROR: required directory is empty -> $dir" >&2
    exit 1
  fi
}

require_approval() {
  local approval_file="$1"
  require_file "$approval_file"
  if ! awk '/decision:/ {print $2}' "$approval_file" | grep -q '^approved$'; then
    echo "STOP: approval missing or not approved in $approval_file"
    exit 2
  fi
}

log_stop() {
  local msg="$1"
  echo "[STOP] $msg"
  echo "Update $UNKNOWNS_FILE and request human decision."
}
