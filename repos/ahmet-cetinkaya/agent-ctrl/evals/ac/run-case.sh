#!/usr/bin/env bash
# Run one ac command eval case (its prompt.txt) against one sandboxed Claude home.
# Usage: run-case.sh <claude-home> <out-dir> <case> <repetition>
set -euo pipefail
readonly EVAL_DIR=$(cd "$(dirname "$0")" && pwd)
readonly RUN_TIMEOUT=2700
claude_home=$1 out_dir=$2 case_name=$3 repetition=$4
run_dir="$out_dir/$case_name-$repetition"

rm -rf "$run_dir" && mkdir -p "$run_dir/repo"
cp -r "$EVAL_DIR/project/." "$run_dir/repo/"
[ -d "$EVAL_DIR/cases/$case_name/overlay" ] && cp -r "$EVAL_DIR/cases/$case_name/overlay/." "$run_dir/repo/"
# Plans live outside .agents/ in the catalog so the repository's .agents ignore rule cannot drop them.
if [ -d "$EVAL_DIR/cases/$case_name/work" ]; then
  mkdir -p "$run_dir/repo/.agents/work" && cp -r "$EVAL_DIR/cases/$case_name/work/." "$run_dir/repo/.agents/work/"
fi
printf '.agents/\n__pycache__/\n' > "$run_dir/repo/.gitignore"
git -C "$run_dir/repo" init -q
git -C "$run_dir/repo" add -A
git -C "$run_dir/repo" -c user.name=eval -c user.email=eval@localhost commit -qm "seed"

# Run one headless session in the case repository; stdout becomes the given transcript.
run_claude() {
  local prompt=$1 transcript=$2
  HOME=$claude_home timeout "$RUN_TIMEOUT" claude -p "$prompt" \
    --agent lead --model opus --output-format stream-json --verbose \
    --permission-mode acceptEdits --strict-mcp-config --settings '{"disableAllHooks": true}' \
    --allowedTools "Bash(python3:*)" "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" \
    "Bash(ls:*)" "Bash(mkdir:*)" "Bash(date:*)" "Bash(sha256sum:*)" "Bash(cat:*)" "Bash(grep:*)" \
    > "$transcript" 2>> "$run_dir/stderr.log" || echo "exit $? ($(basename "$transcript"))" >> "$run_dir/exit-status"
}

cd "$run_dir/repo"
started_at=$(date +%s)
run_claude "$(cat "$EVAL_DIR/cases/$case_name/prompt.txt")" "$run_dir/transcript.jsonl"
# Plan cases: stand in for the user's approval, then execute the plan with the current /ac:run.
if [ -f "$EVAL_DIR/cases/$case_name/then-run" ]; then
  for plan in .agents/work/*/plan.md; do
    [ -f "$plan" ] && sed -i 's/^status: draft$/status: approved/' "$plan"
  done
  run_claude "/ac:run" "$run_dir/transcript-run.jsonl"
fi
echo $(($(date +%s) - started_at)) > "$run_dir/wall-seconds"
