#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=6
role="SJE-Reviewer"
role_slug="sje-reviewer"
template="governance/prompts/sje-reviewer-phase-6-delivery.md"
handoff="handoff/sje-reviewer/phase-6-handoff.yaml"
outdir="handoff/sje-reviewer/execution"

echo "== Phase 6 Delivery Readiness (${role}) =="
require_file handoff/validator/phase-5-handoff.yaml
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_file docs/delivery/phase-6-readiness.yaml
require_file "$handoff"
mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"

require_approval docs/approvals/approval-phase-6.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"

echo "Phase 6 approved. Migration ready for delivery decision."
