#!/usr/bin/env python3
"""Offline tests: .NET packages stay on binary SDKs and their NuGet locks are
refreshed together with every flake.lock update (no builds, no network)."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/refresh-dotnet-deps.sh"
WORKFLOW = ROOT / ".github/workflows/flake-update.yml"


def declared_entries():
    text = SCRIPT.read_text()
    block = re.search(r"DOTNET_DEPS=\((.*?)\n\)", text, re.S).group(1)
    return [tuple(e.split(":", 1)) for e in re.findall(r'"([^"]+)"', block)]


def dotnet_package_files():
    return sorted(p for p in (ROOT / "pkgs").glob("*/*.nix") if "buildDotnetModule" in p.read_text())


class DotnetPolicyTests(unittest.TestCase):
    def test_every_dotnet_package_lock_is_refreshed(self):
        locks = {lock for _, lock in declared_entries()}
        for nix in dotnet_package_files():
            lock = f"pkgs/{nix.parent.name}/deps.json"
            with self.subTest(package=nix.parent.name):
                self.assertIn(lock, locks, "add the package to DOTNET_DEPS in refresh-dotnet-deps.sh")
        for lock in locks:
            self.assertTrue((ROOT / lock).is_file(), lock)

    def test_dotnet_packages_use_binary_sdk_and_runtime(self):
        # Source-built SDKs bootstrap dotnet-vmr for hours and time out CI.
        for nix in dotnet_package_files():
            text = nix.read_text()
            with self.subTest(file=str(nix.relative_to(ROOT))):
                self.assertRegex(text, r"dotnet-sdk\s*=\s*dotnetCorePackages\.sdk_[0-9_a-z]+-bin\s*;")
                self.assertRegex(text, r"dotnet-runtime\s*=\s*dotnetCorePackages\.runtime_[0-9_]+-bin\s*;")

    def test_flake_update_refreshes_locks_in_the_same_pr(self):
        text = WORKFLOW.read_text()
        update = text.index("run: nix flake update")
        refresh = text.index("bash scripts/refresh-dotnet-deps.sh")
        cpr = text.index("peter-evans/create-pull-request")
        self.assertLess(update, refresh)
        self.assertLess(refresh, cpr)
        self.assertIn("pkgs/*/deps.json", text[cpr:])
        self.assertIn("'pkgs/*/deps.json'", text[update:cpr])


class RefreshScriptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "repo"
        (self.repo / "scripts").mkdir(parents=True)
        shutil.copy(SCRIPT, self.repo / "scripts")
        for _, lock in declared_entries():
            (self.repo / lock).parent.mkdir(parents=True, exist_ok=True)
            (self.repo / lock).write_text("old\n")
        git = ["git", "-C", str(self.repo), "-c", "user.name=t", "-c", "user.email=t@t"]
        subprocess.run(git[:3] + ["init", "-q"], check=True)
        subprocess.run(git + ["add", "."], check=True)
        subprocess.run(git + ["commit", "-qm", "init"], check=True)
        self.bin = Path(self.temp.name) / "bin"
        self.bin.mkdir()
        fetch = self.bin / "fake-fetch-deps"
        fetch.write_text('#!/usr/bin/env bash\n'
                         'printf "%s %s %s\\n" "$TMPDIR" "$HOME" "$DOTNET_CLI_HOME" >> "$NIX_CALLS.env"\n'
                         '[[ -d "$TMPDIR" && -d "$HOME" && "$HOME" == "$DOTNET_CLI_HOME" ]] || exit 9\n'
                         'echo partial > "$1"\n'
                         '[[ "$1" == "$FAIL_LOCK" ]] && exit 1\necho new > "$1"\n')
        fetch.chmod(0o755)
        nix = self.bin / "nix"
        # Record which locks were already emptied when each fetch-deps was evaluated.
        nix.write_text(f'#!/usr/bin/env bash\necho "$*" >> "$NIX_CALLS"\n'
                       'for f in pkgs/*/deps.json; do printf "%s=%s " "$f" "$(cat "$f")"; done >> "$NIX_CALLS.locks"\n'
                       'echo >> "$NIX_CALLS.locks"\n'
                       f'echo {fetch}\n')
        nix.chmod(0o755)
        self.calls = Path(self.temp.name) / "calls"

    def run_script(self, **env):
        return subprocess.run(
            ["bash", "scripts/refresh-dotnet-deps.sh"], cwd=self.repo, text=True, capture_output=True,
            env={**os.environ, "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
                 "NIX_CALLS": str(self.calls), **env})

    def test_refreshes_every_lock_without_building_packages(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for attr, lock in declared_entries():
            self.assertEqual((self.repo / lock).read_text(), "new\n")
        calls = self.calls.read_text().splitlines()
        self.assertEqual(len(calls), len(declared_entries()))
        self.assertTrue(all(c.rstrip().endswith(".fetch-deps") for c in calls), calls)
        # Each lock is regenerated from scratch, never from its stale content.
        snapshots = Path(str(self.calls) + ".locks").read_text().splitlines()
        for (_, lock), snapshot in zip(declared_entries(), snapshots):
            self.assertIn(f"{lock}=[]", snapshot)
        # Each fetch-deps gets its own fresh TMPDIR/HOME, removed afterwards.
        envs = [line.split() for line in Path(str(self.calls) + ".env").read_text().splitlines()]
        self.assertEqual(len({e[0] for e in envs}), len(envs))
        self.assertTrue(all(e[0] != os.environ.get("TMPDIR", "/tmp") for e in envs))
        self.assertFalse(any(Path(e[0]).exists() for e in envs))

    def test_failure_restores_that_lock_continues_and_fails(self):
        entries = declared_entries()
        failing = entries[0][1]
        result = self.run_script(FAIL_LOCK=failing)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"Failed to refresh {failing}", result.stdout)
        self.assertEqual((self.repo / failing).read_text(), "old\n")
        for _, lock in entries[1:]:
            self.assertEqual((self.repo / lock).read_text(), "new\n")


if __name__ == "__main__":
    unittest.main()
