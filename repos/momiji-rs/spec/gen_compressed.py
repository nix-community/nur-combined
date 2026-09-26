#!/usr/bin/env python3
"""
gen_compressed.py — build the compressed-style expectation manifest.

Why this exists
---------------
sass-spec ships exactly one expectation per case and dart-sass generated all of
them in the default `expanded` style. The suite contains no compressed
expectation anywhere, so running `run_spec.py --style=compressed` against
`output.css` fails nearly every success case on whitespace alone — `[measured]`
58 PASS out of 497 non-error cases in the first 600. That is why the
conformance ratchet has only ever scored `expanded`, and why compressed-only
serialization divergences have been invisible to it.

Scoring compressed output therefore needs a second oracle: the compressed CSS a
reference dart-sass emits for the same case. This script produces it. Storing
the CSS itself would be several megabytes, so we store a 12-hex-char sha256 of
the *normalized* output per case — the same normalization the byte-exact
comparison applies — in a line-oriented manifest that diffs one case per line:

    spec/COMPRESSED_EXPECT.txt

That file is COMMITTED. The gate then needs neither node nor the network, which
is the whole point: `python3 spec/check_baseline.py --style compressed` is a
plain offline ratchet like the expanded one. Regenerate it only when the
dart-sass pin or the sass-spec pin moves — the diff is then a readable record
of which compressed outputs upstream changed.

Usage
-----
    # pinned dart-sass via npx (slow: one node start per case)
    python3 spec/gen_compressed.py --jobs 10

    # a locally installed dart-sass of the pinned version (much faster)
    DART_SASS=/path/to/sass-wrapper python3 spec/gen_compressed.py --jobs 10

    # what does dart-sass emit for one case, and what do we emit?
    SASS_BIN=target/release/sasso \\
        python3 spec/gen_compressed.py --show 'spec/css/media:query'

The reference binary must honour the same contract as SASS_BIN:
    <bin> --style=compressed <input-file>   -> CSS on stdout
`spec/dartsass.sh` (npx) is the default and satisfies it.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import run_spec  # noqa: E402  (same directory; shares the case model exactly)

DEFAULT_OUT = HERE / "COMPRESSED_EXPECT.txt"
DEFAULT_DART = HERE / "dartsass.sh"


def reference_version(dart_bin: str) -> str:
    """`<bin> --version` -> the bare version, or 'unknown'."""
    import subprocess
    try:
        out = subprocess.run([dart_bin, "--version"], stdout=subprocess.PIPE,
                             stderr=subprocess.DEVNULL, timeout=120)
        text = out.stdout.decode("utf-8", errors="replace").strip()
    except Exception:
        return "unknown"
    m = re.match(r"(\d+\.\d+\.\d+)", text)
    return m.group(1) if m else (text.splitlines()[0] if text else "unknown")


def pinned_dart_sass() -> str | None:
    """The dart-sass version this repo's oracle is defined against.

    The ratchet refuses a manifest whose `dart_sass` header disagrees with the
    baseline, so generating from an unpinned `npx sass` would produce a
    manifest that is either rejected later or -- worse, if someone bumps the
    baseline to match -- silently redefines the oracle. The pin is read from
    the baselines rather than duplicated here.
    """
    for name in ("BASELINE_COMPRESSED.json", "BASELINE.json"):
        path = HERE / name
        if not path.exists():
            continue
        try:
            version = json.loads(path.read_text(encoding="utf-8")).get(
                "dart_sass")
        except ValueError:
            continue
        if version:
            return str(version)
    return None


def spec_commit() -> str:
    path = HERE / "SPEC_VERSION.txt"
    if not path.exists():
        return "unknown"
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("commit:"):
            return line.split(":", 1)[1].strip()
    return "unknown"


def eligible_cases(suite: Path, filter_: str | None, limit: int | None):
    """The cases a compressed ratchet run will actually score: every case the
    expanded run attempts that is not an error spec. Error specs are excluded
    on purpose — their verdict is the exit status, which is style-independent,
    so they need no reference output and the ratchet scores them as before.

    The skip predicate is `run_spec`'s own, with `run_spec`'s own default tag
    set, so the manifest covers exactly the cases the scorer asks about.
    """
    enabled_tags = set(run_spec.SKIP_TAGS) - {
        "extend", "use", "forward", "indented-syntax"}
    out = []
    for case in run_spec.iter_all_cases(suite, suite):
        if filter_ and filter_ not in case.name:
            continue
        if case.expects_error:
            continue
        if run_spec.decide_skip(case, enabled_tags, run_spec.IMPL):
            continue
        out.append(case)
        if limit is not None and len(out) >= limit:
            break
    return out


def compile_compressed(case, bin_path: str):
    """(name, digest) on success, (name, None) when the reference errored."""
    stdout, rc, _, _ = run_spec.compile_case(case, bin_path, "compressed")
    if rc != 0:
        return case.name, None
    return case.name, run_spec.css_digest(stdout)


def resolve_suite(raw: str) -> Path:
    suite = Path(raw)
    if not suite.is_absolute():
        suite = (Path.cwd() / suite).resolve()
    if (suite / "spec").is_dir() and not any(suite.glob("*.hrx")):
        suite = suite / "spec"
    return suite


def do_show(name: str, suite: Path, dart_bin: str) -> int:
    """Print the reference and (if SASS_BIN is set) our compressed output for
    one case. The manifest holds digests only, so this is how a FAIL from the
    compressed ratchet gets turned back into a diff."""
    matches = [c for c in run_spec.iter_all_cases(suite, suite)
               if c.name == name or name in c.name]
    if not matches:
        print(f"no case matching {name!r}", file=sys.stderr)
        return 2
    for case in matches[:5]:
        print("=" * 70)
        print(case.name)
        ref_out, ref_rc, _, _ = run_spec.compile_case(
            case, dart_bin, "compressed")
        print(f"--- reference ({dart_bin}) rc={ref_rc} "
              f"digest={run_spec.css_digest(ref_out)}")
        print(ref_out.rstrip("\n"))
        ours = os.environ.get("SASS_BIN")
        if ours:
            our_out, our_rc, _, _ = run_spec.compile_case(
                case, ours, "compressed")
            print(f"--- sasso ({ours}) rc={our_rc} "
                  f"digest={run_spec.css_digest(our_out)}")
            print(our_out.rstrip("\n"))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(
        description="generate the compressed-style expectation manifest")
    ap.add_argument("--suite", default=str(run_spec.DEFAULT_SUITE))
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--jobs", type=int, default=8,
                    help="parallel reference compiles (default 8)")
    ap.add_argument("--filter", default=None,
                    help="only cases whose name contains this substring")
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--allow-version-mismatch", action="store_true",
                    help="generate even though the reference compiler is not "
                         "the pinned version (use when deliberately moving "
                         "the pin, and bump the baselines in the same commit)")
    ap.add_argument("--show", default=None, metavar="CASE",
                    help="print the reference compressed CSS for one case "
                         "(and ours, when SASS_BIN is set) instead of "
                         "generating; this is how a digest FAIL is triaged")
    args = ap.parse_args()

    dart_bin = os.environ.get("DART_SASS", str(DEFAULT_DART))
    pin = pinned_dart_sass()
    if pin and "DART_SASS_VERSION" not in os.environ:
        # Read by spec/dartsass.sh, so the default path is `npx sass@<pin>`
        # rather than whatever npx resolves today. A custom DART_SASS that
        # ignores it is caught by the version check below instead.
        os.environ["DART_SASS_VERSION"] = pin
    suite = resolve_suite(args.suite)
    if not suite.exists():
        print(f"ERROR: suite not found: {suite} — run spec/fetch.sh first",
              file=sys.stderr)
        return 2

    if args.show:
        return do_show(args.show, suite, dart_bin)

    version = reference_version(dart_bin)
    commit = spec_commit()
    print(f"reference : {dart_bin}  (dart-sass {version})")
    print(f"suite     : {suite}  (pinned {commit[:12]})")
    if pin and version != pin:
        tag = "WARNING" if args.allow_version_mismatch else "ERROR"
        print(f"{tag}: the reference is dart-sass {version} but this repo's "
              f"oracle is pinned to {pin}.", file=sys.stderr)
        if not args.allow_version_mismatch:
            print("A manifest generated from another version is not the "
                  "oracle the ratchet checks: it would be rejected as stale, "
                  "or -- if the baselines were bumped to match -- it would "
                  "quietly redefine parity. Point DART_SASS at "
                  f"dart-sass {pin}, or pass --allow-version-mismatch and "
                  "bump the baselines in the same commit.", file=sys.stderr)
            return 2
        print("writing the manifest anyway; bump `dart_sass` in both "
              "baselines in the same commit.", file=sys.stderr)

    cases = eligible_cases(suite, args.filter, args.limit)
    print(f"cases     : {len(cases)} non-error, non-skipped")

    digests: dict = {}
    errored = []
    done = 0
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for name, digest in pool.map(
                lambda c: compile_compressed(c, dart_bin), cases):
            done += 1
            if digest is None:
                errored.append(name)
            else:
                digests[name] = digest
            if done % 500 == 0:
                print(f"  {done}/{len(cases)}")

    if errored:
        print(f"note: the reference failed to compile {len(errored)} case(s); "
              f"they get no entry and the ratchet will SKIP them:")
        for n in errored[:20]:
            print(f"  {n}")
        if len(errored) > 20:
            print(f"  ... and {len(errored) - 20} more")

    header = [
        "compressed-style expectation manifest for the sass-spec ratchet.",
        "Generated by spec/gen_compressed.py — do not edit by hand.",
        "Each line: <sha256[:12] of the normalized compressed CSS> <case name>.",
        "The digest is of the REFERENCE compiler's output, so a hit means our",
        "compressed CSS is byte-exact with dart-sass after the same",
        "normalization the expanded ratchet applies.",
        "style: compressed",
        f"dart_sass: {version}",
        f"spec_commit: {commit}",
        f"cases: {len(digests)}",
        f"reference_errors: {len(errored)}",
    ]
    out = Path(args.out)
    run_spec.write_expect_file(out, digests, header)
    print(f"wrote {out}  ({len(digests)} digests, "
          f"{out.stat().st_size / 1024:.0f} KiB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
