#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 3 Backlog Generation (Planner-Architect) =="
require_glob_match "docs/features/*.yaml"
require_glob_match "docs/stories/*.yaml"
require_glob_match "docs/tasks/*.yaml"
require_file handoff/planner-architect/phase-3-handoff.yaml

require_approval docs/approvals/approval-phase-3.yaml

echo "Phase 3 approved."
