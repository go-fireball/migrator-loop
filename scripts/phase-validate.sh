#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

provider="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
phase=5
role="Validator"
role_slug="validator"
template="governance/prompts/validator-phase-5-validate.md"
handoff="handoff/validator/phase-5-handoff.yaml"
outdir="handoff/validator/execution"

echo "== Phase 5 Validation (${role}) =="
require_file handoff/builder/phase-4-handoff.yaml
prompt_path="$("$DIR/render-prompt.sh" "$phase" "$role_slug" "$template")"
"$DIR/providers/run-assistant.sh" "$provider" "$role" "$phase" "$prompt_path" "$outdir"

require_file docs/validation-report.yaml
require_file "$handoff"
mark_phase_needs_human_review "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "stop_for_approval"

require_approval docs/approvals/approval-phase-5.yaml
mark_phase_approved "$phase"
record_phase_metadata "$phase" "$role" "$provider" "$prompt_path" "$handoff" "success"

echo "Phase 5 approved."
