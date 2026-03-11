#!/usr/bin/env python3
from __future__ import annotations
import argparse
import datetime
from pathlib import Path

STATUS_FILE = Path("docs/status/phase-status.yaml")
LOG_FILE = Path("docs/status/execution-log.yaml")


def read_lines(path: Path):
    return path.read_text(encoding="utf-8").splitlines()


def write_lines(path: Path, lines):
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def set_top_key(lines, key, value):
    prefix = f"{key}:"
    for i, line in enumerate(lines):
      if line.startswith(prefix):
        lines[i] = f"{key}: {value}"
        return
    lines.insert(0, f"{key}: {value}")


def set_phase_status(lines, phase: int, status: str):
    phase_line = f"  - phase: {phase}"
    idx = None
    for i, line in enumerate(lines):
        if line.strip() == f"- phase: {phase}" or line == phase_line:
            idx = i
            break
    if idx is None:
        return
    for j in range(idx + 1, min(len(lines), idx + 20)):
        if lines[j].startswith("  - phase:"):
            break
        if lines[j].strip().startswith("status:"):
            indent = lines[j].split("status:")[0]
            lines[j] = f"{indent}status: {status}"
            return


def append_log(phase, role, provider, prompt_path, handoff_path, result):
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    if not LOG_FILE.exists():
        LOG_FILE.write_text("execution_runs: []\n", encoding="utf-8")
    ts = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    entry = [
        "  - timestamp: \"%s\"" % ts,
        f"    phase: {phase}",
        f"    role: {role}",
        f"    provider: {provider}",
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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase", type=int, required=True)
    parser.add_argument("--status")
    parser.add_argument("--current-phase", type=int)
    parser.add_argument("--provider")
    parser.add_argument("--role")
    parser.add_argument("--prompt-path")
    parser.add_argument("--handoff-path")
    parser.add_argument("--result")
    args = parser.parse_args()

    lines = read_lines(STATUS_FILE)
    if args.status:
        set_phase_status(lines, args.phase, args.status)
    if args.current_phase is not None:
        set_top_key(lines, "current_phase", args.current_phase)
    if args.provider:
        set_top_key(lines, "last_assistant_provider", args.provider)
    if args.prompt_path:
        set_top_key(lines, "last_rendered_prompt", args.prompt_path)
    if args.handoff_path:
        set_top_key(lines, "last_handoff", args.handoff_path)
    write_lines(STATUS_FILE, lines)

    if args.result:
        append_log(args.phase, args.role or "unknown", args.provider or "unknown", args.prompt_path or "", args.handoff_path or "", args.result)


if __name__ == "__main__":
    main()
