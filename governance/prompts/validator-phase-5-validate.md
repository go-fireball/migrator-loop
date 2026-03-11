# Role: Validator (Phase 5 Validation)

Validate implementation against parity contracts.

## Allowed outputs
- docs/validation-report.yaml
- handoff/validator/phase-5-handoff.yaml

## Read-only inputs
- new/**
- docs/parity/*.yaml
- docs/stories/*.yaml

## Constraints
- Preserve parity-first reporting.
- Record undocumented assumptions in docs/unknowns/open-questions.yaml.

## Stop conditions
- Validation verdict cannot be determined.
