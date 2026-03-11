#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

ASSISTANT_PROVIDER="${MIGRATION_ASSISTANT_PROVIDER:-$(get_default_assistant_provider)}"
TARGET_PHASE=""
RESUME=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --assistant)
      ASSISTANT_PROVIDER="$2"
      shift 2
      ;;
    --phase)
      TARGET_PHASE="$2"
      shift 2
      ;;
    --resume)
      RESUME=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

validate_assistant_provider "$ASSISTANT_PROVIDER"
MAX_RUNS="$(get_max_runs)"
RUNS=0

phase_script() {
  case "$1" in
    0) echo "phase-intake.sh" ;;
    1) echo "phase-discovery.sh" ;;
    2) echo "phase-strategy.sh" ;;
    3) echo "phase-backlog.sh" ;;
    4) echo "phase-implement.sh" ;;
    5) echo "phase-validate.sh" ;;
    6) echo "phase-delivery.sh" ;;
    *) echo "" ;;
  esac
}

run_phase() {
  local phase="$1"
  local script
  script="$(phase_script "$phase")"
  [[ -n "$script" ]] || { echo "Invalid phase: $phase" >&2; exit 1; }

  RUNS=$((RUNS + 1))
  if (( RUNS > MAX_RUNS )); then
    echo "STOP: max_agent_runs_per_session ($MAX_RUNS) exceeded"
    exit 3
  fi

  echo "Running phase ${phase} via ${script}"
  set +e
  MIGRATION_ASSISTANT_PROVIDER="$ASSISTANT_PROVIDER" "$DIR/$script"
  rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    if [[ $rc -eq 2 ]]; then
      echo "Stopped for approval at phase ${phase}."
      exit 2
    fi
    exit "$rc"
  fi

  next=$((phase + 1))
  if (( next <= 6 )); then
    advance_current_phase "$next"
  fi
}

echo "Using assistant provider: $ASSISTANT_PROVIDER"
start_phase="$(get_current_phase)"

if [[ -n "$TARGET_PHASE" ]]; then
  start_phase="$TARGET_PHASE"
fi

if [[ "$RESUME" == true && -z "$TARGET_PHASE" ]]; then
  start_phase="$(get_current_phase)"
fi

for phase in 0 1 2 3 4 5 6; do
  if (( phase < start_phase )); then
    continue
  fi
  run_phase "$phase"
  if [[ -n "$TARGET_PHASE" ]]; then
    break
  fi
done

echo "Migration baton sequence complete."
