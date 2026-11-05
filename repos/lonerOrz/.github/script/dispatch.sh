#!/usr/bin/env bash
# Compare two JSON fingerprints and dispatch one build job
# containing all changed packages.

# Usage:
#   ./dispatch.sh --base <old.json> --head <new.json> [options]
#
# Required:
#   --base           Baseline fingerprint
#   --head           Current fingerprint
#
# Optional:
#   --repo           Target repository (default: lonerOrz/loneros-nur)
#   --pr             Pull request number
#   --dry-run        Print payload without dispatching
#   --ref            Workflow branch (default: main)
#
# Environment:
#   GH_TOKEN         GitHub token (or GITHUB_TOKEN)

set -euo pipefail

BASE_FILE=""
HEAD_FILE=""
REPO="lonerOrz/loneros-nur"
PR=""
WORKFLOW_REPO="lonerOrz/nixpkgs-review-gha"
WORKFLOW_FILE="build-pr.yml"
REF="main"
DRY_RUN=0

usage() {
  cat <<EOF
Usage: $0 --base <old.json> --head <new.json> [options]

Required:
  --base           Path to baseline JSON
  --head           Path to current JSON

Optional:
  --repo           Target repository (default: $REPO)
  --pr             Pull request number (required)
  --dry-run        Print payload without dispatching
  --ref            Workflow branch (default: $REF)

Environment:
  GH_TOKEN         GitHub token (or GITHUB_TOKEN)
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --base)
    [[ $# -ge 2 ]] || usage
    BASE_FILE="$2"
    shift 2
    ;;
  --head)
    [[ $# -ge 2 ]] || usage
    HEAD_FILE="$2"
    shift 2
    ;;
  --repo)
    [[ $# -ge 2 ]] || usage
    REPO="$2"
    shift 2
    ;;
  --pr)
    [[ $# -ge 2 ]] || usage
    PR="$2"
    shift 2
    ;;
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  --ref)
    [[ $# -ge 2 ]] || usage
    REF="$2"
    shift 2
    ;;
  *)
    usage
    ;;
  esac
done

# Validate inputs.

[[ -n "$BASE_FILE" && -n "$HEAD_FILE" ]] || usage
[[ -n "$PR" ]] || {
  echo "Error: --pr is required" >&2
  exit 1
}

AUTH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

if [[ "$DRY_RUN" -eq 0 && -z "$AUTH_TOKEN" ]]; then
  echo "Error: GH_TOKEN or GITHUB_TOKEN is required" >&2
  exit 1
fi

if [[ ! -f "$BASE_FILE" || ! -f "$HEAD_FILE" ]]; then
  echo "Error: Input files not found" >&2
  exit 1
fi

# 1. Calculate diff and deduplicate packages.
#
# Fingerprint formats:
#   Old: { package: drvPath }
#   New: { package: { system: drvPath } }
#
# A package is changed when:
#   - It is new in HEAD.
#   - Its drvPath differs on a system present in both fingerprints.
#   - HEAD introduces a new build system for the package.
#
# Packages sharing identical drvPaths in HEAD are dispatched only once.

NORMALIZE='
  if type == "object"
  then with_entries(
    if (.value | type) == "string"
    then {
      key: .key,
      value: { "x86_64-linux": .value }
    }
    else .
    end
  )
  else .
  end
'

CHANGED_PKGS_RAW=$(
  jq -r -n \
    --slurpfile base "$BASE_FILE" \
    --slurpfile head "$HEAD_FILE" \
    '
    ($base[0] | '"$NORMALIZE"') as $b |
    ($head[0] | '"$NORMALIZE"') as $h |
    ($h | keys) |
    map(
      . as $p |
      select(
        # New package.
        (($b[$p] // null) == null)

        or

        # Changed drvPath on an existing system.
        (
          ($h[$p] | to_entries
            | map(select(.key as $s | $b[$p][$s] != null))
            | map(.value != $b[$p][.key])
          ) | any
        )

        or

        # New build system.
        (
          ($h[$p] | to_entries | map(.key)) as $hs |
          ($b[$p]? | keys // []) as $bs |
          ($hs - $bs) != []
        )
      )
    )
    | sort
    | unique
    | group_by(
        . as $p |
        $h[$p] | to_entries | map(.value) | sort | join(",")
      )
    | map(.[0])
    | .[]
    '
)

if [[ -z "$CHANGED_PKGS_RAW" ]]; then
  echo "No changes detected."
  exit 0
fi

mapfile -t CHANGED_PKGS <<<"$CHANGED_PKGS_RAW"

# 2. Filter packages.

EXCLUDES=(
  '_v(2|3|4)$'
  '^firefox'
  '^linux(_|$)'
)

should_build() {
  local pkg="$1"
  local pattern

  for pattern in "${EXCLUDES[@]}"; do
    if [[ "$pkg" =~ $pattern ]]; then
      return 1
    fi
  done

  return 0
}

VALID_PKGS=()

for pkg in "${CHANGED_PKGS[@]}"; do
  if should_build "$pkg"; then
    VALID_PKGS+=("$pkg")
  else
    echo "Skip $pkg"
  fi
done

if [[ ${#VALID_PKGS[@]} -eq 0 ]]; then
  echo "No packages to dispatch after filtering."
  exit 0
fi

echo "Packages to dispatch:"
printf '  %s\n' "${VALID_PKGS[@]}"
echo

# 3. Build dispatch payload.

echo "Dispatching: ${VALID_PKGS[*]}"

DISPATCH_URL="https://api.github.com/repos/${WORKFLOW_REPO}/actions/workflows/${WORKFLOW_FILE}/dispatches"
PACKAGES_CSV=$(
  IFS=','
  echo "${VALID_PKGS[*]}"
)

payload=$(
  jq -n \
    --arg repo "$REPO" \
    --arg pr "$PR" \
    --arg pkgs "$PACKAGES_CSV" \
    --arg ref "$REF" \
    --slurpfile head "$HEAD_FILE" \
    '
    # Collect systems declared by the HEAD fingerprint.
    (reduce $head[0][] as $pkg ({}; . + $pkg) | keys) as $systems |

    ($systems | map(select(test("darwin$")))) as $darwin |
    ($systems - $darwin) as $linux |

    # Explicitly set all supported system inputs.
    (
      [
        "x86_64-linux",
        "aarch64-linux",
        "x86_64-darwin",
        "aarch64-darwin"
      ]
      | map(
          . as $s |
          {
            key: $s,
            val: (
              if ($linux | index($s)) != null then "true"
              elif ($darwin | index($s)) != null then
                "yes_sandbox_relaxed"
              else
                "no"
              end
            )
          }
        )
      | map({ (.key): .val })
      | add
    ) as $sysInputs |

    {
      ref: $ref,
      inputs: (
        {
          repo: $repo,
          "pr-number": $pr,
          packages: $pkgs,
          "pr-comment": "true",
          "telegram-notification": "true",
          "upload-cachix": "true"
        }
        + $sysInputs
      )
    }
    '
)

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "$payload" | jq .
  exit 0
fi

# 4. Dispatch with retries.

RESPONSE=$(mktemp)

cleanup() {
  rm -f "$RESPONSE"
}

trap cleanup EXIT

for attempt in 1 2 3; do
  status=$(
    curl -s \
      -o "$RESPONSE" \
      -w "%{http_code}" \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $AUTH_TOKEN" \
      -H "Content-Type: application/json" \
      "$DISPATCH_URL" \
      -d "$payload"
  )

  if [[ "$status" -eq 204 ]]; then
    echo "Dispatched ${#VALID_PKGS[@]} package(s) successfully."
    exit 0
  fi

  echo "Dispatch failed (HTTP $status), attempt $attempt." >&2
  cat "$RESPONSE" >&2

  if [[ "$attempt" -lt 3 ]]; then
    sleep $((attempt * 2))
  fi
done

echo "All dispatch retries exhausted." >&2
exit 1
