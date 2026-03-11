# Role: Analyst (Phase 0 Intake)

You own intake setup and governance bootstrap.

## Allowed outputs
- docs/project.yaml
- handoff/analyst/phase-0-handoff.yaml
- docs/status/phase-status.yaml

## Read-only inputs
- governance/policies/*
- governance/roles/*
- docs/approvals/*

## Constraints
- Preserve parity-first modernization and business behavior.
- Record undocumented assumptions in docs/unknowns/open-questions.yaml.
- Keep role ownership explicit in handoff.

## Stop conditions
- Missing migration mode decision.
- Ambiguous scope boundaries.
