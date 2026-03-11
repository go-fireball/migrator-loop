#!/usr/bin/env bash
set -euo pipefail

PROJECT_FILE="docs/project.yaml"
STATUS_FILE="docs/status/phase-status.yaml"
UNKNOWNS_FILE="docs/unknowns/open-questions.yaml"
UPDATE_STATUS_SCRIPT="scripts/update-status.py"

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

get_current_phase() {
  awk -F': *' '/^current_phase:/ {print $2; exit}' "$STATUS_FILE"
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
  local decision
  require_file "$approval_file"
  decision="$(awk -F': *' '/^[[:space:]]*decision:[[:space:]]*/ {print $2; exit}' "$approval_file" | sed -E 's/^[[:space:]"'"'"']+|[[:space:]"'"'"']+$//g')"
  if [[ "$decision" != "approved" ]]; then
    echo "STOP: approval missing or not approved in $approval_file (decision: ${decision:-<missing>}; expected: approved)"
    exit 2
  fi
}

set_phase_status() {
  local phase="$1"
  local status="$2"
  python3 "$UPDATE_STATUS_SCRIPT" --phase "$phase" --status "$status"
}

mark_phase_needs_human_review() {
  local phase="$1"
  set_phase_status "$phase" "needs_human_review"
}

mark_phase_approved() {
  local phase="$1"
  set_phase_status "$phase" "approved"
}

record_phase_metadata() {
  local phase="$1"
  local role="$2"
  local provider="$3"
  local prompt_path="$4"
  local handoff_path="$5"
  local result="$6"
  python3 "$UPDATE_STATUS_SCRIPT" --phase "$phase" --role "$role" --provider "$provider" --prompt-path "$prompt_path" --handoff-path "$handoff_path" --result "$result"
}

advance_current_phase() {
  local phase="$1"
  python3 "$UPDATE_STATUS_SCRIPT" --phase "$phase" --current-phase "$phase"
}

log_stop() {
  local msg="$1"
  echo "[STOP] $msg"
  echo "Update $UNKNOWNS_FILE and request human decision."
}
