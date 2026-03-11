#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 5 ]]; then
  echo "Usage: $0 <provider> <role> <phase> <prompt_file> <output_dir>" >&2
  exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
provider="$1"
role="$2"
phase="$3"
prompt_file="$4"
output_dir="$5"

mkdir -p "$output_dir"

case "$provider" in
  codex|claude|copilot)
    ;;
  *)
    echo "ERROR: Unsupported provider '$provider'" >&2
    exit 1
    ;;
esac

"$DIR/${provider}.sh" "$role" "$phase" "$prompt_file" "$output_dir"
