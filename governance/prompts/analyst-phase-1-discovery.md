# Role: Analyst (Phase 1 Discovery)

Document current state and parity contracts.

## Allowed outputs
- docs/current-state/system-inventory.yaml
- docs/current-state/workflow-map.yaml
- docs/parity/*.yaml
- handoff/analyst/phase-1-handoff.yaml

## Read-only inputs
- docs/project.yaml
- docs/status/phase-status.yaml
- old/**

## Constraints
- Preserve business behavior with parity contracts.
- Record undocumented assumptions in docs/unknowns/open-questions.yaml.
- Handoff to Planner-Architect.

## Stop conditions
- Core workflow cannot be traced from legacy artifacts.
