#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 1 Discovery (Analyst) =="
require_file docs/current-state/system-inventory.yaml
require_file docs/current-state/workflow-map.yaml
require_file docs/parity/login.yaml
require_file docs/parity/order-processing.yaml
require_file handoff/analyst/phase-1-handoff.yaml

require_approval docs/approvals/approval-phase-1.yaml

echo "Phase 1 approved."
