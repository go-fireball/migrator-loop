# migration-loop

`migration-loop` is a governance-first, human-in-the-loop migration framework.
It uses a controlled baton model: assistants perform phase work, then humans approve before continuation.

## Execution lifecycle (per phase)

1. Validate prerequisites.
2. Render an inspectable prompt at `handoff/<role>/rendered-phase-<n>-prompt.md`.
3. Invoke selected provider (`codex`, `claude`, `copilot`) via adapters.
4. Validate required artifacts.
5. Mark phase `needs_human_review`.
6. Stop for approval.

### Resume semantics (important)

- **Before approval:** rerun stops without re-running assistant work.
- **After approval:** rerun finalizes the phase, updates status/manifest, and advances to the next phase **without re-running assistant work**.

This preserves strict sequencing while avoiding duplicate assistant executions.

## Quick start

1. Place legacy app under `old/`.
2. Update `docs/project.yaml`.
3. Run baton:
   - `scripts/run-migration-baton.sh`
   - or `scripts/run-migration-baton.sh --assistant claude`
4. Review outputs and approvals.
5. Resume with `scripts/run-migration-baton.sh --resume`.

Optional controls:
- `--phase <n>`: run only a specific phase.
- `ALLOW_MOCK_FALLBACK=true|false`: control fallback behavior in provider adapters.

## Provider adapter model

Provider wrappers live in `scripts/providers/`:
- `codex.sh`
- `claude.sh`
- `copilot.sh`
- shared dispatcher: `run-assistant.sh`

Behavior:
- If real CLI is available and succeeds, **mock is not executed**.
- If CLI is missing/fails, mock fallback is used only when `ALLOW_MOCK_FALLBACK=true` (default).
- Execution mode is written to phase output and execution log (`real`, `mock_fallback`, `resume_no_execution`, etc.).

## Traceability

- `docs/status/phase-status.yaml`: current phase, per-phase statuses, and last prompt/handoff/provider metadata.
- `docs/project.yaml`: includes `last_successful_phase` and execution-provider contract fields.
- `docs/status/execution-log.yaml`: append-only execution events with result and execution mode.

## Guardrails (unchanged)

- Human approval gates are mandatory.
- `docs/parity/` and parity-first behavior are preserved.
- `docs/unknowns/open-questions.yaml` remains the place for unresolved assumptions.
- This is not an always-on autonomous agent runtime.
