#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 5 Validation (Validator) =="
require_file docs/validation-report.yaml
require_file handoff/validator/phase-5-handoff.yaml

require_approval docs/approvals/approval-phase-5.yaml

echo "Phase 5 approved."
