#!/usr/bin/env python3
"""Per-case before/after comparison of two run_spec.py results files.

The zero-regression gate used by every feature commit: a net +N passing delta
can still hide per-case regressions, so this lists exactly which cases flipped
in each direction.

Usage:
    python3 spec/regress.py BEFORE.json AFTER.json

Exit code 1 if any regression (was passing, now not), else 0.
"""
import json
import sys
from collections import Counter

OK = {"PASS", "ERROR_EXPECTED"}


def load(path: str) -> dict:
    return {c["name"]: c["status"] for c in json.load(open(path))["cases"]}


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    before, after = load(sys.argv[1]), load(sys.argv[2])

    ac = Counter(after.values())
    p, e, f = ac.get("PASS", 0), ac.get("ERROR_EXPECTED", 0), ac.get("FAIL", 0)
    print(f"AFTER passing={p + e} pass={p} err={e} fail={f}")

    regress = sorted(n for n in before if before[n] in OK and after.get(n) not in OK)
    gained = sorted(n for n in after if after[n] in OK and before.get(n) not in OK)

    print(f"REGRESSIONS: {len(regress)}")
    for n in regress:
        print(f"  - {n} {before[n]} -> {after.get(n)}")
    print(f"GAINED: {len(gained)}")
    for n in gained:
        print(f"  + {n}")
    return 1 if regress else 0


if __name__ == "__main__":
    sys.exit(main())
