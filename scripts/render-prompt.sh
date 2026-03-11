#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <phase> <role-slug> <template-file>" >&2
  exit 1
fi

phase="$1"
role_slug="$2"
template="$3"
out_dir="handoff/${role_slug}"
out_file="${out_dir}/rendered-phase-${phase}-prompt.md"

mkdir -p "$out_dir"

{
  echo "# Rendered Prompt - Phase ${phase}"
  echo
  echo "Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
  cat "$template"
  echo
  echo "---"
  echo "## Project manifest (docs/project.yaml)"
  sed -n '1,220p' docs/project.yaml
  echo
  echo "## Phase status (docs/status/phase-status.yaml)"
  sed -n '1,260p' docs/status/phase-status.yaml

  case "$phase" in
    0)
      ;;
    1)
      echo
      echo "## Previous handoff"
      sed -n '1,200p' handoff/analyst/phase-0-handoff.yaml 2>/dev/null || true
      ;;
    2)
      echo
      echo "## Discovery docs"
      sed -n '1,220p' docs/current-state/system-inventory.yaml 2>/dev/null || true
      sed -n '1,220p' docs/current-state/workflow-map.yaml 2>/dev/null || true
      ;;
    3)
      echo
      echo "## Strategy docs"
      sed -n '1,220p' docs/strategy/migration-strategy.yaml 2>/dev/null || true
      ;;
    4)
      echo
      echo "## Backlog docs"
      sed -n '1,220p' docs/features/*.yaml 2>/dev/null || true
      sed -n '1,220p' docs/stories/*.yaml 2>/dev/null || true
      sed -n '1,220p' docs/tasks/*.yaml 2>/dev/null || true
      ;;
    5)
      echo
      echo "## Implementation handoff"
      sed -n '1,220p' handoff/builder/phase-4-handoff.yaml 2>/dev/null || true
      ;;
    6)
      echo
      echo "## Validation report"
      sed -n '1,220p' docs/validation-report.yaml 2>/dev/null || true
      ;;
  esac

  echo
  echo "## Open questions"
  sed -n '1,220p' docs/unknowns/open-questions.yaml 2>/dev/null || true

  echo
  echo "## Parity references"
  sed -n '1,220p' docs/parity/*.yaml 2>/dev/null || true
} > "$out_file"

echo "$out_file"
