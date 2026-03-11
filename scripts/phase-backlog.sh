#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=3
next_phase=4
role="Planner-Architect"
role_slug="planner-architect"
template="governance/prompts/planner-architect-phase-3-backlog.md"
approval_file="docs/approvals/approval-phase-3.yaml"
handoff="handoff/planner-architect/phase-3-handoff.yaml"
outdir="handoff/planner-architect/execution"
prompt_path="handoff/${role_slug}/rendered-phase-${phase}-prompt.md"

echo "== Phase 3 Backlog Generation (${role}) =="
require_file handoff/planner-architect/phase-2-handoff.yaml

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

require_glob_match "docs/features/*.yaml"
require_glob_match "docs/stories/*.yaml"
require_glob_match "docs/tasks/*.yaml"
require_file "$handoff"

mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval" "$execution_mode"

echo "Phase ${phase} executed and is now waiting for human approval."
exit 2
