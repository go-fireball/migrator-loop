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
    codex|copilot|claude) ;;
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

phase_status() {
  local phase="$1"
  awk -v phase="$phase" '
    $0 ~ "^[[:space:]]*- phase: " phase "$" {in_phase=1; next}
    in_phase && $0 ~ "^[[:space:]]*- phase:" {exit}
    in_phase && $0 ~ "^[[:space:]]*status:" {
      sub(/^[[:space:]]*status:[[:space:]]*/, "", $0)
      print $0
      exit
    }
  ' "$STATUS_FILE"
}

approval_decision() {
  local approval_file="$1"
  require_file "$approval_file"
  awk -F': *' '/^[[:space:]]*decision:[[:space:]]*/ {print $2; exit}' "$approval_file" | sed -E 's/^[[:space:]"'"'"']+|[[:space:]"'"'"']+$//g'
}

is_approval_approved() {
  local approval_file="$1"
  [[ "$(approval_decision "$approval_file")" == "approved" ]]
}

is_phase_waiting_for_approval() {
  local phase="$1"
  [[ "$(phase_status "$phase")" == "needs_human_review" ]]
}

is_phase_approved() {
  local phase="$1"
  [[ "$(phase_status "$phase")" == "approved" ]]
}

is_phase_already_executed() {
  local phase="$1"
  local status
  status="$(phase_status "$phase")"
  [[ "$status" == "needs_human_review" || "$status" == "approved" ]]
}

require_approval() {
  local approval_file="$1"
  local decision
  decision="$(approval_decision "$approval_file")"
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

set_current_phase() {
  local phase="$1"
  python3 "$UPDATE_STATUS_SCRIPT" --phase "$phase" --current-phase "$phase"
}

set_last_successful_phase() {
  local phase="$1"
  python3 "$UPDATE_STATUS_SCRIPT" --phase "$phase" --last-successful-phase "$phase"
}

mark_phase_complete() {
  local phase="$1"
  local next="$2"
  mark_phase_approved "$phase"
  set_last_successful_phase "$phase"
  set_current_phase "$next"
}

record_phase_metadata() {
  local phase="$1"
  local role="$2"
  local provider="$3"
  local prompt_path="$4"
  local handoff_path="$5"
  local result="$6"
  local execution_mode="${7:-unknown}"
  python3 "$UPDATE_STATUS_SCRIPT" \
    --phase "$phase" \
    --role "$role" \
    --provider "$provider" \
    --prompt-path "$prompt_path" \
    --handoff-path "$handoff_path" \
    --result "$result" \
    --execution-mode "$execution_mode"
}

log_stop() {
  local msg="$1"
  echo "[STOP] $msg"
  echo "Update $UNKNOWNS_FILE and request human decision."
}
