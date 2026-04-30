#!/usr/bin/env bash

set -uo pipefail

declare -a ALL_TASKS=()
declare -a NVFETCHER_ARGS=()
declare -A PLANNED_TASKS=()
declare -A EXECUTED_TASKS=()
declare -A SKIPPED_TASKS=()
GO_VENDORHASH_TARGETS=""

init_nvfetcher_args() {
  local -a env_args=()

  if [[ -n "${AUTO_UPDATE_NVFETCHER_ARGS:-}" ]]; then
    read -r -a env_args <<< "${AUTO_UPDATE_NVFETCHER_ARGS}"
    NVFETCHER_ARGS+=("${env_args[@]}")
  fi

  if (( $# > 0 )); then
    NVFETCHER_ARGS+=("$@")
  fi

  if (( ${#NVFETCHER_ARGS[@]} > 0 )); then
    echo "Using extra nvfetcher args: ${NVFETCHER_ARGS[*]}"
  fi
}

load_all_tasks() {
  mapfile -t ALL_TASKS < <(sed -n 's/^\[\(.*\)\]$/\1/p' nvfetcher.toml)
}

tasks_for_filter() {
  local filter="$1"
  local task

  for task in "${ALL_TASKS[@]}"; do
    if [[ "$task" =~ $filter ]]; then
      printf '%s\n' "$task"
    fi
  done
}

mark_filter_tasks() {
  local target_name="$1"
  local filter="$2"
  local mode="$3"
  local matched=0
  local task

  while IFS= read -r task; do
    [[ -z "$task" ]] && continue
    matched=1

    case "$mode" in
      planned)
        PLANNED_TASKS["$task"]=1
        ;;
      executed)
        EXECUTED_TASKS["$task"]=1
        ;;
      skipped)
        SKIPPED_TASKS["$task"]=1
        ;;
      *)
        echo "::error title=nvfetcher invalid state::Unknown mark mode '$mode'"
        return 2
        ;;
    esac
  done < <(tasks_for_filter "$filter")

  if (( ! matched )); then
    echo "::warning title=nvfetcher empty filter::$target_name matched no tasks for filter $filter"
  fi
}

snapshot_task_field() {
  local task="$1"
  local field_selector="${2:-.src}"

  if [[ ! -f _sources/generated.json ]]; then
    echo "__MISSING_GENERATED_JSON__"
    return 0
  fi

  jq -cS --arg task "$task" --arg field_selector "$field_selector" '
    if has($task) then
      .[$task] | if $field_selector == ".src" then .src else . end
    else
      null
    end
  ' _sources/generated.json
}

run_nvfetcher() {
  local filter="$1"

  nix run nixpkgs#nvfetcher -- --keep-going --filter "$filter" "${NVFETCHER_ARGS[@]}"
}

run_nvfetcher_filter() {
  local name="$1"
  local package_list="$2"
  local filter="$3"

  mark_filter_tasks "$name" "$filter" planned
  mark_filter_tasks "$name" "$filter" executed

  echo "Updating [$name]: $package_list"
  if ! run_nvfetcher "$filter"; then
    echo "::warning title=nvfetcher partial failure::$name had update failures; continuing with other groups"
    return 1
  fi

  return 0
}

run_nvfetcher_change_gate() {
  local name="$1"
  local task="$2"
  local filter="$3"
  local field_selector="${4:-.src}"
  local before
  local after

  mark_filter_tasks "$name" "$filter" planned
  mark_filter_tasks "$name" "$filter" executed

  before="$(snapshot_task_field "$task" "$field_selector")"

  echo "Updating [$name]: $task (tracking $field_selector)"
  if ! run_nvfetcher "$filter"; then
    echo "::warning title=nvfetcher partial failure::$name had update failures; skipping dependent groups"
    return 2
  fi

  after="$(snapshot_task_field "$task" "$field_selector")"
  if [[ "$before" != "$after" ]]; then
    return 0
  fi

  return 1
}

mark_skipped_group() {
  local name="$1"
  local filter="$2"

  mark_filter_tasks "$name" "$filter" planned
  mark_filter_tasks "$name" "$filter" skipped
}

warn_unplanned_tasks() {
  local missing=()
  local task

  for task in "${ALL_TASKS[@]}"; do
    if [[ -z "${PLANNED_TASKS[$task]:-}" ]]; then
      missing+=("$task")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    echo "::warning title=nvfetcher uncovered tasks::No update group covers: ${missing[*]}"
  fi
}

print_execution_summary() {
  local skipped=()
  local task

  for task in "${ALL_TASKS[@]}"; do
    if [[ -n "${SKIPPED_TASKS[$task]:-}" ]]; then
      skipped+=("$task")
    fi
  done

  if (( ${#skipped[@]} > 0 )); then
    echo "Skipped nvfetcher tasks due to unchanged prerequisites: ${skipped[*]}"
  fi
}

append_go_vendorhash_target() {
  local target="$1"

  if [[ -z "$GO_VENDORHASH_TARGETS" ]]; then
    GO_VENDORHASH_TARGETS=":${target}:"
    return 0
  fi

  if [[ "$GO_VENDORHASH_TARGETS" != *":${target}:"* ]]; then
    GO_VENDORHASH_TARGETS="${GO_VENDORHASH_TARGETS}${target}:"
  fi
}

run_go_vendorhash_gate() {
  local name="$1"
  local task="$2"
  local filter="$3"
  local status

  run_nvfetcher_change_gate "$name" "$task" "$filter" '.src'
  status="$?"

  case "$status" in
    0)
      append_go_vendorhash_target "$task"
      ;;
    1)
      echo "$name unchanged; go vendor hash update not needed from this task"
      ;;
  esac
}

write_github_outputs() {
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "go_vendorhash_targets=${GO_VENDORHASH_TARGETS}" >> "$GITHUB_OUTPUT"
  fi
}

main() {
  init_nvfetcher_args "$@"
  load_all_tasks

  run_nvfetcher_filter "agent-run" "agent-run" '^(agent-run)$'
  run_nvfetcher_filter "create-tauri-app" "create-tauri-app" '^(create-tauri-app)$'
  run_nvfetcher_filter "dingtalk" "dingtalk-bin-amd64, dingtalk-bin-arm64" '^(dingtalk-bin-amd64|dingtalk-bin-arm64)$'
  run_nvfetcher_filter "claude-code" "claude-code-bin-arm64-linux, claude-code-bin-amd64-linux, claude-code-bin-arm64-darwin, claude-code-bin-amd64-darwin" '^(claude-code-bin-arm64-linux|claude-code-bin-amd64-linux|claude-code-bin-arm64-darwin|claude-code-bin-amd64-darwin)$'

  if run_nvfetcher_change_gate "codex" "codex" '^(codex)$' '.src'; then
    echo "codex changed; updating codex-bin tasks"
    run_nvfetcher_filter "codex-bin" "codex-bin-amd64-linux, codex-bin-arm64-linux, codex-bin-amd64-darwin, codex-bin-arm64-darwin" '^(codex-bin-amd64-linux|codex-bin-arm64-linux|codex-bin-amd64-darwin|codex-bin-arm64-darwin)$'
  else
    case "$?" in
      1)
        echo "codex unchanged; skipping codex-bin tasks"
        mark_skipped_group "codex-bin" '^(codex-bin-amd64-linux|codex-bin-arm64-linux|codex-bin-amd64-darwin|codex-bin-arm64-darwin)$'
        ;;
      2)
        mark_skipped_group "codex-bin" '^(codex-bin-amd64-linux|codex-bin-arm64-linux|codex-bin-amd64-darwin|codex-bin-arm64-darwin)$'
        ;;
    esac
  fi

  run_go_vendorhash_gate "kwok" "kwok" '^(kwok)$'
  run_go_vendorhash_gate "vagrant-vmware-utility" "vagrant-vmware-utility" '^(vagrant-vmware-utility)$'

  warn_unplanned_tasks
  print_execution_summary
  write_github_outputs
}

main "$@"
