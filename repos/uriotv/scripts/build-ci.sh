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
  # Never leave a successful-looking output list after a failed/partial build.
  rm -f "$outfile"
  : > "$work/outputs"
  : > "$work/statuses"
  status=0
  while IFS= read -r name; do
    echo "::group::Build $name"
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
  (( status == 0 )) || { echo 'Build failures prevent publishing.'; exit 1; }
  sort -u "$work/outputs" > "$outfile"
  echo 'All package outputs built; publication is a separate gated step.'
  exit 0
fi

: "${CACHIX_AUTH_TOKEN:?CACHIX_AUTH_TOKEN is required for main-branch publication}"
python3 - "$manifest" "$outfile" > "$work/cacheable" <<'PY'
import json, sys
rows = json.load(open(sys.argv[1], encoding="utf-8"))
built = set(open(sys.argv[2], encoding="utf-8").read().splitlines())
expected = {path for p in rows if p["buildable"] for path in p["outputs"]}
assert built == expected, "Incomplete or unexpected built outputs; refusing publication"
paths = {path for p in rows if p["cacheable"] for path in p["outputs"]}
print("\n".join(sorted(paths)), end="\n" if paths else "")
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
echo 'All redistributable roots published and their StorePath verified.'
