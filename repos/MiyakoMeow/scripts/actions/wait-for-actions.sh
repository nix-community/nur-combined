#!/usr/bin/env bash
set -euo pipefail

# Wait for GitHub Actions checks on the head SHA of a PR to complete.
#
# Usage:
#   wait-for-actions.sh <PR_NUMBER> [PACKAGE]
#
# Environment:
#   GITHUB_REPOSITORY - (required) owner/repo, usually provided by GitHub Actions
#   GITHUB_TOKEN      - (optional) token for `gh` CLI; usually provided by Actions as secrets.GITHUB_TOKEN
#   MAX_WAIT          - (optional) max seconds to wait (default: 1800)
#
# Exit codes:
#   0 - success (all checks completed and none failed)
#   1 - one or more checks failed or script encountered an error while checking runs
#   2 - usage / missing required env
#   3 - timeout waiting for checks to complete

PR_NUMBER="${1:-}"
PACKAGE="${2:-}"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <PR_NUMBER> [PACKAGE]" >&2
  exit 2
fi

# Prefer explicit env, otherwise rely on Actions-provided env
GITHUB_REPO="${GITHUB_REPOSITORY:-}"
if [ -z "$GITHUB_REPO" ]; then
  echo "GITHUB_REPOSITORY is not set. This script must run in GitHub Actions or GITHUB_REPOSITORY must be exported." >&2
  exit 2
fi

# Ensure dependencies exist
if ! command -v gh >/dev/null 2>&1; then
  echo "Required command 'gh' not found in PATH" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Required command 'jq' not found in PATH" >&2
  exit 2
fi

if [ -n "$PACKAGE" ]; then
  echo "等待PR #$PR_NUMBER ($PACKAGE) 的CI完成"
else
  echo "等待 PR #$PR_NUMBER 的 CI 完成"
fi

: "${MAX_WAIT:=1800}"   # default 30 minutes
WAIT_TIME=0
SLEEP_INTERVAL=10

while [ "$WAIT_TIME" -lt "$MAX_WAIT" ]; do
  # Get head SHA of the PR
  if ! HEAD_SHA=$(gh api "repos/${GITHUB_REPO}/pulls/${PR_NUMBER}" --jq '.head.sha' 2>/dev/null); then
    echo "无法获取 PR #${PR_NUMBER} 的 head SHA" >&2
    exit 1
  fi

  # Get check runs for the commit
  if ! CHECK_RUNS=$(gh api "repos/${GITHUB_REPO}/commits/${HEAD_SHA}/check-runs" --jq '.check_runs' 2>/dev/null); then
    echo "无法获取提交 ${HEAD_SHA} 的检查结果" >&2
    exit 1
  fi

  TOTAL_CHECKS=$(echo "$CHECK_RUNS" | jq 'length')
  COMPLETED_CHECKS=$(echo "$CHECK_RUNS" | jq '[.[] | select(.status == "completed")] | length')
  FAILED_CHECKS=$(echo "$CHECK_RUNS" | jq '[.[] | select(.conclusion == "failure" or .conclusion == "cancelled" or .conclusion == "timed_out")] | length')

  echo "检查状态: ${COMPLETED_CHECKS}/${TOTAL_CHECKS} 已完成"

  if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo "发现失败的检查，停止等待"
    FAILED_NAMES=$(echo "$CHECK_RUNS" | jq -r '.[] | select(.conclusion == "failure" or .conclusion == "cancelled" or .conclusion == "timed_out") | .name')
    echo "失败的检查: $FAILED_NAMES"
    exit 1
  fi

  if [ "$TOTAL_CHECKS" -gt 0 ] && [ "$COMPLETED_CHECKS" -eq "$TOTAL_CHECKS" ]; then
    echo "所有 CI 检查已完成"
    exit 0
  fi

  echo "等待 CI 完成... (已等待 ${WAIT_TIME}s)"
  sleep "${SLEEP_INTERVAL}"
  WAIT_TIME=$((WAIT_TIME + SLEEP_INTERVAL))
done

echo "等待 CI 超时 (已等待 ${WAIT_TIME}s，最大 ${MAX_WAIT}s)" >&2
exit 3
