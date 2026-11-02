#!/usr/bin/env python3
import os
from pathlib import Path
import re
import subprocess
import sys


def parse_version(v: str):
    return [int(x) for x in v.split(".") if x.isdigit()]


def get_latest_tag() -> str:
    print("Fetching latest tags from zoidsh/meru...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    tags_out = subprocess.check_output(
        ["git", "ls-remote", "--tags", "https://github.com/zoidsh/meru.git"],
        text=True,
        env=env,
    )
    versions = []
    for line in tags_out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1].startswith("refs/tags/"):
            tag = parts[1][len("refs/tags/") :]
            if not tag.endswith("^{}") and re.match(r"^v[0-9]+(\.[0-9]+)+$", tag):
                versions.append(tag.lstrip("v"))
    if not versions:
        raise RuntimeError("No valid release tags found in zoidsh/meru")
    versions.sort(key=parse_version)
    return versions[-1]


def prefetch_src_hash(version: str) -> str:
    url = f"https://github.com/zoidsh/meru/archive/refs/tags/v{version}.tar.gz"
    print(f"Prefetching {url}...")
    raw_hash = subprocess.check_output(
        ["nix-prefetch-url", "--unpack", url],
        text=True,
    ).strip()
    sri_hash = subprocess.check_output(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw_hash],
        text=True,
    ).strip()
    return sri_hash


def compute_node_modules_hash(repo_root: Path) -> str:
    print("Building meru.passthru.node_modules to determine fixed-output hash...")
    proc = subprocess.run(
        [
            "nix-build",
            "--no-out-link",
            str(repo_root),
            "-A",
            "meru.passthru.node_modules",
        ],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    m = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", proc.stdout)
    if not m:
        print(proc.stdout, file=sys.stderr)
        raise RuntimeError(
            "Failed to extract new node_modules hash from nix-build output"
        )
    return m.group(1)


def main() -> int:
    try:
        repo_root = Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
        pkg_nix = repo_root / "by-name/me/meru/package.nix"
    except Exception:
        pkg_nix = Path(__file__).resolve().parent / "package.nix"
        repo_root = pkg_nix.parent.parent.parent.parent

    if not pkg_nix.is_file():
        print(f"Error: Could not find package.nix at {pkg_nix}", file=sys.stderr)
        return 1

    content = pkg_nix.read_text(encoding="utf-8")
    m_ver = re.search(r'(?m)^\s*version = "([^"]+)";', content)
    if not m_ver:
        print("Error: Could not find version in package.nix", file=sys.stderr)
        return 1
    current_version = m_ver.group(1)

    target_version = None
    for arg in sys.argv[1:]:
        if arg in ("-h", "--help"):
            print("Usage: update.py [TARGET_VERSION]")
            return 0
        if arg.startswith("--version="):
            target_version = arg.split("=", 1)[1].lstrip("v")
        elif not arg.startswith("-"):
            target_version = arg.lstrip("v")

    if not target_version:
        target_version = get_latest_tag()

    print(f"Current version: {current_version}")
    print(f"Target version:  {target_version}")

    src_hash = prefetch_src_hash(target_version)
    print(f"New source hash: {src_hash}")

    content, n_ver = re.subn(
        r'(?m)^(\s*version = )"[^"]+";',
        rf'\g<1>"{target_version}";',
        content,
        count=1,
    )
    content, n_src = re.subn(
        r'(src = fetchFromGitHub \{\s*owner = "zoidsh";\s*repo = "meru";\s*rev = "[^"]+";\s*hash = ")[^"]+(";)',
        rf"\g<1>{src_hash}\g<2>",
        content,
        count=1,
    )
    # Set dummy hash to trigger hash mismatch in nix-build
    dummy_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    content, n_out = re.subn(
        r'(?m)^(\s*outputHash = )"[^"]+";',
        rf'\g<1>"{dummy_hash}";',
        content,
        count=1,
    )

    if n_ver != 1 or n_src != 1 or n_out != 1:
        raise RuntimeError(
            f"Failed to update attributes in {pkg_nix} (ver={n_ver}, src={n_src}, outputHash={n_out})"
        )

    pkg_nix.write_text(content, encoding="utf-8")

    new_hash = compute_node_modules_hash(repo_root)
    print(f"New node_modules outputHash: {new_hash}")

    content, n_out_real = re.subn(
        r'(?m)^(\s*outputHash = )"[^"]+";',
        rf'\g<1>"{new_hash}";',
        content,
        count=1,
    )
    if n_out_real != 1:
        raise RuntimeError(f"Failed to write real node_modules hash in {pkg_nix}")

    pkg_nix.write_text(content, encoding="utf-8")
    print(f"Successfully updated meru to {target_version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
