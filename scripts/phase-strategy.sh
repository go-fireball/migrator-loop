#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 2 Strategy (Planner-Architect) =="
require_file docs/strategy/migration-strategy.yaml
require_glob_match "docs/adr/ADR-*.md"
require_file handoff/planner-architect/phase-2-handoff.yaml

if grep -Eq '^[[:space:]]*status:[[:space:]]*needs_human_review([[:space:]]|$)' docs/unknowns/open-questions.yaml; then
  log_stop "Open human-review questions detected."
  exit 4
fi

require_approval docs/approvals/approval-phase-2.yaml

echo "Phase 2 approved."
