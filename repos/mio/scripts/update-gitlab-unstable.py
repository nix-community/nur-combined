#!/usr/bin/env python3
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path


def run(*args: str) -> str:
    return subprocess.check_output(args, text=True).strip()


def main() -> int:
    if len(sys.argv) not in (4, 5):
        print(
            f"Usage: {Path(sys.argv[0]).name} PACKAGE_PATH HOST/OWNER/REPO ATTRIBUTE [stable]",
            file=sys.stderr,
        )
        return 2

    package_path, project, attribute = sys.argv[1:4]
    stable = len(sys.argv) == 5 and sys.argv[4] == "stable"
    host, owner, repo = project.split("/", 2)
    root = Path(run("git", "rev-parse", "--show-toplevel"))
    package = root / package_path
    if package.is_dir():
        package /= "package.nix"
    content = package.read_text(encoding="utf-8")

    env = dict(os.environ, GIT_CONFIG_COUNT="0", GIT_TERMINAL_PROMPT="0")
    remote = f"https://{host}/{owner}/{repo}.git"
    if stable:
        tags = subprocess.check_output(
            ["git", "ls-remote", "--tags", remote],
            text=True,
            env=env,
        )
        versions = sorted(
            (
                (tuple(int(part) for part in tag.lstrip("v").split(".")), tag)
                for line in tags.splitlines()
                for tag in [line.split("refs/tags/")[-1]]
                if re.fullmatch(r"v?\d+(?:\.\d+)+", tag)
            ),
            reverse=True,
        )
        if not versions:
            raise RuntimeError(f"No semver tags found for {remote}")
        tag = versions[0][1]
        version = tag.lstrip("v")
        archive_ref = tag
        rev = subprocess.check_output(
            ["git", "ls-remote", remote, f"refs/tags/{archive_ref}"],
            text=True,
            env=env,
        ).split()[0]
    else:
        rev = subprocess.check_output(
            ["git", "ls-remote", remote, "HEAD"],
            text=True,
            env=env,
        ).split()[0]
        version = f"0-unstable-{datetime.now(timezone.utc):%Y-%m-%d}"
        archive_ref = rev
    current_source = re.search(
        r'(?m)^\s*(?:rev|tag) = "([^"]+)";',
        content,
    )
    if not current_source and re.search(
        r'(?m)^\s*(?:tag|rev) = finalAttrs\.version;',
        content,
    ):
        current_source = re.search(r'(?m)^\s*version = "([^"]+)";', content)
    if not current_source:
        raise RuntimeError(f"Could not find rev or tag in {package}")
    if (stable and current_source.group(1) == version) or (
        not stable and current_source.group(1) == rev
    ):
        print(f"{attribute} is already up to date ({rev[:7]}).")
        return 0

    if host == "gitlab.com":
        archive = (
            f"https://{host}/{owner}/{repo}/-/archive/"
            f"{archive_ref}/{repo}-{archive_ref}.tar.gz"
        )
        raw_hash = run("nix-prefetch-url", "--unpack", archive)
        sri_hash = run(
            "nix",
            "hash",
            "convert",
            "--hash-algo",
            "sha256",
            "--to",
            "sri",
            raw_hash,
        )
    else:
        with tempfile.TemporaryDirectory() as temp_dir:
            checkout = Path(temp_dir) / "src"
            checkout.mkdir()
            run("git", "-C", str(checkout), "init", "--quiet")
            run("git", "-C", str(checkout), "remote", "add", "origin", remote)
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
            )
            run("git", "-C", str(checkout), "checkout", "--quiet", "FETCH_HEAD")
            shutil.rmtree(checkout / ".git")
            sri_hash = run("nix", "hash", "path", "--type", "sha256", str(checkout))
    content, rev_count = re.subn(
        r'(?m)^(\s*rev = )"[^"]+";',
        rf'\g<1>"{rev}";',
        content,
        count=1,
    )
    if rev_count == 0:
        rev_count = 1
    content, hash_count = re.subn(
        r'(?ms)(src = fetch(?:FromGitLab|git) \{.*?^\s*hash = )"[^"]+";',
        rf'\g<1>"{sri_hash}";',
        content,
        count=1,
    )
    content, version_count = re.subn(
        r'(?m)^(\s*version = )"[^"]+";',
        rf'\g<1>"{version}";',
        content,
        count=1,
    )
    if (rev_count, hash_count, version_count) != (1, 1, 1):
        raise RuntimeError(
            f"Failed to update {package} "
            f"(rev={rev_count}, hash={hash_count}, version={version_count})"
        )

    package.write_text(content, encoding="utf-8")
    print(f"Updated {attribute}: {current_source.group(1)[:7]} -> {rev[:7]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
