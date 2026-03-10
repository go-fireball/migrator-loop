# ADR-0000: Use ADR Naming and Decision Discipline

- Status: Accepted
- Date: 2026-01-10
- Decision Makers: SJE-Reviewer, Planner-Architect
- Related Artifacts: `governance/templates/adr-template.md`

## Context

Migration decisions must be reviewable and durable. Critical modernization choices need explicit context and consequences.

## Decision

Adopt `ADR-XXXX-<slug>.md` naming and require an approval reference for major decisions.

## Alternatives Considered

- Keep decisions in chat logs only.
- Store decisions only in project manifest comments.

## Consequences

- Positive: Better auditability and onboarding.
- Negative: Slight process overhead.
- Follow-up actions: Add ADR checks in CI later.

## Human Approval

- Approval record: `docs/approvals/approval-phase-2.yaml`
