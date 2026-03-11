#!/usr/bin/env bash
set -euo pipefail
provider="$1"; role="$2"; phase="$3"; prompt_file="$4"; output_dir="$5"
ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p "$output_dir"
summary="$output_dir/phase-${phase}-assistant-summary.md"
{
  echo "# Assistant Execution Summary"
  echo "- provider: $provider"
  echo "- role: $role"
  echo "- phase: $phase"
  echo "- prompt: $prompt_file"
  echo "- generated_at: $ts"
} > "$summary"

case "$phase" in
  0)
    mkdir -p handoff/analyst
    [[ -f docs/project.yaml ]] || cat > docs/project.yaml <<'YAML'
project_name: migration-loop-demo
migration_mode: hybrid
legacy_stack_summary:
  - "Legacy app"
target_stack_summary:
  - "Modernized app"
current_phase: 0
app_type: mixed
default_assistant_provider: codex
assistant_execution_mode: cli
execution_limits:
  max_agent_runs_per_session: 12
provider_overrides: {}
last_successful_phase: -1
key_modernization_decisions: []
YAML
    cat > handoff/analyst/phase-0-handoff.yaml <<YAML
phase: 0
from_role: Analyst
to_role: Analyst
summary: Intake completed by ${provider}.
open_questions_file: docs/unknowns/open-questions.yaml
generated_at: "$ts"
YAML
    ;;
  1)
    mkdir -p docs/current-state docs/parity handoff/analyst
    [[ -f docs/current-state/system-inventory.yaml ]] || cat > docs/current-state/system-inventory.yaml <<YAML
systems:
  - name: legacy-app
    notes: Generated during phase 1 discovery.
YAML
    [[ -f docs/current-state/workflow-map.yaml ]] || cat > docs/current-state/workflow-map.yaml <<YAML
workflows:
  - id: WF-001
    name: Login flow
YAML
    [[ -f docs/parity/core-flow.yaml ]] || cat > docs/parity/core-flow.yaml <<YAML
feature: core-flow
parity_goal: Preserve core user behavior.
YAML
    cat > handoff/analyst/phase-1-handoff.yaml <<YAML
phase: 1
from_role: Analyst
to_role: Planner-Architect
summary: Discovery artifacts refreshed.
generated_at: "$ts"
YAML
    ;;
  2)
    mkdir -p docs/strategy docs/adr handoff/planner-architect
    [[ -f docs/strategy/migration-strategy.yaml ]] || cat > docs/strategy/migration-strategy.yaml <<YAML
strategy_summary: Assistant-generated migration strategy draft.
YAML
    [[ -f docs/adr/ADR-0001-migration-mode.md ]] || cat > docs/adr/ADR-0001-migration-mode.md <<MD
# ADR-0001 Migration Mode
Status: proposed
MD
    cat > handoff/planner-architect/phase-2-handoff.yaml <<YAML
phase: 2
from_role: Planner-Architect
to_role: Planner-Architect
summary: Strategy draft produced.
generated_at: "$ts"
YAML
    ;;
  3)
    mkdir -p docs/features docs/stories docs/tasks handoff/planner-architect
    [[ -f docs/features/feature-generated.yaml ]] || echo -e "id: FEAT-GEN\nstatus: draft" > docs/features/feature-generated.yaml
    [[ -f docs/stories/story-generated.yaml ]] || echo -e "id: STORY-GEN\nstatus: draft" > docs/stories/story-generated.yaml
    [[ -f docs/tasks/task-generated.yaml ]] || echo -e "id: TASK-GEN\nstatus: draft" > docs/tasks/task-generated.yaml
    cat > handoff/planner-architect/phase-3-handoff.yaml <<YAML
phase: 3
from_role: Planner-Architect
to_role: Builder
summary: Backlog generated/updated.
generated_at: "$ts"
YAML
    ;;
  4)
    mkdir -p new/apps new/tests handoff/builder docs/implementation
    [[ -f new/apps/README.md ]] || echo "Generated implementation placeholder." > new/apps/README.md
    [[ -f new/tests/smoke.test.md ]] || echo "Implementation smoke checklist." > new/tests/smoke.test.md
    cat > docs/implementation/phase-4-summary.yaml <<YAML
phase: 4
summary: Implementation artifacts created by assistant wrapper.
generated_at: "$ts"
YAML
    cat > handoff/builder/phase-4-handoff.yaml <<YAML
phase: 4
from_role: Builder
to_role: Validator
summary: Implementation complete for approved scope.
generated_at: "$ts"
YAML
    ;;
  5)
    mkdir -p handoff/validator
    cat > docs/validation-report.yaml <<YAML
phase: 5
verdict: pending_human_review
notes: Validation report updated by assistant wrapper.
generated_at: "$ts"
YAML
    cat > handoff/validator/phase-5-handoff.yaml <<YAML
phase: 5
from_role: Validator
to_role: SJE-Reviewer
summary: Validation run complete; see docs/validation-report.yaml.
generated_at: "$ts"
YAML
    ;;
  6)
    mkdir -p handoff/sje-reviewer docs/delivery
    cat > docs/delivery/phase-6-readiness.yaml <<YAML
phase: 6
readiness: pending_human_approval
generated_at: "$ts"
YAML
    cat > handoff/sje-reviewer/phase-6-handoff.yaml <<YAML
phase: 6
from_role: SJE-Reviewer
to_role: Human Approver
summary: Delivery readiness artifacts prepared.
generated_at: "$ts"
YAML
    ;;
  *)
    echo "Unknown phase: $phase" >&2
    exit 1
    ;;
esac

echo "Mock assistant wrote phase artifacts for phase $phase"
