# migration-loop

`migration-loop` is a governance-first, human-in-the-loop migration framework. It now combines:

1. **Execution baton** (assistant actually performs phase work)
2. **Governance gates** (human approval is still mandatory between phases)

This is intentionally **not** an always-on autonomous agent system.

## Core model

For each phase, baton execution is:

1. Validate prerequisites
2. Render inspectable phase prompt
3. Invoke selected assistant provider (`codex`, `claude`, `copilot`)
4. Generate/update phase artifacts
5. Validate required artifacts
6. Mark `needs_human_review`
7. Stop for approval
8. On rerun with approval in place, mark phase approved and continue

## Folder layout additions

```text
scripts/
  providers/
    run-assistant.sh
    codex.sh
    claude.sh
    copilot.sh
    mock-assistant.sh
  render-prompt.sh
  update-status.py
governance/
  prompts/
docs/status/
  execution-log.yaml
```

## Quick start

1. Copy legacy code into `old/`.
2. Configure `docs/project.yaml` (provider + execution limits).
3. Run baton:
   - `scripts/run-migration-baton.sh`
   - or `scripts/run-migration-baton.sh --assistant claude`
4. Review artifacts and rendered prompt under `handoff/<role>/`.
5. Approve phase in `docs/approvals/approval-phase-<n>.yaml`.
6. Resume:
   - `scripts/run-migration-baton.sh --resume`
   - or target a phase: `scripts/run-migration-baton.sh --phase 3`

## Provider adapter model

- Provider CLIs are isolated in `scripts/providers/*.sh`.
- Adapters contain realistic CLI wrappers and TODO notes for exact flags.
- When a provider CLI is unavailable, adapters fall back to `mock-assistant.sh` so baton behavior remains testable and inspectable.
- Provider selection does **not** bypass approvals.

## Prompt rendering

Each phase uses a prompt template from `governance/prompts/`.

The rendered prompt is written to:

- `handoff/<role>/rendered-phase-<n>-prompt.md`

Rendered prompts include project/status context, parity references, open questions, and phase-specific source artifacts.

## Traceability

- `docs/status/phase-status.yaml` tracks current phase, per-phase status, last provider, last rendered prompt, and last handoff.
- `docs/status/execution-log.yaml` appends phase run entries:
  - timestamp
  - phase
  - role
  - provider
  - rendered prompt path
  - handoff path
  - result (`success|stop_for_approval|error`)

## Approvals remain hard gates

Human-in-the-loop control is unchanged:

- phase work is executed first,
- baton stops for approval,
- continuation requires `decision: approved`.

## Canonical phases and ownership

- Phase 0: Intake (**Analyst**)
- Phase 1: Discovery (**Analyst**)
- Phase 2: Strategy (**Planner-Architect**)
- Phase 3: Backlog Generation (**Planner-Architect**)
- Phase 4: Story Implementation (**Builder**) in `new/`
- Phase 5: Validation (**Validator**)
- Phase 6: Delivery Readiness (**SJE-Reviewer**)

## Guardrails preserved

- parity-first modernization
- docs/parity contracts
- docs/unknowns decision tracking
- role-owned handoffs
- strict phase sequencing with stop points
- mandatory human approvals between phases
