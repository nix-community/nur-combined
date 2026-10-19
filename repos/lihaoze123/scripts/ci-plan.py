#!/usr/bin/env python3
"""Turn isolated evaluation results into a package matrix and cache manifest."""

import json
import os
from pathlib import Path
import sys

from cache_metadata import fetch_metadata, read_token


def make_plan(rows, lookup=None):
    jobs, cached, errors, paths = [], [], [], []
    for row in rows:
        attr = row.get("attr", "<evaluation>")
        if "error" in row:
            errors.append({"attr": attr, "error": row["error"]})
            continue
        outputs = list(row.get("outputs", {}).values())
        if not outputs or any(not isinstance(path, str) for path in outputs):
            errors.append({"attr": attr, "error": "Missing concrete output paths"})
            continue
        outputs.sort()
        paths.extend(outputs)
        # A hit in an upstream cache is not a hit in our private cache.
        if lookup and all(lookup(path) is not None for path in outputs):
            cached.append(attr)
        else:
            jobs.append({"attr": attr, "outPaths": outputs, "skip": False})
    return {
        "matrix": {"include": jobs or [{"attr": "__skip_build", "outPaths": [], "skip": True}]},
        "cached": cached,
        "errors": errors,
        "paths": sorted(set(paths)),
    }


def main():
    rows = [json.loads(line) for line in Path(sys.argv[1]).read_text().splitlines() if line.strip()]
    lookup = fetch_metadata if read_token() else None
    plan = make_plan(rows, lookup)
    if int(os.environ.get("EVAL_EXIT_CODE", "0")) and not plan["errors"]:
        plan["errors"].append({"attr": "<evaluation>", "error": "Evaluator exited unsuccessfully; see its log"})
    if not rows:
        plan["errors"].append({"attr": "<evaluation>", "error": "Evaluator produced no package results"})
    Path("ci-plan.json").write_text(json.dumps(plan, indent=2) + "\n")
    Path("ci-paths").write_text("".join(path + "\n" for path in plan["paths"]))
    outputs = os.environ.get("GITHUB_OUTPUT")
    if outputs:
        with open(outputs, "a") as output:
            output.write("matrix=" + json.dumps(plan["matrix"], separators=(",", ":")) + "\n")
            output.write(f"has-errors={str(bool(plan['errors'])).lower()}\n")
    print(json.dumps(plan, indent=2))
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a") as output:
            output.write(f"Private cache hits: {len(plan['cached'])}; packages to build: {sum(not j['skip'] for j in plan['matrix']['include'])}; evaluation errors: {len(plan['errors'])}\n")
            for error in plan["errors"]:
                output.write(f"\n- `{error['attr']}`: {error['error']}\n")


if __name__ == "__main__":
    main()
