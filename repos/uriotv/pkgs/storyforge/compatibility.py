#!/usr/bin/env python3
"""Bounded, offline Bun compatibility plan. Never resolve or install dependencies."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import tempfile


def _unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"Duplicate JSON key: {key}")
        result[key] = value
    return result


def parse_jsonc(text):
    """Parse JSON with comments/trailing commas, preserving string contents.

    Bun's lock is JSONC, not arbitrary JSON5. Unknown syntax is rejected rather
    than repaired. Duplicate keys are errors, including in generated plans.
    """
    output = []
    i = 0
    quoted = False
    escaped = False
    while i < len(text):
        char = text[i]
        if quoted:
            output.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
            i += 1
        elif char == '"':
            quoted = True
            output.append(char)
            i += 1
        elif text.startswith("//", i):
            end = text.find("\n", i + 2)
            end = len(text) if end < 0 else end
            output.append(" " * (end - i))
            i = end
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end < 0:
                raise ValueError("Unterminated JSONC comment")
            output.extend("\n" if c == "\n" else " " for c in text[i:end + 2])
            i = end + 2
        else:
            output.append(char)
            i += 1
    text = "".join(output)
    output = []
    quoted = escaped = False
    for i, char in enumerate(text):
        if quoted:
            output.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
            output.append(char)
        elif char == ",":
            following = i + 1
            while following < len(text) and text[following].isspace():
                following += 1
            if following == len(text) or text[following] not in "}]":
                output.append(char)
        else:
            output.append(char)
    return json.loads("".join(output), object_pairs_hook=_unique_object)


def make_plan(source_dir):
    source_dir = Path(source_dir)
    lock_bytes = (source_dir / "bun.lock").read_bytes()
    package_bytes = (source_dir / "package.json").read_bytes()
    lock = parse_jsonc(lock_bytes.decode("utf-8"))
    package = json.loads(package_bytes, object_pairs_hook=_unique_object)
    if not isinstance(lock, dict) or not isinstance(package, dict):
        raise ValueError("Expected object manifests")
    version = lock.get("lockfileVersion")
    if type(version) is not int or version not in (1, 2):
        raise ValueError(f"Unsupported Bun lockfileVersion: {version!r}")
    config_version = lock.get("configVersion", 1)
    if type(config_version) is not int or config_version != 1:
        raise ValueError("Unsupported Bun configVersion")
    if not isinstance(lock.get("packages"), dict):
        raise ValueError("Missing Bun package records")
    workspaces = lock.get("workspaces")
    if not isinstance(workspaces, dict):
        raise ValueError("Missing Bun workspaces")
    root = workspaces.get("")
    if not isinstance(root, dict):
        raise ValueError("Missing root lock workspace")
    package_deps, lock_deps = package.get("dependencies", {}), root.get("dependencies", {})
    if not isinstance(package_deps, dict) or not isinstance(lock_deps, dict):
        raise ValueError("Unsupported dependencies schema")
    requested = package_deps.get("better-auth")
    locked = lock_deps.get("better-auth")
    adjustment = None
    if requested != locked:
        if (requested, locked) != ("^1.7.7", "^1.7.6"):
            raise ValueError(f"Unreviewed better-auth mismatch: {requested!r} vs {locked!r}")
        adjustment = {"from": requested, "to": locked}
    return {
        "schemaVersion": 1,
        "inputSha256": {
            "bun.lock": hashlib.sha256(lock_bytes).hexdigest(),
            "package.json": hashlib.sha256(package_bytes).hexdigest(),
        },
        "lockfileVersion": {"from": version, "to": 1},
        "betterAuth": adjustment,
    }


def _replace_file(path, data):
    descriptor, name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            stream.write(data)
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def apply_plan(source_dir, plan, check_only=False):
    source_dir = Path(source_dir)
    # Regenerate the only permitted plan. Equality checks fingerprints, schema
    # and every edit; a changed source or arbitrary patch plan is rejected.
    if plan != make_plan(source_dir):
        raise ValueError("Compatibility plan does not match the source or supported edits")
    if check_only:
        return
    if plan["lockfileVersion"]["from"] != plan["lockfileVersion"]["to"]:
        lock = parse_jsonc((source_dir / "bun.lock").read_text())
        lock["lockfileVersion"] = plan["lockfileVersion"]["to"]
        _replace_file(source_dir / "bun.lock", json.dumps(lock, ensure_ascii=False, indent=2) + "\n")
    if plan["betterAuth"] is not None:
        package = json.loads((source_dir / "package.json").read_text())
        package["dependencies"]["better-auth"] = plan["betterAuth"]["to"]
        _replace_file(source_dir / "package.json", json.dumps(package, ensure_ascii=False, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=Path("."))
    parser.add_argument("--plan", type=Path, required=True)
    parser.add_argument("--check-only", action="store_true")
    args = parser.parse_args()
    plan = json.loads(args.plan.read_text(), object_pairs_hook=_unique_object)
    apply_plan(args.source, plan, args.check_only)


if __name__ == "__main__":
    main()
