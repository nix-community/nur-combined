#!/usr/bin/env bash
# Drive the distributed build of every scheduled package output.
#
# The build budgets itself well below the runner's hard 6-hour limit on purpose: hitting that limit *cancels* the job, and cancellation skips every `if: !cancelled()` step after this one, so the Cachix push and reconciliation vanish and the run publishes nothing at all.
# A self-imposed timeout fails only this step, exactly like a failed package would, and the partial results still get published.
#
# --max-silent-time is an independent backstop for a build that wedges while its ssh link stays healthy, which the keepalives in builders/attach cannot see. It sits far above the silent stretch of the slowest single crate, since buildRustCrate prints nothing between "Running env rustc" and the finished crate.
set -euo pipefail

build_systems="$(jq -c '[.[].system] | unique' <<<"${TARGETS}")"

# --print-build-logs streams every crate's output and overruns the job log's size cap: run 31878636580 was cut off at 45 minutes and the following five hours simply were not there. Keep a full copy for the artifact step.
: >"${BUILD_LOG}"

set +e
{
  printf '### Built package outputs\n\n'
  BUILD_SYSTEMS="${build_systems}" timeout --signal=INT --kill-after=5m "${BUILD_TIMEOUT_MINUTES}m" \
    nix build \
    --impure \
    --file ci/outputs.nix \
    --no-link \
    --no-write-lock-file \
    --print-build-logs \
    --print-out-paths \
    --max-jobs 0 \
    --max-silent-time "${MAX_SILENT_SECONDS}" \
    --keep-going \
    2> >(tee -a "${BUILD_LOG}" >&2) |
    tee /tmp/built-outputs.txt |
    while IFS= read -r path; do
      # shellcheck disable=SC2016  # backticks are markdown for the step summary
      printf -- '- `%s`\n' "${path}"
    done
} >>"${GITHUB_STEP_SUMMARY}"
build_status=$?
set -e

if ((build_status == 124 || build_status == 137)); then
  printf '::error::The distributed build exceeded its %s-minute budget; publishing whatever finished.\n' \
    "${BUILD_TIMEOUT_MINUTES}"
fi

# `nix build` prints out-paths only when the whole invocation succeeds, so with --keep-going one failing package would hide every other realised output from the push set. Re-derive them from the local store, and name the ones still missing — otherwise a failure is only findable by reading a six-figure line count of build log.
: >/tmp/built-outputs.txt
: >/tmp/failed-targets.txt
while IFS=$'\t' read -r name out; do
  if nix-store --check-validity "${out}" 2>/dev/null; then
    printf '%s\n' "${out}" >>/tmp/built-outputs.txt
  else
    printf '%s\n' "${name}" >>/tmp/failed-targets.txt
  fi
done < <(jq -r '.[] | [.name, .outputPath] | @tsv' <<<"${TARGETS}" | sort --unique)

if [[ -s /tmp/failed-targets.txt ]]; then
  sort --unique -o /tmp/failed-targets.txt /tmp/failed-targets.txt
  {
    printf '\n### Packages that did not build\n\n'
    while IFS= read -r name; do
      # shellcheck disable=SC2016  # backticks are markdown for the step summary
      printf -- '- `%s`\n' "${name}"
    done </tmp/failed-targets.txt
  } >>"${GITHUB_STEP_SUMMARY}"
  printf '::error::%s package(s) failed: %s\n' \
    "$(wc -l </tmp/failed-targets.txt)" "$(paste -sd' ' - </tmp/failed-targets.txt)"
fi

exit "${build_status}"
