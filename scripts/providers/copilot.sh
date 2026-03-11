#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
role="$1"; phase="$2"; prompt_file="$3"; output_dir="$4"
transcript="$output_dir/copilot-phase-${phase}.log"

echo "provider: copilot" > "$transcript"
echo "role: $role" >> "$transcript"
echo "phase: $phase" >> "$transcript"
echo "prompt_file: $prompt_file" >> "$transcript"

if command -v gh >/dev/null 2>&1; then
  # TODO: adjust to supported GitHub Copilot CLI command set.
  gh copilot suggest -f "$prompt_file" >> "$transcript" 2>&1 || true
else
  echo "gh CLI unavailable; using mock assistant fallback" >> "$transcript"
fi

"$DIR/mock-assistant.sh" "copilot" "$role" "$phase" "$prompt_file" "$output_dir" >> "$transcript" 2>&1
