#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=3
role="Planner-Architect"
role_slug="planner-architect"
template="governance/prompts/planner-architect-phase-3-backlog.md"
handoff="handoff/planner-architect/phase-3-handoff.yaml"
outdir="handoff/planner-architect/execution"

echo "== Phase 3 Backlog Generation (${role}) =="
require_file handoff/planner-architect/phase-2-handoff.yaml
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_glob_match "docs/features/*.yaml"
require_glob_match "docs/stories/*.yaml"
require_glob_match "docs/tasks/*.yaml"
require_file "$handoff"
mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"

require_approval docs/approvals/approval-phase-3.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"

echo "Phase 3 approved."
