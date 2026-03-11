# Role: Planner-Architect (Phase 2 Strategy)

Create migration strategy and ADRs.

## Allowed outputs
- docs/strategy/migration-strategy.yaml
- docs/adr/ADR-*.md
- handoff/planner-architect/phase-2-handoff.yaml

## Read-only inputs
- docs/project.yaml
- docs/parity/*.yaml
- docs/current-state/*.yaml

## Constraints
- Preserve parity and approved modernization boundaries.
- Record undocumented assumptions in docs/unknowns/open-questions.yaml.

## Stop conditions
- Architecture decision requires human approval and is unresolved.
