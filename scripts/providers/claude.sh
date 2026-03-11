#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/provider-common.sh"

role="$1"; phase="$2"; prompt_file="$3"; output_dir="$4"
transcript="$output_dir/claude-phase-${phase}.log"

{
  echo "provider: claude"
  echo "role: $role"
  echo "phase: $phase"
  echo "prompt_file: $prompt_file"
} > "$transcript"

# TODO: replace with exact Claude CLI invocation in your environment.
run_with_fallback "claude" "$role" "$phase" "$prompt_file" "$output_dir" "$transcript" "$DIR/mock-assistant.sh" \
  claude --prompt-file "$prompt_file" --output-dir "$output_dir"
