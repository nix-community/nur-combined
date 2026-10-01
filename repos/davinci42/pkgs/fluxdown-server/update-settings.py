import argparse
import difflib
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import cast

SOURCES = ["native/protocol/src/daemon_config.rs", "native/protocol/src/rpc.rs"]


def parse_fields(source: str) -> dict[str, dict[str, object]]:
    source = re.sub(r"//[^\n]*", "", source)
    enums = {
        name: cast(list[str], json.loads("[" + values + "]"))
        for name, values in (
            (match.group(1), match.group(2))
            for match in re.finditer(
                r"pub const (\w+): &\[&str\] = &\[([^\]]*)\];", source
            )
        )
    }
    catalog = (
        source.split("pub const DAEMON_CONFIG_FIELDS:", 1)[1]
        .split("= &[", 1)[1]
        .split("];", 1)[0]
    )
    pattern = re.compile(
        r'\s*field\(\s*("[^"\\]*")\s*,\s*DaemonConfigKind::'
        + r"(Bool|Integer|Float|Enum|Text|ReadOnly)\s*"
        + r'(\{[^}]*\}|\([^)]*\))?\s*,\s*("[^"\\]*")\s*,?\s*\)\s*,?'
    )
    fields: dict[str, dict[str, object]] = {}
    while catalog.strip():
        match = pattern.match(catalog)
        if match is None:
            raise ValueError("Unrecognized upstream configuration syntax")
        key, kind, constraints, default = (match.group(index) for index in range(1, 5))
        key = cast(str, json.loads(key))
        if key in fields:
            raise ValueError("Duplicate upstream key: " + key)
        field: dict[str, object] = {
            "kind": kind,
            "default": cast(str, json.loads(default)),
        }
        if kind in ("Integer", "Float"):
            for part in constraints.strip("{} ").split(","):
                if part.strip():
                    name, value = part.strip().split(":", 1)
                    value = value.strip().replace("_", "")
                    field[name] = (
                        9223372036854775807
                        if value == "i64::MAX"
                        else cast(int | float, json.loads(value))
                    )
        elif kind == "Enum":
            field["values"] = enums[constraints.strip("() ")]
        fields[key] = field
        catalog = catalog[match.end() :]
    if not fields:
        raise ValueError("Empty upstream configuration catalog")
    return fields


def generate(ref: str) -> dict[str, object]:
    sources = {
        path: subprocess.check_output(
            [
                "gh",
                "api",
                f"repos/zerx-lab/FluxDown/contents/{path}?ref={ref}",
                "-H",
                "Accept: application/vnd.github.raw+json",
            ],
            text=True,
        )
        for path in SOURCES
    }
    protocol = re.search(
        r"pub const PROTOCOL_VERSION: u32 = (\d+);", sources[SOURCES[1]]
    )
    if protocol is None:
        raise ValueError("Cannot determine upstream RPC protocol version")
    return {
        "version": ref.removeprefix("v"),
        "protocolVersion": int(protocol.group(1)),
        "sourceHashes": {
            path: hashlib.sha256(text.encode()).hexdigest()
            for path, text in sources.items()
        },
        "fields": parse_fields(sources[SOURCES[0]]),
    }


class Arguments(argparse.Namespace):
    ref: str | None = None
    check: bool = False


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate or check the pinned FluxDown daemon configuration contract"
    )
    _ = parser.add_argument(
        "--ref", help="Upstream tag or revision; defaults to the package version"
    )
    _ = parser.add_argument(
        "--check",
        action="store_true",
        help="Fail on upstream contract drift without modifying files",
    )
    args = parser.parse_args(namespace=Arguments())
    folder = Path(__file__).resolve().parent
    match = re.search(r'version = "([^"]+)";', (folder / "default.nix").read_text())
    if match is None:
        raise ValueError("Cannot determine package version")
    version = match.group(1)
    content = (
        json.dumps(generate(args.ref or "v" + version), indent=2, sort_keys=True) + "\n"
    )
    target = folder / "settings-schema.json"
    if args.check:
        previous = target.read_text()
        if previous != content:
            _ = sys.stdout.writelines(
                difflib.unified_diff(
                    previous.splitlines(True),
                    content.splitlines(True),
                    fromfile="recorded",
                    tofile="upstream",
                )
            )
            return 1
        print("Upstream daemon configuration contract matches")
    else:
        _ = target.write_text(content)
    return 0


if __name__ == "__main__":
    sys.exit(main())
