#!/usr/bin/env python3
"""sass-spec pass-rate ratchet.

Re-runs the conformance harness against a built `sasso` and fails if the
number of passing cases regresses below the committed baseline. Every feature
that raises the count should bump the baseline file in the same commit.

There are TWO ratchets, one per output style, each with its own baseline:

    expanded    scored against the suite's own output.css (sass-spec ships
                dart-sass's expanded output and nothing else)
    compressed  scored against spec/COMPRESSED_EXPECT.txt, a committed
                manifest of per-case digests of a pinned dart-sass's
                COMPRESSED output. sass-spec has no compressed expectation
                anywhere, so without that manifest a compressed run fails
                nearly every success case on whitespace alone and measures
                nothing. See spec/gen_compressed.py.

Usage:
    cargo build --release
    python3 spec/check_baseline.py                      # expanded
    python3 spec/check_baseline.py --style compressed
    SASS_BIN=/path/to/sasso python3 spec/check_baseline.py
"""
import argparse
import json
import os
import subprocess
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# Per-style ratchet wiring. The expanded entry reproduces the original
# invocation exactly, so its verdict is unchanged by this file gaining a second
# style.
STYLES = {
    "expanded": {
        "baseline": "BASELINE.json",
        "results": "results.json",
        "label": "sass-spec",
    },
    "compressed": {
        "baseline": "BASELINE_COMPRESSED.json",
        "results": "results-compressed.json",
        "label": "compressed",
        "expect": "COMPRESSED_EXPECT.txt",
    },
}


def pinned_spec_commit():
    path = os.path.join(HERE, "SPEC_VERSION.txt")
    if not os.path.exists(path):
        return None
    for line in open(path, encoding="utf-8"):
        if line.startswith("commit:"):
            return line.split(":", 1)[1].strip()
    return None


def check_manifest_is_current(expect_path, baseline, style):
    """A digest manifest is only an oracle for the pins it was generated from.

    Scoring against a manifest built from a different dart-sass, or a different
    sass-spec commit, silently measures the wrong thing — so refuse instead.
    Regenerating is a documented one-liner.

    Every header these checks read is REQUIRED, not merely checked when
    present: a comparison that is skipped because its header is absent is not a
    guard, it is a line an edit can delete to turn the guard off.

    Returns the parsed header on success and None on failure.
    """
    header = {}
    entries = 0
    for line in open(expect_path, encoding="utf-8"):
        if line.startswith("#"):
            body = line[1:].strip()
            if ":" in body:
                k, v = body.split(":", 1)
                if " " not in k:
                    header[k.strip()] = v.strip()
            continue
        if line.strip():
            entries += 1

    want_dart = baseline.get("dart_sass")
    got_dart = header.get("dart_sass")
    want_commit = pinned_spec_commit()
    got_commit = header.get("spec_commit")

    problems = []

    # The style the digests were generated in. Nothing about a digest says
    # which, and run_spec.py refuses a mismatch too — this one just fails
    # before a three-minute run rather than after one.
    got_style = header.get("style")
    if got_style is None:
        problems.append("it has no `style:` header")
    elif got_style != style:
        problems.append(f"{got_style} expectations, but the {style} ratchet "
                        "is scoring them")

    # A missing entry is a SKIP, by design: a manifest gap must not read as a
    # sasso regression. The cost of that choice is that dropping entries also
    # drops cases out of the denominator, so a truncated manifest could hide
    # the very failures it omits. Two things stop that: the header's own count
    # must match the body, and main() refuses a shrunken `attempted`.
    got_cases = header.get("cases")
    if got_cases is None:
        problems.append("it has no `cases:` header")
    elif not got_cases.isdigit():
        problems.append(f"its `cases:` header is not a number ({got_cases!r})")
    elif int(got_cases) != entries:
        problems.append(f"{entries} digest lines but its header says "
                        f"{got_cases} cases")

    if not want_dart:
        problems.append("the baseline records no `dart_sass` to check against")
    elif got_dart is None:
        problems.append("it has no `dart_sass:` header")
    elif want_dart != got_dart:
        problems.append(f"dart-sass {got_dart} in the manifest vs "
                        f"{want_dart} in the baseline")

    if not want_commit:
        problems.append("SPEC_VERSION.txt records no commit to check against")
    elif got_commit is None:
        problems.append("it has no `spec_commit:` header")
    elif want_commit != got_commit:
        problems.append(f"sass-spec {got_commit[:12]} in the manifest vs "
                        f"{want_commit[:12]} in SPEC_VERSION.txt")

    # How many eligible cases the reference itself could not compile, and so
    # legitimately have no digest. main() uses it as the exact allowance for
    # `no-reference-digest` SKIPs; see check_manifest_covers_run().
    got_errors = header.get("reference_errors")
    if got_errors is None:
        problems.append("it has no `reference_errors:` header")
    elif not got_errors.isdigit():
        problems.append("its `reference_errors:` header is not a number "
                        f"({got_errors!r})")
    if problems:
        name = os.path.relpath(expect_path, ROOT)
        print(f"error: {name} is not a usable oracle — "
              + "; ".join(problems), file=sys.stderr)
        print("Regenerate it: python3 spec/gen_compressed.py --jobs 10",
              file=sys.stderr)
        return None
    return header


