#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 6 Delivery Readiness (SJE-Reviewer) =="
require_file handoff/sje-reviewer/phase-6-handoff.yaml

require_approval docs/approvals/approval-phase-6.yaml

echo "Phase 6 approved. Migration ready for delivery decision."
