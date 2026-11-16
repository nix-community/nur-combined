#!/usr/bin/env python3
"""Update Cutefish package pins in pkgs/desktops/cutefish/sources.nix."""

from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


OWNER = "cutefishos"
SOURCES_REL = Path("pkgs/desktops/cutefish/sources.nix")


def run(
    *args: str,
    env: dict[str, str] | None = None,
    quiet_stderr: bool = False,
) -> str:
    return subprocess.check_output(
        args,
        text=True,
        env=env,
        stderr=subprocess.DEVNULL if quiet_stderr else None,
    ).strip()


def clean_env() -> dict[str, str]:
    # Hardened Python can leave allocator hooks that abort Nix unpack helpers.
    env = {
        key: value
        for key, value in os.environ.items()
        if key not in ("LD_PRELOAD", "LD_LIBRARY_PATH")
    }
    env["GIT_TERMINAL_PROMPT"] = "0"
    env["GIT_CONFIG_COUNT"] = "0"
    return env


def repo_root() -> Path:
    return Path(run("git", "rev-parse", "--show-toplevel"))


def list_packages(content: str) -> list[str]:
    return re.findall(r"(?m)^  ([A-Za-z0-9_-]+) = \{", content)


def entry_block(content: str, pname: str) -> re.Match[str]:
    match = re.search(
        rf"(?ms)^  {re.escape(pname)} = \{{.*?\n  \}};",
        content,
    )
    if not match:
        raise RuntimeError(f"No sources.nix entry for {pname}")
    return match


def field(block: str, name: str) -> str:
    match = re.search(rf'(?m)^\s*{re.escape(name)} = "([^"]+)";', block)
    if not match:
        raise RuntimeError(f"Missing {name} in sources entry")
    return match.group(1)


def github_remote(repo: str) -> str:
    return f"https://github.com/{OWNER}/{repo}.git"


def latest_rev(repo: str) -> str:
    return run(
        "git", "ls-remote", github_remote(repo), "HEAD", env=clean_env()
    ).split()[0]


def commit_date(repo: str, rev: str) -> str:
    remote = github_remote(repo)
    env = clean_env()
    with tempfile.TemporaryDirectory() as temp_dir:
        checkout = Path(temp_dir) / "src"
        checkout.mkdir()
        run("git", "-C", str(checkout), "init", "--quiet", env=env)
        run("git", "-C", str(checkout), "remote", "add", "origin", remote, env=env)
        run(
            "git",
            "-C",
            str(checkout),
            "fetch",
            "--quiet",
            "--depth",
            "1",
            "origin",
            rev,
            env=env,
        )
        return run(
            "git",
            "-C",
            str(checkout),
            "show",
            "-s",
            "--format=%cs",
            "FETCH_HEAD",
            env=env,
        )


def prefetch_hash(repo: str, rev: str) -> str:
    # Hash the same GitHub archive fetchFromGitHub uses. A plain git checkout
    # can diverge (export-ignore / LFS), which is what broke cutefish-icons.
    # Call nix-prefetch-url under a cleaned env: hardened Python's allocator
    # hooks have aborted the unpack helpers mid-run.
    archive = f"https://github.com/{OWNER}/{repo}/archive/{rev}.tar.gz"
    env = clean_env()
    raw = run(
        "nix-prefetch-url",
        "--unpack",
        archive,
        env=env,
        quiet_stderr=True,
    ).splitlines()[-1]
    return run(
        "nix",
        "hash",
        "convert",
        "--hash-algo",
        "sha256",
        "--to",
        "sri",
        raw,
        env=env,
    )


def update_package(content: str, pname: str) -> tuple[str, bool, str]:
    match = entry_block(content, pname)
    block = match.group(0)
    repo = field(block, "repo")
    old_rev = field(block, "rev")
    rev = latest_rev(repo)
    if rev == old_rev:
        return content, False, f"{pname} is already up to date ({rev[:7]})."

    date, sri = commit_date(repo, rev), prefetch_hash(repo, rev)
    new_block, n = re.subn(
        r'(?m)^(\s*rev = )"[^"]+";(\n\s*hash = )"[^"]+";(\n\s*date = )"[^"]+";',
        rf'\1"{rev}";\2"{sri}";\3"{date}";',
        block,
        count=1,
    )
    if n != 1:
        raise RuntimeError(f"Failed to rewrite {pname} entry")

    updated = content[: match.start()] + new_block + content[match.end() :]
    return (
        updated,
        True,
        f"Updated {pname}: {old_rev[:7]} -> {rev[:7]} ({date})",
    )


def main(argv: list[str]) -> int:
    root = repo_root()
    sources_path = root / SOURCES_REL
    content = sources_path.read_text(encoding="utf-8")
    packages = list_packages(content)

    if len(argv) >= 2 and argv[1] == "--all":
        targets = packages
    elif len(argv) >= 2:
        targets = argv[1:]
    elif os.environ.get("UPDATE_NIX_ATTR_PATH"):
        targets = [os.environ["UPDATE_NIX_ATTR_PATH"]]
    else:
        print(
            f"Usage: {Path(argv[0]).name} <pname>|--all",
            file=sys.stderr,
        )
        return 2

    unknown = [name for name in targets if name not in packages]
    if unknown:
        raise RuntimeError(
            f"Unknown Cutefish source entries: {', '.join(unknown)}; "
            f"known: {', '.join(packages)}"
        )

    changed = False
    for pname in targets:
        content, did_change, message = update_package(content, pname)
        print(message)
        changed = changed or did_change

    if changed:
        sources_path.write_text(content, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
