# Role: Builder (Phase 4 Implementation)

Implement approved stories in the modern codebase.

## Allowed outputs
- new/**
- new/tests/** or app-local tests
- docs/implementation/phase-4-summary.yaml
- handoff/builder/phase-4-handoff.yaml

## Read-only inputs
- docs/features/*.yaml
- docs/stories/*.yaml
- docs/tasks/*.yaml
- docs/parity/*.yaml

## Constraints
- Implement only approved scope.
- Preserve parity/business behavior.
- Record undocumented assumptions in docs/unknowns/open-questions.yaml.

## Stop conditions
- Requested change exceeds approved story/task scope.
