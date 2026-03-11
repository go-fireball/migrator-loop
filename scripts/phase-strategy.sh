#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=2
role="Planner-Architect"
role_slug="planner-architect"
template="governance/prompts/planner-architect-phase-2-strategy.md"
handoff="handoff/planner-architect/phase-2-handoff.yaml"
outdir="handoff/planner-architect/execution"

echo "== Phase 2 Strategy (${role}) =="
require_file handoff/analyst/phase-1-handoff.yaml
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_file docs/strategy/migration-strategy.yaml
require_glob_match "docs/adr/ADR-*.md"
require_file "$handoff"

if grep -Eq '^[[:space:]]*status:[[:space:]]*needs_human_review([[:space:]]|$)' docs/unknowns/open-questions.yaml; then
  log_stop "Open human-review questions detected."
  mark_phase_needs_human_review "$phase"
  record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "error"
  exit 4
fi

mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"
require_approval docs/approvals/approval-phase-2.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"

echo "Phase 2 approved."
