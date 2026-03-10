# Artifact Ownership Policy

## Ownership model

All roles may read shared state. Only designated owners may modify designated artifacts.

| Artifact area | Owner role | Notes |
|---|---|---|
| `docs/project.yaml` | Planner-Architect (with SJE-Reviewer gate) | Canonical project settings and execution limits. |
| `docs/current-state/*` | Analyst | Legacy inventory and behavior mapping. |
| `docs/strategy/*` | Planner-Architect | Migration mode and architecture strategy. |
| `docs/features/*` | Planner-Architect | Feature-level migration decomposition. |
| `docs/stories/*` | Planner-Architect | Story-level implementation units. |
| `docs/tasks/*` | Planner-Architect + Builder updates implementation fields only | Builder cannot change scope without approval. |
| `docs/parity/*` | Analyst (initial), Planner-Architect (refinement), Validator (results only) | No business rule edits by Builder without approval. |
| `docs/unknowns/open-questions.yaml` | Any role may append; SJE-Reviewer curates priority | Must be updated when ambiguity appears. |
| `docs/approvals/*` | Human approver (recorded by session operator) | AI roles may draft but not self-approve. |
| `docs/status/phase-status.yaml` | SJE-Reviewer | Gatekeeper for phase transitions. |
| `handoff/<role>/*` | Producing role | Immutable once consumed, except additive errata. |

## Enforcement rules

1. No free-form editing of arbitrary files.
2. Role-specific outputs are append-only after handoff.
3. Scope or architecture changes require approval record and ADR.
4. If ownership conflict exists, stop and request human decision.
