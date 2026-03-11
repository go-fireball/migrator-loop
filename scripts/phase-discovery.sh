#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=1
next_phase=2
role="Analyst"
role_slug="analyst"
template="governance/prompts/analyst-phase-1-discovery.md"
approval_file="docs/approvals/approval-phase-1.yaml"
handoff="handoff/analyst/phase-1-handoff.yaml"
outdir="handoff/analyst/execution"
prompt_path="handoff/${role_slug}/rendered-phase-${phase}-prompt.md"

echo "== Phase 1 Discovery (${role}) =="
require_file handoff/analyst/phase-0-handoff.yaml

if is_phase_approved "$phase"; then
  set_last_successful_phase "$phase"
  set_current_phase "$next_phase"
  echo "Phase ${phase} already approved."
  exit 0
fi

if is_phase_waiting_for_approval "$phase"; then
  if is_approval_approved "$approval_file"; then
    mark_phase_complete "$phase" "$next_phase"
    record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success" "resume_no_execution"
    echo "Phase ${phase} approved."
    exit 0
  fi
  echo "Phase ${phase} is waiting for human approval."
  exit 2
fi

prompt_path="$($DIR/render-prompt.sh "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"
execution_mode="$(cat "$outdir/phase-${phase}-execution-mode.txt" 2>/dev/null || echo unknown)"

require_file docs/current-state/system-inventory.yaml
require_file docs/current-state/workflow-map.yaml
require_glob_match "docs/parity/*.yaml"
require_file "$handoff"

mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval" "$execution_mode"

echo "Phase ${phase} executed and is now waiting for human approval."
exit 2
