#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=0
role="Analyst"
role_slug="analyst"
template="governance/prompts/analyst-phase-0-intake.md"
handoff="handoff/analyst/phase-0-handoff.yaml"
outdir="handoff/analyst/execution"

echo "== Phase 0 Intake (${role}) =="
require_file "$template"
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_file docs/project.yaml
require_file "$handoff"
mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"

require_approval docs/approvals/approval-phase-0.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"
echo "Phase 0 approved."
