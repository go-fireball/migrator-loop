#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=2
next_phase=3
role="Planner-Architect"
role_slug="planner-architect"
template="governance/prompts/planner-architect-phase-2-strategy.md"
approval_file="docs/approvals/approval-phase-2.yaml"
handoff="handoff/planner-architect/phase-2-handoff.yaml"
outdir="handoff/planner-architect/execution"
prompt_path="handoff/${role_slug}/rendered-phase-${phase}-prompt.md"

echo "== Phase 2 Strategy (${role}) =="
require_file handoff/analyst/phase-1-handoff.yaml

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

require_file docs/strategy/migration-strategy.yaml
require_glob_match "docs/adr/ADR-*.md"
require_file "$handoff"

if grep -Eq '^[[:space:]]*status:[[:space:]]*needs_human_review([[:space:]]|$)' docs/unknowns/open-questions.yaml; then
  log_stop "Open human-review questions detected."
  mark_phase_needs_human_review "$phase"
  record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "error" "$execution_mode"
  exit 4
fi

mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval" "$execution_mode"

echo "Phase ${phase} executed and is now waiting for human approval."
exit 2
