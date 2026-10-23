import json
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path
from typing import cast

ROOT = Path(__file__).resolve().parents[2]
FOLDER = Path(__file__).resolve().parent
NAMES = {"fastapi", "fastapi-redis-sdk", "fastmcp", "fastmcp-slim", "litellm", "mcp", "mcp-types"}


def dependency_manifest(content: str) -> dict[str, dict[str, str]]:
    lock = tomllib.loads(content)
    packages = cast(list[dict[str, object]], lock["package"])
    result: dict[str, dict[str, str]] = {}
    for package in packages:
        name = str(package["name"])
        if name not in NAMES:
            continue
        if name in result:
            raise ValueError("Multiple locked versions for " + name)
        wheels = cast(list[dict[str, object]], package.get("wheels", []))
        candidates = [
            wheel for wheel in wheels
            if str(wheel["url"]).endswith("-py3-none-any.whl")
        ]
        if len(candidates) != 1:
            raise ValueError("Expected one portable wheel for " + name)
        wheel = candidates[0]
        url = str(wheel["url"])
        digest = str(wheel["hash"])
        if not url.startswith("https://files.pythonhosted.org/packages/"):
            raise ValueError("Unexpected wheel host for " + name)
        if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
            raise ValueError("Invalid wheel checksum for " + name)
        result[name] = {
            "version": str(package["version"]),
            "url": url,
            "hash": digest.removeprefix("sha256:"),
        }
    if result.keys() != NAMES:
        raise ValueError("Missing locked dependencies: " + str(NAMES - result.keys()))
    if result["fastmcp"]["version"] != result["fastmcp-slim"]["version"]:
        raise ValueError("FastMCP packages must have matching versions")
    if result["mcp"]["version"] != result["mcp-types"]["version"]:
        raise ValueError("MCP packages must have matching versions")
    return dict(sorted(result.items()))


def main() -> None:
    paths = [FOLDER / "default.nix", FOLDER / "dependencies.json"]
    saved = {path: path.read_bytes() for path in paths}
    detecting = os.environ.get("NUR_DETECT_VERSION") == "1"
    command = ["nix-update", "-f", ".", "basic-memory", "--use-github-releases"]
    if target := os.environ.get("NUR_TARGET_VERSION"):
        command.append("--version=" + target)
    command.extend(sys.argv[1:])
    if detecting:
        command.extend(["--no-src", "--src-only"])
    try:
        _ = subprocess.run(command, cwd=ROOT, check=True)
        if detecting:
            return
        source = subprocess.check_output(
            ["nix-build", "-A", "basic-memory.src", "--no-out-link"],
            cwd=ROOT, text=True,
        ).strip()
        manifest = dependency_manifest((Path(source) / "uv.lock").read_text())
        _ = paths[1].write_text(json.dumps(manifest, indent=2) + "\n")
    except BaseException:
        for path, content in saved.items():
            _ = path.write_bytes(content)
        raise


if __name__ == "__main__":
    main()
