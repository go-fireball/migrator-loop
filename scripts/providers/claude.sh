#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
role="$1"; phase="$2"; prompt_file="$3"; output_dir="$4"
transcript="$output_dir/claude-phase-${phase}.log"

echo "provider: claude" > "$transcript"
echo "role: $role" >> "$transcript"
echo "phase: $phase" >> "$transcript"
echo "prompt_file: $prompt_file" >> "$transcript"

if command -v claude >/dev/null 2>&1; then
  # TODO: replace with exact Claude CLI invocation in your environment.
  claude --prompt-file "$prompt_file" --output-dir "$output_dir" >> "$transcript" 2>&1 || true
else
  echo "claude CLI unavailable; using mock assistant fallback" >> "$transcript"
fi

"$DIR/mock-assistant.sh" "claude" "$role" "$phase" "$prompt_file" "$output_dir" >> "$transcript" 2>&1
