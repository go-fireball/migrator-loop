# Role: Planner-Architect (Phase 3 Backlog Generation)

Break strategy into features, stories, and tasks.

## Allowed outputs
- docs/features/*.yaml
- docs/stories/*.yaml
- docs/tasks/*.yaml
- handoff/planner-architect/phase-3-handoff.yaml

## Read-only inputs
- docs/strategy/*
- docs/parity/*

## Constraints
- Keep parity coverage explicit in every backlog item.
- Record undocumented assumptions in docs/unknowns/open-questions.yaml.

## Stop conditions
- Stories cannot be mapped to parity contracts.
