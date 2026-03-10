# ADR-0001: Select Hybrid Migration Mode

- Status: Proposed
- Date: 2026-01-10
- Decision Makers: Planner-Architect, SJE-Reviewer
- Related Artifacts: `docs/strategy/migration-strategy.yaml`, `docs/parity/order-processing.yaml`

## Context

The legacy system has mixed risk profiles: some modules are bounded and clear, while order processing has opaque dependencies and business-critical flows.

## Decision

Use a hybrid model: direct rewrite for clear low-risk workflows and strangler-style rollout for high-risk order processing.

## Alternatives Considered

- Full direct rewrite
- Full strangler for all modules

## Consequences

- Positive: Balances speed and risk.
- Negative: Requires careful orchestration across two migration paths.
- Follow-up actions: Confirm cutover checkpoints in phase 3 backlog.

## Human Approval

- Approval record: `docs/approvals/approval-phase-2.yaml` (pending)
