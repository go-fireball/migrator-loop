# migration-loop

`migration-loop` is a governance-first, human-in-the-loop framework for modernizing **one legacy application at a time**. It uses a tagged baton handoff model across explicit phases and roles, with hard stop points for human review.

The framework is designed for teams who want AI-assisted migration **without** open-ended autonomous execution.

## Core Philosophy

1. Preserve business behavior and core workflows first.
2. Modernize technology second.
3. Delivery-channel changes (for example, Windows desktop to web) require explicit human approval.
4. Prefer direct parity rewrite for small/medium apps with clear boundaries.
5. Prefer hybrid or strangler migration for large, business-critical, or unclear systems.
6. Prefer modular monoliths over many microservices.
7. Use mainstream frameworks and boring, maintainable architecture.
8. Stop between phases and require human approval before continuing.
9. Record all approvals, questions, unknowns, and decisions in durable files.
10. Make structured artifacts machine-readable and human-readable (YAML-first).

## What this repository provides

- Governance policies, role definitions, and ownership rules.
- Strict YAML schemas for key migration artifacts.
- Templates for repeatable, inspectable outputs.
- Baton handoff folders per role.
- Phase scripts that enforce approval gates.
- First-class parity contract structure under `docs/parity/`.
- `old/` and `new/` boundaries for legacy and modernized code.

## Folder layout

```text
migration-loop/
  README.md
  governance/
    policies/
    roles/
    schemas/
    templates/
    judgments/
  docs/
    current-state/
    strategy/
    features/
    stories/
    tasks/
    parity/
    unknowns/
    adr/
    approvals/
    status/
  handoff/
    analyst/
    planner-architect/
    builder/
    validator/
    sje-reviewer/
  old/
  new/
    apps/
    packages/
    infra/
    tests/
  scripts/
```

## Quick start

1. Copy your entire legacy repository into `old/`.
2. Review and update `docs/project.yaml`.
3. Run `scripts/run-migration-baton.sh`.
4. Complete each phase in order.
5. At each phase stop, review artifacts and record a human approval in `docs/approvals/`.
6. Continue only after approval status is `approved`.

## Canonical phases

- Phase 0 - Intake
- Phase 1 - Discovery
- Phase 2 - Strategy
- Phase 3 - Backlog Generation
- Phase 4 - Story Implementation
- Phase 5 - Validation
- Phase 6 - Delivery Readiness

Each phase has:
- expected outputs,
- a handoff location,
- a role owner,
- a schema/template,
- explicit stop conditions,
- an approval gate.

## How approvals work

- Every phase writes `needs_human_review` before pause.
- Human approval is captured in `docs/approvals/approval-<phase>.yaml`.
- `docs/status/phase-status.yaml` is updated only after approval.
- If ambiguity/conflict exists, phase must stop and open a question in `docs/unknowns/open-questions.yaml`.

## How parity contracts work

Parity contracts define behavior to preserve while modernizing implementation.

Key fields include:
- legacy entry points and modules,
- target apps,
- business rules and edge cases,
- allowed modernizations,
- forbidden changes,
- validation approach and parity result.

See examples in:
- `docs/parity/login.yaml`
- `docs/parity/order-processing.yaml`

## Agent roles

- **Analyst**: inventories `old/`, captures workflows/dependencies/risks, initializes parity artifacts.
- **Planner-Architect**: selects migration mode, target architecture, features/stories/tasks, modernization decisions.
- **Builder**: implements approved stories in `new/`.
- **Validator**: verifies unit/integration/parity outcomes and deviations.
- **SJE-Reviewer**: governance/judgment gate for boring architecture and risk control.

## Example migration flow

1. Intake: define project scope, constraints, and initial risks.
2. Discovery: map legacy modules and workflows.
3. Strategy: pick direct rewrite/hybrid/strangler and architecture.
4. Backlog: produce feature/story/task files tied to parity contracts.
5. Implementation: deliver approved stories under `new/`.
6. Validation: compare behavior against parity contracts.
7. Delivery Readiness: final readiness summary and release plan.

## Guardrails and non-goals

### Guardrails

- Do not proceed past a phase without a recorded approval.
- Do not change behavior outside approved parity scope.
- Do not bypass unknown/question tracking.
- Do not let non-owner roles edit owner-controlled artifacts.

### Non-goals / anti-patterns

- Not a fully autonomous always-on multi-agent runtime.
- No default microservices-first decomposition.
- No invention of undocumented business behavior.
- No silent external behavior changes.
- No default NoSQL choice for relational workloads.
- No Lambda-first architecture by default.
- No custom framework creation without explicit justification.
- No automatic continuation through approval gates.

## Default technical guidance

- Backend: ASP.NET Core (C#), controller/service/repository, optional pragmatic vertical slices.
- Frontend: React + Next.js (React/Vite for lightweight internal tools).
- Database: PostgreSQL by default, with risk-reducing transitional options allowed.
- Infra: AWS default, CDK preferred, ECS/Fargate preferred, RDS/Aurora PostgreSQL preferred.
- Auth: Cognito default on AWS unless justified override.
- CI/CD: include GitHub Actions and Azure DevOps templates.

## ADR usage

Use `docs/adr/ADR-XXXX-<slug>.md` with the provided template. ADRs are required for major modernization choices, especially delivery channel changes or architecture boundary shifts.
