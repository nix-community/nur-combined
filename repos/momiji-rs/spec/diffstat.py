#!/usr/bin/env python3
"""Per-case diff-size triage for output-mismatch FAILs.

Recompiles every "output mismatch" case from a results.json and measures the
unified-diff size (changed lines) against the expected CSS, surfacing the most
contained byte-diff wins first.

Usage:
    cargo build --release
    python3 spec/diffstat.py [results.json] [--out diffsizes.json] [--top N]

Defaults: results.json = spec/results.json (the last run_spec.py output),
SASS_BIN = target/release/sasso.
"""
import argparse
import difflib
import json
import os
import sys
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))

import run_spec as rs  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("results", nargs="?", default=str(HERE / "results.json"),
                    help="results.json from run_spec.py (default: spec/results.json)")
    ap.add_argument("--out", default=None,
                    help="write the full [{size,name,diff}] list as JSON here")
    ap.add_argument("--top", type=int, default=45,
                    help="how many smallest diffs to print (default 45)")
    ap.add_argument("--filter", default=None,
                    help="only measure cases whose name contains this substring")
    args = ap.parse_args()

    sass_bin = os.environ.get("SASS_BIN", str(ROOT / "target" / "release" / "sasso"))
    results = json.load(open(args.results))["cases"]
    mism = {c["name"] for c in results
            if c["status"] == "FAIL" and "output mismatch" in (c.get("reason") or "")}
    if args.filter:
        mism = {n for n in mism if args.filter in n}

    suite_scan = (HERE / "sass-spec" / "spec").resolve()
    all_cases = {c.name: c for c in rs.iter_all_cases(suite_scan, suite_scan)}

    rows = []
    for name in sorted(mism):
        case = all_cases.get(name)
        if case is None or case.expected_css is None:
            continue
        out, rc, _, _ = rs.compile_case(case, sass_bin, "expanded")
        if rc != 0:
            continue
        diff = [l for l in difflib.unified_diff(
                    case.expected_css.splitlines(), out.splitlines(), lineterm="", n=0)
                if l and l[0] in "+-" and not l.startswith(("+++", "---"))]
        rows.append({"size": len(diff), "name": name, "diff": diff})

    rows.sort(key=lambda r: r["size"])
    print(f"measured {len(rows)} compilable output-mismatch fails\n")
    hist = Counter(r["size"] for r in rows)
    print("diff-size histogram (changed lines):",
          dict(sorted(hist.items())[:15]))
    print(f"\n=== smallest {args.top} ===")
    for r in rows[:args.top]:
        print(f"\n--- [{r['size']}] {r['name']}")
        for l in r["diff"][:6]:
            print("   ", l)

    if args.out:
        json.dump(rows, open(args.out, "w"))
        print(f"\nfull list -> {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
