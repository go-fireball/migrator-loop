# Phase Policy

Each phase must end in one of:
- `needs_human_review`
- `blocked`
- `approved`

No script may auto-advance past phase gates.

## Required gate checks per phase

1. Required outputs present.
2. Handoff summary written.
3. Unknowns updated.
4. Approval record exists with `decision: approved`.
5. `docs/status/phase-status.yaml` updated by SJE-Reviewer.

## Stop conditions

- Missing required artifact.
- Ambiguous migration decision.
- Conflicting parity contracts.
- Requested modernization without explicit approval.
- `max_agent_runs_per_session` exceeded.
