#!/usr/bin/env python3
"""Offline regression tests for the package update workflow."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

RUNNER = Path(__file__).resolve().parents[1] / "scripts/update-packages.sh"


class UpdateWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.summary = self.root / "summary.md"
        self.body = self.root / "pr-body.md"

    def package(self, name, commands):
        directory = self.root / "pkgs" / name
        directory.mkdir(parents=True)
        (directory / "default.nix").write_text("original\n")
        script = directory / "update.sh"
        script.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + commands + "\n")
        script.chmod(0o755)
        return directory

    def run_updates(self, package=""):
        return subprocess.run(
            ["bash", str(RUNNER)],
            cwd=self.root,
            env={
                **os.environ,
                "UPDATE_PACKAGE": package,
                "GITHUB_STEP_SUMMARY": str(self.summary),
                "PR_BODY_PATH": str(self.body),
                "BUILD_LOG_URL": "https://example.org/build/123",
            },
            text=True,
            capture_output=True,
        )

    def test_failure_restores_package_and_continues_before_and_after(self):
        before = self.package("a-good", 'echo updated > pkgs/a-good/default.nix')
        failed = self.package(
            "b-broken",
            "echo partial > pkgs/b-broken/default.nix\n"
            "rm pkgs/b-broken/existing.txt\n"
            "mkdir pkgs/b-broken/generated\n"
            "echo leftover > pkgs/b-broken/generated/hash\n"
            "chmod -x pkgs/b-broken/update.sh\n"
            "echo 'download failed | <error> `EOF`'\nexit 1",
        )
        (failed / "existing.txt").write_text("preserved\n")
        after = self.package("c-good", 'echo updated > pkgs/c-good/default.nix')

        result = self.run_updates()

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((before / "default.nix").read_text(), "updated\n")
        self.assertEqual((after / "default.nix").read_text(), "updated\n")
        self.assertEqual((failed / "default.nix").read_text(), "original\n")
        self.assertEqual((failed / "existing.txt").read_text(), "preserved\n")
        self.assertFalse((failed / "generated").exists())
        self.assertTrue(os.access(failed / "update.sh", os.X_OK))
        self.assertIn("::warning file=pkgs/b-broken/update.sh::", result.stdout)
        summary = self.summary.read_text()
        self.assertIn("| a-good | ✅ Success |", summary)
        self.assertIn("| b-broken | ❌ Failed |", summary)
        self.assertIn("| c-good | ✅ Success |", summary)
        self.assertIn(r"download failed \| \<error\> \`EOF\`", summary)
        self.assertIn(summary.strip(), self.body.read_text())
        self.assertIn("https://example.org/build/123", self.body.read_text())

    def test_all_failures_are_warnings_and_leave_no_partial_updates(self):
        for name in ("a", "b"):
            self.package(name, f"echo partial > pkgs/{name}/default.nix\nexit 1")
        result = self.run_updates()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("2 package update(s) failed", result.stdout)
        for name in ("a", "b"):
            self.assertEqual((self.root / "pkgs" / name / "default.nix").read_text(),
                             "original\n")

    def test_specific_package_failure_does_not_run_other_updaters(self):
        good = self.package("good", "echo unexpected > pkgs/good/default.nix")
        self.package("broken", "echo partial > pkgs/broken/default.nix\nexit 1")
        result = self.run_updates("broken")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((good / "default.nix").read_text(), "original\n")
        self.assertNotIn("| good |", self.summary.read_text())

    def test_successful_updates_are_preserved_without_warning(self):
        good = self.package("good", "echo updated > pkgs/good/default.nix")
        result = self.run_updates()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((good / "default.nix").read_text(), "updated\n")
        self.assertNotIn("::warning", result.stdout)

    def test_invalid_or_missing_package_remains_a_hard_error(self):
        for name in ("../escape", "..", ".", "missing"):
            with self.subTest(package=name):
                result = self.run_updates(name)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("::error::", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
