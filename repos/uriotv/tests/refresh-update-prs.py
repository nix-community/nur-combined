#!/usr/bin/env python3
"""Offline tests for scripts/refresh-update-prs.sh (stubbed gh, no network)."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RefreshUpdatePrsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.calls = self.root / "calls"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        gh = self.bin / "gh"
        gh.write_text('''#!/usr/bin/env bash
echo "$*" >> "$CALLS"
if [[ $1 == pr && $2 == list ]]; then printf '%s' "$OPEN_HEADS"; fi
''')
        gh.chmod(0o755)

    def run_refresh(self, heads):
        result = subprocess.run(
            ["bash", str(ROOT / "scripts/refresh-update-prs.sh")], text=True, capture_output=True,
            env={**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}", "CALLS": str(self.calls),
                 "OPEN_HEADS": "".join(f"{h}\n" for h in heads),
                 "GH_TOKEN": "t", "GH_REPO": "o/r"})
        dispatched = [line for line in self.calls.read_text().splitlines()
                      if line.startswith("workflow run")]
        return result, dispatched

    def test_nothing_is_dispatched_without_open_update_prs(self):
        result, dispatched = self.run_refresh(["feature/x", "fix/auto-update/y"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(dispatched, [])
        self.assertIn("nothing to refresh", result.stdout)

    def test_open_package_prs_dispatch_the_updater_once(self):
        result, dispatched = self.run_refresh(["auto-update/pig", "auto-update/wowup-cf", "feature/x"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(dispatched, ["workflow run update.yml --ref main"])
        self.assertIn("2 open package update", result.stdout)

    def test_open_lock_pr_dispatches_the_lock_update(self):
        result, dispatched = self.run_refresh(["auto-update-flake-lock"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(dispatched, ["workflow run flake-update.yml --ref main"])

    def test_both_kinds_dispatch_both_workflows(self):
        _, dispatched = self.run_refresh(["auto-update-flake-lock", "auto-update/pig"])
        self.assertEqual(dispatched, ["workflow run update.yml --ref main",
                                      "workflow run flake-update.yml --ref main"])

    def test_workflow_is_trusted_and_least_privileged(self):
        body = (ROOT / ".github/workflows/refresh-update-prs.yml").read_text()
        self.assertIn("push:\n    branches: [main]", body)
        self.assertNotIn("pull_request", body.split("jobs:")[0].split("on:")[1])
        self.assertIn("permissions: {}", body)
        self.assertIn("actions: write", body)
        self.assertNotIn("secrets.", body)
        for name in ("update.yml", "flake-update.yml"):
            workflow = (ROOT / ".github/workflows" / name).read_text()
            self.assertIn("workflow_dispatch:", workflow)
            self.assertIn("cancel-in-progress: false", workflow)


if __name__ == "__main__":
    unittest.main(verbosity=2)
