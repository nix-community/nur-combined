#!/usr/bin/env bash
# Builds every supported package. Publication is a separate, main-only operation.
set -euo pipefail

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
manifest=${CI_MANIFEST_PATH:-$work/manifest.json}
outfile=${CI_BUILT_OUTPUTS_FILE:-${RUNNER_TEMP:-/tmp}/ci-built-outputs.txt}
publish=${CI_PUBLISH_ONLY:-false}

if [[ "$publish" == true ]]; then
  trusted_event=false
  if [[ "${GITHUB_EVENT_NAME:-}" =~ ^(push|workflow_dispatch|schedule)$ ]] ||
     [[ "${GITHUB_EVENT_NAME:-}" == workflow_run && "${CI_TRUSTED_UPDATE_COMPLETION:-false}" == true ]]; then
    trusted_event=true
  fi
  if [[ "${GITHUB_REF:-}" != refs/heads/main || "$trusted_event" != true ]]; then
    echo 'Read-only CI: no cache publication for this event/ref'
    exit 0
  fi
fi
if [[ -z "${CI_MANIFEST_PATH:-}" ]]; then
  nix eval --json --no-write-lock-file .#ci.x86_64-linux.manifest > "$manifest"
fi

# Reject incomplete/malformed manifests rather than silently succeeding with no
# builds. Names are quoted in the installable; they are never executed as shell.
python3 - "$manifest" > "$work/buildable" <<'PY'
import json, re, sys
rows = json.load(open(sys.argv[1], encoding="utf-8"))
assert isinstance(rows, list) and rows, "Empty or invalid CI manifest"
seen = set()
for p in rows:
    name = p["name"]
    assert re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._+-]*", name), f"Invalid package name: {name!r}"
    assert name not in seen, f"Duplicate package: {name}"
    seen.add(name)
    assert isinstance(p["buildable"], bool) and isinstance(p["cacheable"], bool), name
    assert not p["cacheable"] or p["buildable"], name
    assert isinstance(p["outputs"], list), name
    if p["buildable"]:
        assert p["outputs"], f"No outputs for {name}"
        for path in p["outputs"]:
            assert re.fullmatch(r"/nix/store/[a-z0-9]{32}-[^/\s]+", path), f"Invalid store path: {path!r}"
        print(name)
assert any(p["buildable"] for p in rows), "No buildable packages"
PY

if [[ "$publish" != true ]]; then
  # The output list is a record of what actually built: it holds the outputs of
  # every package that passed and nothing else. Publish mode compares it with the
  # manifest, so a partial build can never look complete.
  rm -f "$outfile"
  : > "$work/outputs"
  : > "$work/statuses"
  status=0
  while IFS= read -r name; do
    echo "::group::Build $name"
    # Fail in seconds, not after the job timeout, when the plan would bootstrap
    # a compiler/SDK from source. Dry-run errors fall through to the real build.
    if [[ "${CI_ALLOW_HEAVY_BUILDS:-false}" != true ]] &&
       nix build --dry-run --no-link --no-write-lock-file \
         ".#packages.x86_64-linux.\"${name}\"^*" 2> "$work/plan" > /dev/null; then
      plan_status=0
      python3 "$(dirname "${BASH_SOURCE[0]}")/check-build-plan.py" < "$work/plan" > "$work/heavy" || plan_status=$?
      if (( plan_status != 0 )); then
        if (( plan_status == 3 )); then
          echo "::error::$name would compile a toolchain from source (not in the binary cache):"
        else
          echo "::error::Build plan check crashed for $name"
        fi
        cat "$work/heavy"
        echo 'Use a binary toolchain variant (e.g. dotnetCorePackages.sdk_*-bin) or set CI_ALLOW_HEAVY_BUILDS.'
        printf '%s\tfailed\n' "$name" >> "$work/statuses"
        status=1
        echo '::endgroup::'
        continue
      fi
    fi
    # Keep stderr separate: progress/warnings must not corrupt the JSON response.
    if nix build --print-build-logs --no-link --no-write-lock-file --json \
      ".#packages.x86_64-linux.\"${name}\"^*" > "$work/build.json"; then
      if python3 - "$manifest" "$name" "$work/build.json" > "$work/package-outputs" <<'PY'
import json, sys
manifest = json.load(open(sys.argv[1], encoding="utf-8"))
expected = next(p["outputs"] for p in manifest if p["name"] == sys.argv[2])
result = json.load(open(sys.argv[3], encoding="utf-8"))
actual = set()
for drv in result:
    for output in drv["outputs"].values():
        # Nix versions expose outputs either as paths or as objects with `path`.
        actual.add(output if isinstance(output, str) else output["path"])
