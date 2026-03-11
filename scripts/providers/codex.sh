#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/provider-common.sh"

role="$1"; phase="$2"; prompt_file="$3"; output_dir="$4"
transcript="$output_dir/codex-phase-${phase}.log"

{
  echo "provider: codex"
  echo "role: $role"
  echo "phase: $phase"
  echo "prompt_file: $prompt_file"
} > "$transcript"

# TODO: align flags with installed Codex CLI capabilities.
run_with_fallback "codex" "$role" "$phase" "$prompt_file" "$output_dir" "$transcript" "$DIR/mock-assistant.sh" \
  codex exec --input-file "$prompt_file" --output-dir "$output_dir"
