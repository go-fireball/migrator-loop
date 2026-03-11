#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/provider-common.sh"

role="$1"; phase="$2"; prompt_file="$3"; output_dir="$4"
transcript="$output_dir/copilot-phase-${phase}.log"

{
  echo "provider: copilot"
  echo "role: $role"
  echo "phase: $phase"
  echo "prompt_file: $prompt_file"
} > "$transcript"

# TODO: adjust to supported GitHub Copilot CLI command set.
run_with_fallback "copilot" "$role" "$phase" "$prompt_file" "$output_dir" "$transcript" "$DIR/mock-assistant.sh" \
  gh copilot suggest -f "$prompt_file"
