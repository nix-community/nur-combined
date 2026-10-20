#!/usr/bin/env python3
"""Offline regression tests for the package update workflow."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO_ROOT = Path(__file__).resolve().parents[1]
RUNNER = REPO_ROOT / "scripts/update-packages.sh"
RIMSORT_RELEASE_SELECTOR = REPO_ROOT / "pkgs/rimsort-appimage/latest-stable-version.py"
RIMSORT_UPDATE_SCRIPT = REPO_ROOT / "pkgs/rimsort-appimage/update.sh"


class RimSortReleaseSelectionTests(unittest.TestCase):
    def select_version(self, releases):
        return subprocess.run(
            ["python3", str(RIMSORT_RELEASE_SELECTOR)],
            input=json.dumps(releases),
            text=True,
            capture_output=True,
            check=False,
        )

    def test_ignores_edge_and_selects_newest_stable_with_appimage(self):
        releases = [
            {
                "tag_name": "Edge",
                "prerelease": True,
                "assets": [{"name": "RimSort-v1.16.0-edge1-x86_64.AppImage"}],
            },
            {
                "tag_name": "v1.15.1",
                "prerelease": False,
                "assets": [{"name": "RimSort-v1.15.1-Ubuntu-24.04_x86_64.tar.gz"}],
            },
            {
                "tag_name": "v1.15.0",
                "prerelease": False,
                "assets": [{"name": "RimSort-v1.15.0-x86_64.AppImage"}],
            },
        ]

        result = self.select_version(releases)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "1.15.0")

    def test_selects_newer_stable_once_its_appimage_exists(self):
        releases = [
            {
                "tag_name": "v1.16.0",
                "prerelease": False,
                "assets": [{"name": "RimSort-v1.16.0-x86_64.AppImage"}],
            },
            {
                "tag_name": "v1.15.0",
                "prerelease": False,
                "assets": [{"name": "RimSort-v1.15.0-x86_64.AppImage"}],
            },
        ]

        result = self.select_version(releases)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "1.16.0")

    def test_fails_if_no_stable_release_has_appimage(self):
        result = self.select_version([
            {"tag_name": "Edge", "prerelease": True, "assets": []},
            {"tag_name": "v1.15.1", "prerelease": False, "assets": []},
        ])

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No stable RimSort release", result.stderr)


class RimSortUpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.fixture = self.root / "releases.json"
        self.args_file = self.root / "nix-update-args"

        curl_stub = self.bin / "curl"
        curl_stub.write_text("#!/usr/bin/env bash\ncat \"$RELEASES_FIXTURE\"\n")
        curl_stub.chmod(0o755)

        nix_update_stub = self.bin / "nix-update"
        nix_update_stub.write_text(
            "#!/usr/bin/env bash\nprintf '%s\\n' \"$@\" > \"$NIX_UPDATE_ARGS_FILE\"\n"
        )
        nix_update_stub.chmod(0o755)

    def run_updater(self, releases):
        self.fixture.write_text(json.dumps(releases))
        return subprocess.run(
            ["bash", str(RIMSORT_UPDATE_SCRIPT)],
            cwd=REPO_ROOT,
            env={
                **os.environ,
                "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
                "RELEASES_FIXTURE": str(self.fixture),
                "NIX_UPDATE_ARGS_FILE": str(self.args_file),
            },
            text=True,
            capture_output=True,
            check=False,
        )

    def test_update_script_passes_only_stable_asset_version_to_nix_update(self):
        result = self.run_updater([
            {
                "tag_name": "Edge",
                "prerelease": True,
                "assets": [{"name": "RimSort-v1.16.0-edge1-x86_64.AppImage"}],
            },
            {
                "tag_name": "v1.15.0",
                "prerelease": False,
                "assets": [{"name": "RimSort-v1.15.0-x86_64.AppImage"}],
            },
        ])

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.args_file.read_text().splitlines(),
            ["--flake", "--version=1.15.0", "rimsort-appimage"],
        )

    def test_update_script_does_not_call_nix_update_without_a_matching_asset(self):
        result = self.run_updater([
            {
                "tag_name": "v1.15.1",
                "prerelease": False,
                "assets": [{"name": "RimSort-v1.15.1-Ubuntu-24.04_x86_64.tar.gz"}],
            },
        ])

        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.args_file.exists())


class UpdateWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.summary = self.root / "summary.md"
        self.body = self.root / "pr-body.md"
        self.outputs = self.root / "outputs"

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
                "GITHUB_OUTPUT": str(self.outputs),
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

    def test_counts_allow_workflow_to_report_partial_failure_after_opening_pr(self):
        self.package("good", "true")
        self.package("bad", "exit 1")
        result = self.run_updates()
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.outputs.read_text(), "update_failures=1\nsuccessful_updates=1\n")

    def test_forgotten_updater_fails_preflight_before_changing_other_packages(self):
        good = self.package("a-good", "echo updated > pkgs/a-good/default.nix")
        missing = self.root / "pkgs" / "z-new"
        missing.mkdir()
        (missing / "default.nix").write_text("original\n")
        result = self.run_updates()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing executable updater", result.stdout)
        self.assertEqual((good / "default.nix").read_text(), "original\n")

    def test_nonpackage_directories_are_not_updated(self):
        self.package("good", "true")
        orphan = self.package("orphan", "exit 1")
        (orphan / "default.nix").unlink()
        result = self.run_updates()
        self.assertEqual(result.returncode, 0)
        self.assertNotIn("Updating orphan", result.stdout)
        self.assertIn("update_failures=0", self.outputs.read_text())

    def test_empty_registry_is_a_hard_error(self):
        (self.root / "pkgs").mkdir()
        result = self.run_updates()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No packages discovered", result.stdout)

    def test_scopebuddy_tag_tracks_the_declared_version(self):
        source = (REPO_ROOT / "pkgs/scopebuddy/default.nix").read_text()
        self.assertIn("tag = finalAttrs.version;", source)
        self.assertNotIn('rev = "1.4.0"', source)

    def test_invalid_or_missing_package_remains_a_hard_error(self):
        for name in ("../escape", "..", ".", "missing"):
            with self.subTest(package=name):
                result = self.run_updates(name)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("::error::", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