assert actual == set(expected), f"Unexpected outputs for {sys.argv[2]}: {actual} != {set(expected)}"
print("\n".join(sorted(actual)))
PY
      then
        cat "$work/package-outputs" >> "$work/outputs"
        printf '%s\tpassed\n' "$name" >> "$work/statuses"
      else
        echo "::error::Invalid build output for $name"
        printf '%s\tfailed\n' "$name" >> "$work/statuses"
        status=1
      fi
    else
      echo "::error::Build failed: $name"
      printf '%s\tfailed\n' "$name" >> "$work/statuses"
      status=1
    fi
    echo '::endgroup::'
  done < "$work/buildable"

  python3 - "$manifest" "$work/statuses" <<'PY' > "$work/summary"
import json, sys
status = dict(line.rstrip().split("\t") for line in open(sys.argv[2], encoding="utf-8"))
print("## Package build and cache policy\n\n| Package | Build | Public cache | Reason |\n|---|---|---|---|")
for p in json.load(open(sys.argv[1], encoding="utf-8")):
    print(f"| {p['name']} | {status.get(p['name'], 'skipped')} | {'yes' if p['cacheable'] else 'no'} | {p['reason']} |")
PY
  cat "$work/summary"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then cat "$work/summary" >> "$GITHUB_STEP_SUMMARY"; fi
  sort -u "$work/outputs" > "$outfile"
  if (( status != 0 )); then
    # A failing package must not hide the outputs that did build; the publication
    # step decides per package whether those may be pushed. The job still fails so
    # the breakage stays visible and PRs stay blocked.
    echo "$(wc -l < "$outfile") outputs built; some packages failed."
    echo 'Publication is a separate gated step; successful packages may still publish.'
    exit 1
  fi
  echo 'All package outputs built; publication is a separate gated step.'
  exit 0
fi

: "${CACHIX_AUTH_TOKEN:?CACHIX_AUTH_TOKEN is required for main-branch publication}"

# Publication granularity follows the shape of the revision. `flake.lock`/`flake.nix`
# are shared by every package: moving them invalidates every output, so that
# revision is published all-or-nothing (an unknown state is treated the same way).
# A package-only revision publishes exactly the packages that built; the cache
# branch still advances only for a commit whose whole build succeeded.
shared_inputs=${CI_SHARED_INPUTS_CHANGED:-unknown}
case "$shared_inputs" in
  true | false | unknown) ;;
  *) echo "::error::CI_SHARED_INPUTS_CHANGED must be true, false or unknown (got '$shared_inputs')"; exit 1 ;;
esac

python3 - "$manifest" "$outfile" "$shared_inputs" "$work" <<'PY'
import json, os, sys

def fail(message):
    print(f"::error::{message}", file=sys.stderr)
    sys.exit(1)

try:
    rows = json.load(open(sys.argv[1], encoding="utf-8"))
except (OSError, ValueError) as error:
    fail(f"Cannot read the CI manifest ({error}); refusing publication")
try:
    built = {line for line in open(sys.argv[2], encoding="utf-8").read().splitlines() if line}
except FileNotFoundError:
    built = set()
shared_inputs, work = sys.argv[3], sys.argv[4]
expected = {path for p in rows if p["buildable"] for path in p["outputs"]}
unexpected = built - expected
if unexpected:
    fail(f"Unexpected built outputs: {sorted(unexpected)}")
missing = expected - built
complete = not missing

if shared_inputs != "false" and not complete:
    names = ", ".join(p["name"] for p in rows
                     if p["buildable"] and missing.intersection(p["outputs"]))
    print(f"Refusing publication: shared flake inputs changed ({shared_inputs}) and only "
          f"{len(built)} of {len(expected)} outputs were built (missing: {names}).", file=sys.stderr)
    sys.exit(3)

publishable = {p for p in rows if p["cacheable"] for p in p["outputs"]}
paths = sorted(built & publishable)
with open(os.path.join(work, "cacheable"), "w", encoding="utf-8") as f:
    f.write("\n".join(paths) + ("\n" if paths else ""))
with open(os.path.join(work, "decision"), "w", encoding="utf-8") as f:
    f.write("complete\n" if complete else "partial\n")
if not complete:
    names = ", ".join(p["name"] for p in rows
                     if p["buildable"] and missing.intersection(p["outputs"]))
    print(f"::warning::Partial publication: {len(paths)} cacheable outputs of a package-only "
          f"revision; not built: {names}. The cache branch keeps the last complete commit.",
          file=sys.stderr)
PY
if [[ -s "$work/cacheable" ]]; then
  cachix push uriotv < "$work/cacheable"
  while IFS= read -r path; do
    hash=${path#/nix/store/}
    hash=${hash%%-*}
    curl --fail --silent --show-error --retry 5 --retry-all-errors \
      "https://uriotv.cachix.org/${hash}.narinfo" > "$work/output.narinfo"
    grep -Fx "StorePath: $path" "$work/output.narinfo"
  done < "$work/cacheable"
fi
# Publishing is best effort for the packages that built, but the publication status
# stays a failure until the whole revision builds: the cache branch is a promise
# that every eligible output of that commit is available.
if [[ "$(cat "$work/decision")" != complete ]]; then
  echo '::error::Publication incomplete; the cache branch stays on the last complete commit.'
  exit 1
fi
echo 'All redistributable roots published and their StorePath verified.'
