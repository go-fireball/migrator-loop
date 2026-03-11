#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
role="$1"; phase="$2"; prompt_file="$3"; output_dir="$4"
transcript="$output_dir/codex-phase-${phase}.log"

echo "provider: codex" > "$transcript"
echo "role: $role" >> "$transcript"
echo "phase: $phase" >> "$transcript"
echo "prompt_file: $prompt_file" >> "$transcript"

if command -v codex >/dev/null 2>&1; then
  # TODO: align flags with installed Codex CLI capabilities.
  codex exec --input-file "$prompt_file" --output-dir "$output_dir" >> "$transcript" 2>&1 || true
else
  echo "codex CLI unavailable; using mock assistant fallback" >> "$transcript"
fi

"$DIR/mock-assistant.sh" "codex" "$role" "$phase" "$prompt_file" "$output_dir" >> "$transcript" 2>&1
