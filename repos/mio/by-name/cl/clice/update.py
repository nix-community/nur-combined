#!/usr/bin/env python3
import os
from pathlib import Path
import re
import subprocess
import sys


def parse_version(v: str):
    return [int(x) for x in v.split(".") if x.isdigit()]


def get_latest_tag() -> str:
    print("Fetching latest tags from clice-io/clice...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    tags_out = subprocess.check_output(
        ["git", "ls-remote", "--tags", "https://github.com/clice-io/clice.git"],
        text=True,
        env=env,
    )
    versions = []
    for line in tags_out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1].startswith("refs/tags/"):
            tag = parts[1][len("refs/tags/") :]
            if not tag.endswith("^{}") and re.match(r"^v[0-9]+(\.[0-9]+)+$", tag):
                versions.append(tag[1:])
    if not versions:
        raise RuntimeError("No valid release tags found in clice-io/clice")
    versions.sort(key=parse_version)
    return versions[-1]


def get_registry_rev() -> str:
    print("Fetching latest gh-pages commit from clice-io/bazel...")
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    out = subprocess.check_output(
        [
            "git",
            "ls-remote",
            "https://github.com/clice-io/bazel.git",
            "refs/heads/gh-pages",
        ],
        text=True,
        env=env,
    )
    for line in out.splitlines():
        parts = line.split()
        if parts and re.match(r"^[0-9a-f]{40}$", parts[0]):
            return parts[0]
    raise RuntimeError("Could not resolve gh-pages commit from clice-io/bazel")


def prefetch_src_hash(version: str) -> str:
    url = f"https://github.com/clice-io/clice/archive/refs/tags/v{version}.tar.gz"
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


def get_current_system() -> str:
    return subprocess.check_output(
        ["nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem"],
        text=True,
    ).strip()


def compute_deps_hash(repo_root: Path) -> str | None:
    print("Building clice.deps to determine updated fixed-output hash...")
    proc = subprocess.run(
        ["nix-build", "--no-out-link", str(repo_root), "-A", "clice.deps"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if proc.returncode == 0:
        print("clice.deps built cleanly with the existing hash.")
        return None
    m = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", proc.stdout)
    if not m:
        print(proc.stdout, file=sys.stderr)
        raise RuntimeError("Failed to extract new deps hash from nix-build output")
    return m.group(1)


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    try:
        repo_root = Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
        pkg_nix = repo_root / "by-name/cl/clice/package.nix"
    except Exception:
        pkg_nix = script_dir / "package.nix"
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

    if current_version == target_version:
        print(f"clice is already up to date ({current_version}).")
        return 0

    src_hash = prefetch_src_hash(target_version)
    print(f"New source hash: {src_hash}")

    registry_rev = get_registry_rev()
    print(f"New registryRev: {registry_rev}")

    content, n_ver = re.subn(
        r'(?m)^(\s*version = )"[^"]+";',
        rf'\g<1>"{target_version}";',
        content,
        count=1,
    )
    content, n_reg = re.subn(
        r'(?m)^(\s*registryRev = )"[^"]+";',
        rf'\g<1>"{registry_rev}";',
        content,
        count=1,
    )
    content, n_src = re.subn(
        r'(src = fetchFromGitHub \{\s*owner = "clice-io";\s*repo = "clice";\s*tag = "v\$\{finalAttrs\.version\}";\s*hash = ")[^"]+(";)',
        rf"\g<1>{src_hash}\g<2>",
        content,
        count=1,
    )
    if n_ver != 1 or n_reg != 1 or n_src != 1:
        raise RuntimeError(
            f"Failed to update attributes in {pkg_nix} (ver={n_ver}, reg={n_reg}, src={n_src})"
        )

    pkg_nix.write_text(content, encoding="utf-8")

    system = get_current_system()
    new_deps_hash = compute_deps_hash(repo_root)
    if new_deps_hash:
        print(f"New depsHash for {system}: {new_deps_hash}")
        content, n_deps = re.subn(
            rf'(?m)^(\s*{re.escape(system)} = )"[^"]+";',
            rf'\g<1>"{new_deps_hash}";',
            content,
            count=1,
        )
        if n_deps != 1:
            raise RuntimeError(f"Failed to update depsHashes.{system} in {pkg_nix}")
        pkg_nix.write_text(content, encoding="utf-8")

    print(f"Successfully updated clice to {target_version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
