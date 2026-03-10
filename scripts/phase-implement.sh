#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

echo "== Phase 4 Story Implementation (Builder) =="
require_file handoff/builder/phase-4-handoff.yaml

echo "Implementation occurs in new/."
echo "Do not proceed if story/task status is not approved."

require_approval docs/approvals/approval-phase-4.yaml

echo "Phase 4 approved."
