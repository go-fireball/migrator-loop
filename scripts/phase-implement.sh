#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=4
role="Builder"
role_slug="builder"
template="governance/prompts/builder-phase-4-implement.md"
handoff="handoff/builder/phase-4-handoff.yaml"
outdir="handoff/builder/execution"

echo "== Phase 4 Story Implementation (${role}) =="
require_file handoff/planner-architect/phase-3-handoff.yaml
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_nonempty_dir new
require_file docs/implementation/phase-4-summary.yaml
require_file "$handoff"
mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"

require_approval docs/approvals/approval-phase-4.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"

echo "Phase 4 approved."
