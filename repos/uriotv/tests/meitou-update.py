#!/usr/bin/env python3
"""Offline tests for Meitou game release selection and NuGet refresh."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "pkgs/meitou-client/update.sh"


class MeitouUpdaterTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        (self.root / "pkgs/meitou-client").mkdir(parents=True)
        self.log = self.root / "calls"
        self.fixture = self.root / "releases.json"
        self.fixture.write_text(json.dumps([
            {"tag_name": "launcher-v9.0.0", "draft": False, "prerelease": False},
            {"tag_name": "v0.17.1-nightly", "draft": False, "prerelease": True},
            {"tag_name": "v0.20.0", "draft": True, "prerelease": False},
            {"tag_name": "v0.9.0", "draft": False, "prerelease": False},
            {"tag_name": "v0.17.1", "draft": False, "prerelease": False},
        ]))
        self.stub("curl", 'exec cat "$FIXTURE"')
        self.stub("nix", 'if [ "$1" = eval ]; then printf "%s\\n" "$CURRENT"; else printf "%s\\n" "$STUBDIR/fetch-deps"; fi')
        self.stub("nix-update", 'printf "nix-update %s\\n" "$*" >> "$CALLS"')
        self.stub("fetch-deps", 'printf "fetch-deps %s\\n" "$*" >> "$CALLS"')

    def stub(self, name, body):
        p = self.bin / name
        p.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + body + "\n")
        p.chmod(0o755)

    def run_updater(self, version):
        env = {**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}", "FIXTURE": str(self.fixture),
               "CURRENT": version, "CALLS": str(self.log), "STUBDIR": str(self.bin)}
        return subprocess.run(["bash", str(SCRIPT)], cwd=self.root, env=env, text=True, capture_output=True)

    def test_picks_newest_stable_game_and_regenerates_deps(self):
        result = self.run_updater("0.16.0")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.log.read_text().splitlines(), [
            "nix-update --flake meitou-client --version 0.17.1",
            "fetch-deps pkgs/meitou-client/deps.json",
        ])

    def test_same_or_older_upstream_never_downgrades(self):
        for version in ("0.17.1", "1.0.0"):
            with self.subTest(version=version):
                result = self.run_updater(version)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(self.log.exists())

    def test_missing_stable_game_release_fails_closed(self):
        self.fixture.write_text(json.dumps([{"tag_name": "launcher-v9.0.0", "draft": False, "prerelease": False}]))
        result = self.run_updater("0.1.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
