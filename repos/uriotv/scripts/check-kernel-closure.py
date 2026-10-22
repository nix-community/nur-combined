#!/usr/bin/env python3
"""Fail-closed redistributability gate for a kernel store closure."""

import json
import re
import sys
from pathlib import Path

STORE_PATH = re.compile(r"^/nix/store/[0-9abcdfghijklmnpqrsvwxyz]{32}-[A-Za-z0-9+._?=-]+$")


class GateError(Exception):
    pass


def read_json(path):
    try:
        with open(path, encoding="utf-8") as stream:
            return json.load(stream)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise GateError(f"cannot read valid JSON: {path}") from exc


def paths_from_file(path):
    try:
        lines = Path(path).read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeError) as exc:
        raise GateError(f"cannot read path list: {path}") from exc
    if not lines or any(not line.strip() or line != line.strip() for line in lines):
        raise GateError(f"empty or malformed path list: {path}")
    return lines


def validate_path(value):
    if not isinstance(value, str) or not STORE_PATH.fullmatch(value):
        raise GateError("malformed Nix store path")
    return value


def unique_paths(values, label):
    if not isinstance(values, list) or not values:
        raise GateError(f"{label} must be a nonempty list")
    result = [validate_path(value) for value in values]
    if len(set(result)) != len(result):
        raise GateError(f"duplicate paths in {label}")
    return set(result)


def run(manifest_path, closure_path, built_path, expected_path):
    manifest = read_json(manifest_path)
    if not isinstance(manifest, dict) or set(manifest) != {"roots", "entries"}:
        raise GateError("manifest must contain exactly roots and entries")
    roots = unique_paths(manifest["roots"], "manifest roots")
    expected = unique_paths(read_json(expected_path), "expected outputs")
    built = unique_paths(paths_from_file(built_path), "built outputs")
    closure_rows = paths_from_file(closure_path)
    closure = {validate_path(path) for path in closure_rows}
    if len(closure) != len(closure_rows):
        raise GateError("duplicate paths in closure")
    if roots != built or roots != expected:
        raise GateError("manifest roots, built outputs, and expected outputs do not match")
    if not roots <= closure:
        raise GateError("one or more kernel roots are absent from the closure")

    entries = manifest["entries"]
    if not isinstance(entries, list) or not entries:
        raise GateError("manifest entries must be a nonempty list")
    by_path = {}
    for entry in entries:
        if not isinstance(entry, dict) or set(entry) != {"path", "name", "redistributable", "licenses"}:
            raise GateError("malformed manifest entry")
        path = validate_path(entry["path"])
        if path in by_path:
            raise GateError("duplicate manifest entry")
        if not isinstance(entry["name"], str) or not entry["name"].strip():
            raise GateError("manifest entry has empty name")
        if type(entry["redistributable"]) is not bool:
            raise GateError("redistributable must be a boolean")
        licenses = entry["licenses"]
        if not isinstance(licenses, list) or any(not isinstance(item, str) or not item.strip() for item in licenses):
            raise GateError("malformed license labels")
        by_path[path] = entry

    used = closure
    unknown = used - by_path.keys()
    if unknown:
        names = ", ".join(sorted(path.removeprefix("/nix/store/") for path in unknown))
        raise GateError(f"closure contains {len(unknown)} path(s) without metadata: {names}")
    blocked = []
    for path in sorted(used):
        entry = by_path[path]
        if not entry["redistributable"] or not entry["licenses"]:
            blocked.append(entry["name"])
    if blocked:
        raise GateError("closure is not proven redistributable: " + ", ".join(blocked))
    return len(roots), len(used)


def main(argv):
    if len(argv) != 5:
        print("usage: check-kernel-closure.py MANIFEST.json CLOSURE.txt BUILT_OUTPUTS.txt EXPECTED_OUTPUTS.json", file=sys.stderr)
        return 2
    try:
        roots, count = run(*argv[1:])
    except GateError as exc:
        print(f"BLOCKED: {exc}")
        return 1
    print(f"PASS: {roots} kernel output(s); {count} closure path(s) have explicit redistributable metadata and license labels.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
