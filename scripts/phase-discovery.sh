#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=1
role="Analyst"
role_slug="analyst"
template="governance/prompts/analyst-phase-1-discovery.md"
handoff="handoff/analyst/phase-1-handoff.yaml"
outdir="handoff/analyst/execution"

echo "== Phase 1 Discovery (${role}) =="
require_file handoff/analyst/phase-0-handoff.yaml
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_file docs/current-state/system-inventory.yaml
require_file docs/current-state/workflow-map.yaml
require_glob_match "docs/parity/*.yaml"
require_file "$handoff"
mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"

require_approval docs/approvals/approval-phase-1.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"

echo "Phase 1 approved."
