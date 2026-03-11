#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime
from pathlib import Path

STATUS_FILE = Path("docs/status/phase-status.yaml")
PROJECT_FILE = Path("docs/project.yaml")
LOG_FILE = Path("docs/status/execution-log.yaml")


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def write_lines(path: Path, lines: list[str]) -> None:
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def set_top_key(lines: list[str], key: str, value) -> None:
    prefix = f"{key}:"
    for i, line in enumerate(lines):
        if line.startswith(prefix):
            lines[i] = f"{key}: {value}"
            return
    lines.insert(0, f"{key}: {value}")


def set_phase_status(lines: list[str], phase: int, status: str) -> None:
    idx = None
    for i, line in enumerate(lines):
        if line.strip() == f"- phase: {phase}":
            idx = i
            break
    if idx is None:
        return

    for j in range(idx + 1, len(lines)):
        if lines[j].startswith("  - phase:"):
            break
        if lines[j].strip().startswith("status:"):
            indent = lines[j].split("status:")[0]
            lines[j] = f"{indent}status: {status}"
            return


def append_log(phase: int, role: str, provider: str, prompt_path: str, handoff_path: str, result: str, execution_mode: str) -> None:
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    if not LOG_FILE.exists():
        LOG_FILE.write_text("execution_runs: []\n", encoding="utf-8")

    ts = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    entry = [
        f"  - timestamp: \"{ts}\"",
        f"    phase: {phase}",
        f"    role: {role}",
        f"    provider: {provider}",
        f"    execution_mode: {execution_mode}",
        f"    rendered_prompt: {prompt_path}",
        f"    handoff: {handoff_path}",
        f"    result: {result}",
    ]

    text = LOG_FILE.read_text(encoding="utf-8")
    if "execution_runs:" not in text:
        text = "execution_runs:\n"
    if text.rstrip().endswith("execution_runs: []"):
        text = text.replace("execution_runs: []", "execution_runs:\n" + "\n".join(entry))
    else:
        text = text.rstrip() + "\n" + "\n".join(entry)
    LOG_FILE.write_text(text + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase", type=int, required=True)
    parser.add_argument("--status")
    parser.add_argument("--current-phase", type=int)
    parser.add_argument("--last-successful-phase", type=int)
    parser.add_argument("--provider")
    parser.add_argument("--role")
    parser.add_argument("--prompt-path")
    parser.add_argument("--handoff-path")
    parser.add_argument("--result")
    parser.add_argument("--execution-mode", default="unknown")
    args = parser.parse_args()

    status_lines = read_lines(STATUS_FILE)
    if args.status:
        set_phase_status(status_lines, args.phase, args.status)
    if args.current_phase is not None:
        set_top_key(status_lines, "current_phase", args.current_phase)
    if args.provider:
        set_top_key(status_lines, "last_assistant_provider", args.provider)
    if args.prompt_path:
        set_top_key(status_lines, "last_rendered_prompt", args.prompt_path)
    if args.handoff_path:
        set_top_key(status_lines, "last_handoff", args.handoff_path)
    write_lines(STATUS_FILE, status_lines)

    project_lines = read_lines(PROJECT_FILE)
    if args.current_phase is not None:
        set_top_key(project_lines, "current_phase", args.current_phase)
    if args.last_successful_phase is not None:
        set_top_key(project_lines, "last_successful_phase", args.last_successful_phase)
    write_lines(PROJECT_FILE, project_lines)

    if args.result:
        append_log(
            args.phase,
            args.role or "unknown",
            args.provider or "unknown",
            args.prompt_path or "",
            args.handoff_path or "",
            args.result,
            args.execution_mode,
        )


if __name__ == "__main__":
    main()
