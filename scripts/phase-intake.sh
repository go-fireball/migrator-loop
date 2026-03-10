#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 0 Intake (Analyst) =="
require_file docs/project.yaml
require_file handoff/analyst/phase-0-handoff.yaml

echo "Set phase 0 status to needs_human_review and request approval."
require_approval docs/approvals/approval-phase-0.yaml

echo "Phase 0 approved."
