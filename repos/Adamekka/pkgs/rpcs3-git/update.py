#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
import tempfile
from pathlib import Path
from urllib.parse import urlsplit


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--revision",
        default="master",
        help="RPCS3 revision to update to, default: master",
    )
    args = parser.parse_args()
    package_path = Path(__file__).with_name("default.nix")
    pins_path = Path(__file__).with_name("submodules.json")
    original_package = package_path.read_bytes()
    original_pins = pins_path.read_bytes()
    current = json.loads(original_pins)
    package_revisions = re.findall(
        r'\brev\s*=\s*"([0-9a-f]{40})";', original_package.decode()
    )
    if len(package_revisions) != 1:
        raise RuntimeError("Expected exactly one pinned RPCS3 source revision")

    with tempfile.TemporaryDirectory(prefix="rpcs3-update-") as temporary:
        checkout = Path(temporary)

        def git_output(*arguments):
            return subprocess.check_output(
                ["git", "-C", str(checkout), *arguments], text=True
            ).strip()

        git_output("init", "--quiet")
        git_output("remote", "add", "origin", "https://github.com/RPCS3/rpcs3.git")
        git_output(
            "fetch", "--recurse-submodules=no", "--depth=1", "origin", args.revision
        )
        git_output("checkout", "--quiet", "--detach", "FETCH_HEAD")
        revision = git_output("rev-parse", "HEAD")
        # Capture HEAD once, so every dependency and the final source refer to one commit.
        paths = sorted(current)
        git_output("submodule", "init", "--", *paths)
        names = {}
        for entry in git_output(
            "config", "--file", ".gitmodules", "--get-regexp", r"^submodule\..*\.path$"
        ).splitlines():
            key, path = entry.split(maxsplit=1)
            if path in names:
                raise RuntimeError(f"Duplicate upstream submodule path: {path}")
            names[path] = key.removesuffix(".path")

        updated = {}
        for path in paths:
            tree_entry = git_output("ls-tree", "HEAD", path).split()
            if (
                len(tree_entry) != 4
                or tree_entry[:2] != ["160000", "commit"]
                or path not in names
            ):
                raise RuntimeError(f"Expected a pinned upstream submodule at {path}")
            submodule_revision = tree_entry[2]
            url = urlsplit(git_output("config", "--get", names[path] + ".url"))
            repository = url.path.removeprefix("/").removesuffix(".git").split("/")
            if (
                url.scheme != "https"
                or url.netloc != "github.com"
                or url.query
                or url.fragment
                or len(repository) != 2
            ):
                raise RuntimeError(
                    f"Unsupported submodule URL at {path}: {url.geturl()}"
                )
            owner, repo = repository
            pin = {"owner": owner, "repo": repo, "rev": submodule_revision}
            prefetch = [
                "nix",
                "store",
                "prefetch-file",
                "--unpack",
                "--name",
                "source",
                "--json",
            ]
            if all(current[path][key] == value for key, value in pin.items()):
                prefetch += ["--expected-hash", current[path]["hash"]]
            archive = f"https://codeload.github.com/{owner}/{repo}/tar.gz/{submodule_revision}"
            pin["hash"] = json.loads(
                subprocess.check_output([*prefetch, archive], text=True)
            )["hash"]
            updated[path] = pin

        if package_revisions[0] == revision and updated == current:
            print(f"RPCS3 {revision} and its submodules are up to date")
            return

        # Preserve the existing version convention, using the nearest reachable release tag.
        describe_command = [
            "git",
            "-C",
            str(checkout),
            "describe",
            "--tags",
            "--abbrev=0",
            "--match",
            "v*",
        ]
        depth = 100
        while True:
            tag = subprocess.run(
                describe_command,
                capture_output=True,
                text=True,
                check=False,
            )
            if tag.returncode == 0:
                break
            if depth > 10000:
                git_output(
                    "fetch",
                    "--recurse-submodules=no",
                    "--unshallow",
                    "--tags",
                    "origin",
                    revision,
                )
                tag = subprocess.run(
                    describe_command,
                    capture_output=True,
                    text=True,
                    check=True,
                )
                break
            git_output(
                "fetch",
                "--recurse-submodules=no",
                f"--depth={depth}",
                "--tags",
                "origin",
                revision,
            )
            depth *= 2
        match = re.fullmatch(r"v([0-9]+(?:\.[0-9]+)+)", tag.stdout.strip())
        if match is None:
            raise RuntimeError(f"Unexpected RPCS3 release tag: {tag.stdout.strip()!r}")
        version = (
            f"{match[1]}-unstable-{git_output('show', '-s', '--format=%cs', 'HEAD')}"
        )

        try:
            pins_path.write_text(json.dumps(updated, indent=2, sort_keys=True) + "\n")
            # Same-day upstream commits can share a version string but still need new pins.
            source_update = [
                "update-source-version",
                "rpcs3-git",
                version,
                f"--file={package_path}",
                "--ignore-same-version",
            ]
            if package_revisions[0] != revision:
                source_update.append(f"--rev={revision}")
            subprocess.run(
                source_update,
                check=True,
            )
        except BaseException:
            # A failed fetch must not leave the package and dependency pins out of sync.
            package_path.write_bytes(original_package)
            pins_path.write_bytes(original_pins)
            raise


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"RPCS3 update failed: {error}")
