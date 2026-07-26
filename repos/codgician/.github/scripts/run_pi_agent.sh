#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

input=${1:?prompt file or --check is required}
: "${PACKAGE:?PACKAGE is required}"
: "${DENDRO_API_KEY:?DENDRO_API_KEY is required}"

repository_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
runtime_dir=$(mktemp -d)
trap 'rm -rf "$runtime_dir"' EXIT
cp "$repository_root/.github/pi/models.json" "$runtime_dir/models.json"
export PI_CODING_AGENT_DIR="$runtime_dir"
export PI_OFFLINE=1
export PI_TELEMETRY=0

if [[ "$input" == "--check" ]]; then
  export PI_GUARD_SELF_TEST=1
  cd -- "$repository_root"
  pi \
    --offline \
    --no-approve \
    --no-extensions \
    --extension "$repository_root/.github/pi/ci-guard.ts" \
    --list-models dendro
  exit 0
fi

prompt_path=$(realpath -- "$input")
case "$prompt_path" in
  "$repository_root"/*) ;;
  *)
    echo "Prompt file must be inside the repository: $input" >&2
    exit 2
    ;;
esac

prompt=$(<"$prompt_path")
cd -- "$repository_root"

pi \
  --print \
  --no-session \
  --offline \
  --no-approve \
  --no-extensions \
  --extension "$repository_root/.github/pi/ci-guard.ts" \
  --no-skills \
  --no-prompt-templates \
  --no-themes \
  --no-context-files \
  --tools read,bash,edit,write,grep,find,ls \
  --provider dendro \
  --model gpt-5.6-terra \
  --thinking xhigh \
  "$prompt"
