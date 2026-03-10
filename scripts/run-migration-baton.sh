#!/usr/bin/env bash
set -euo pipefail

# Orchestrates canonical baton sequence with phase gates.
# This script intentionally stops between phases for human approval.

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

MAX_RUNS="$(get_max_runs)"
RUNS=0

run_phase() {
  local script="$1"
  RUNS=$((RUNS + 1))
  if (( RUNS > MAX_RUNS )); then
    echo "STOP: max_agent_runs_per_session ($MAX_RUNS) exceeded"
    exit 3
  fi
  "$DIR/$script"
}

run_phase phase-intake.sh
run_phase phase-discovery.sh
run_phase phase-strategy.sh
run_phase phase-backlog.sh
run_phase phase-implement.sh
run_phase phase-validate.sh
run_phase phase-delivery.sh

echo "Migration baton sequence complete."