def check_manifest_covers_run(header, skip_breakdown, expect_path):
    """The manifest must cover every case this run was eligible to score.

    `attempted` not falling is not enough. Because a missing entry is a SKIP,
    growing the scorer's eligible set -- retiring a skip tag, a case that stops
    being an error spec, anything that makes run_spec.py ask about a case the
    manifest predates -- leaves `attempted` exactly where the baseline expects
    it while the new cases are not scored at all in this style.

    run_spec.py counts precisely those cases as `no-reference-digest` SKIPs, and
    the only ones allowed to be missing are the ones the reference compiler
    could not compile, which the manifest records in its own header. So the
    coverage check is an equality, not a heuristic.
    """
    missing = skip_breakdown.get("no-reference-digest", 0)
    allowed = int(header["reference_errors"])
    if missing <= allowed:
        return True
    name = os.path.relpath(expect_path, ROOT)
    print(f"error: {name} does not cover this run — {missing} eligible case(s) "
          f"had no digest, but the manifest records only {allowed} the "
          "reference could not compile.", file=sys.stderr)
    print("Those cases were SKIPped, so nothing about them was scored. This is "
          "what happens when the eligible set grows (a skip tag retired, a case "
          "reclassified): regenerate the manifest and bump the baseline in the "
          "same commit.", file=sys.stderr)
    print("  python3 spec/gen_compressed.py --jobs 10", file=sys.stderr)
    return False


def main() -> int:
    ap = argparse.ArgumentParser(description="sass-spec pass-rate ratchet")
    ap.add_argument("--style", choices=sorted(STYLES), default="expanded",
                    help="which ratchet to run (default: expanded)")
    args = ap.parse_args()
    cfg = STYLES[args.style]

    baseline = json.load(open(os.path.join(HERE, cfg["baseline"])))
    sass_bin = os.environ.get("SASS_BIN", os.path.join(ROOT, "target", "release", "sasso"))
    if not os.path.exists(sass_bin):
        print(f"error: compiler binary not found at {sass_bin} (run `cargo build --release`)", file=sys.stderr)
        return 2
    if not os.path.isdir(os.path.join(HERE, "sass-spec", "spec")):
        print("error: sass-spec not present — run spec/fetch.sh first", file=sys.stderr)
        return 2

    extra = []
    manifest_header = None
    if "expect" in cfg:
        expect = os.path.join(HERE, cfg["expect"])
        if not os.path.exists(expect):
            print(f"error: {expect} not found — generate it with "
                  "`python3 spec/gen_compressed.py`", file=sys.stderr)
            return 2
        manifest_header = check_manifest_is_current(expect, baseline,
                                                    args.style)
        if manifest_header is None:
            return 2
        extra = [f"--style={args.style}", "--expect-file", expect]

    out = os.path.join(HERE, cfg["results"])
    # The harness exits 1 whenever any case fails, which is the normal state of
    # a ratchet run, so its status cannot simply be trusted. But 2 means it
    # never scored anything (bad flags, a style/manifest mismatch, a missing
    # suite) and an earlier run's results file must not be read as this run's.
    if os.path.exists(out):
        os.remove(out)
    env = {**os.environ, "SASS_BIN": sass_bin}
    proc = subprocess.run(
        [sys.executable, os.path.join(HERE, "run_spec.py"), "--quiet", "--out", out] + extra,
        cwd=ROOT, env=env, check=False,
    )
    if proc.returncode not in (0, 1):
        print(f"error: run_spec.py exited {proc.returncode} without scoring "
              "the suite — see its message above", file=sys.stderr)
        return 2
    if not os.path.exists(out):
        print(f"error: run_spec.py wrote no results to {out}", file=sys.stderr)
        return 2
    scored = json.load(open(out))
    cases = scored["cases"]
    if manifest_header is not None:
        skips = scored.get("summary", {}).get("skip_breakdown", {})
        if not check_manifest_covers_run(manifest_header, skips, expect):
            return 2
    c = Counter(x["status"] for x in cases)
    passes, err, fail = c.get("PASS", 0), c.get("ERROR_EXPECTED", 0), c.get("FAIL", 0)
    passing = passes + err
    attempted = passing + fail

    label = cfg["label"]
    print(f"{label:<12}: passing={passing} (pass={passes} error_expected={err}) attempted={attempted}")
    print(f"baseline    : passing={baseline['passing']} (pass={baseline['pass']})")
    delta = passing - baseline["passing"]
    print(f"delta       : {delta:+d} passing")

    want_attempted = baseline.get("attempted")
    if want_attempted is not None and attempted < want_attempted:
        print(f"REGRESSION: {want_attempted - attempted} case(s) left the "
              f"denominator — attempted {attempted} vs {want_attempted} in the "
              f"baseline.", file=sys.stderr)
        print("A case that stops being scored cannot be seen to fail. If the "
              "drop is intended (suite pin moved), bump "
              f"spec/{cfg['baseline']} in the same commit.", file=sys.stderr)
        return 1
    if passing < baseline["passing"] or passes < baseline["pass"]:
        print("REGRESSION: pass count dropped below the committed baseline.", file=sys.stderr)
        return 1
    if delta > 0:
        print(f"NOTE: {delta} new passing case(s) — bump spec/{cfg['baseline']} "
              "in this commit.")
    print("ratchet OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
