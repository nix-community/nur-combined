from __future__ import annotations

import subprocess
import tempfile
import unittest
from contextlib import ExitStack
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

from .models import PackageRef, PackageState, ValidationResult
from .package_backend import _run_nix_update, _tag_version_regex, update_package
from .process import CommandError


class PackageTransactionTests(unittest.TestCase):
    def setUp(self):
        self.stack = ExitStack()
        self.addCleanup(self.stack.close)
        directory = self.stack.enter_context(tempfile.TemporaryDirectory())
        self.path = Path(directory) / "default.nix"
        self.path.write_text("original")
        self.ref = PackageRef("file", "packages", "example", "packages.example", self.path)
        before = PackageState("1.0", "stable", src_rev="old")
        after = replace(before, version="2.0", src_rev="new")
        self.stack.enter_context(
            patch("updater.package_backend.read_state", side_effect=[before, after])
        )
        self.stack.enter_context(
            patch("updater.transactions.git_changed_files", return_value=set())
        )
        self.stack.enter_context(
            patch("updater.package_backend.latest_release_prefix_for_url", return_value=None)
        )
        self.update = self.stack.enter_context(
            patch("updater.package_backend._run_nix_update", side_effect=self.write_update)
        )
        self.verify = self.stack.enter_context(
            patch("updater.package_backend._update_source_with_verification", return_value=None)
        )
        self.validate = self.stack.enter_context(
            patch(
                "updater.package_backend.validate_transition",
                return_value=ValidationResult("updated", "accepted", True),
            )
        )
        self.refresh_files = self.stack.enter_context(
            patch("updater.package_backend._refresh_source_files")
        )
        self.refresh_hashes = self.stack.enter_context(
            patch("updater.package_backend._refresh_dependency_hashes")
        )

    def write_update(self, *args, **kwargs):
        self.path.write_text("updated")

    def command_error(self):
        return CommandError(["test"], subprocess.CompletedProcess([], 1, "", "failed"))

    def test_accepted_update_is_committed(self):
        result = update_package(self.ref)
        self.assertEqual(result.status, "updated")
        self.assertEqual(result.changed_files, [self.path])
        self.assertEqual(self.path.read_text(), "updated")
        self.refresh_hashes.assert_called_once()

    def test_dry_run_reports_changes_but_restores_files(self):
        result = update_package(self.ref, dry_run=True)
        self.assertEqual(result.status, "updated")
        self.assertEqual(result.changed_files, [self.path])
        self.assertEqual(self.path.read_text(), "original")

    def test_validation_status_is_independent_of_reason_text(self):
        self.validate.return_value = ValidationResult("skipped", "arbitrary new wording")
        result = update_package(self.ref)
        self.assertEqual(result.status, "skipped")
        self.assertEqual(result.reason, "arbitrary new wording")
        self.assertEqual(self.path.read_text(), "original")
        self.refresh_hashes.assert_not_called()

    def test_rejected_transition_is_restored(self):
        self.validate.return_value = ValidationResult("invalid", "rejected")
        self.assertEqual(update_package(self.ref).status, "invalid")
        self.assertEqual(self.path.read_text(), "original")

    def test_source_verification_failure_is_restored(self):
        self.verify.return_value = "source failed"
        self.assertEqual(update_package(self.ref).status, "failed")
        self.assertEqual(self.path.read_text(), "original")

    def test_command_failure_after_partial_edit_is_restored(self):
        def fail(*args, **kwargs):
            self.write_update()
            raise self.command_error()

        self.update.side_effect = fail
        self.assertEqual(update_package(self.ref).status, "skipped")
        self.assertEqual(self.path.read_text(), "original")

    def test_source_file_refresh_failure_is_restored(self):
        self.refresh_files.side_effect = ValueError("invalid source file")
        self.assertEqual(update_package(self.ref).status, "failed")
        self.assertEqual(self.path.read_text(), "original")

    def test_dependency_refresh_failure_is_restored(self):
        self.refresh_hashes.side_effect = self.command_error()
        self.assertEqual(update_package(self.ref).status, "failed")
        self.assertEqual(self.path.read_text(), "original")

    def test_unhandled_exception_after_edit_is_restored_and_propagated(self):
        self.verify.side_effect = ValueError("bad state")
        with self.assertRaisesRegex(ValueError, "bad state"):
            update_package(self.ref)
        self.assertEqual(self.path.read_text(), "original")


class TagVersionRegexTests(unittest.TestCase):
    def test_monorepo_tag_prefix_becomes_a_version_regex(self):
        state = PackageState("0.6.1", "stable", src_rev="cargo-bp-v0.6.1")
        self.assertEqual(_tag_version_regex(state), r"^cargo\-bp\-v(.+)$")

    def test_plain_and_v_tags_need_no_regex(self):
        for rev in ("0.6.1", "v0.6.1", "0123abcd"):
            with self.subTest(rev=rev):
                self.assertIsNone(_tag_version_regex(PackageState("0.6.1", "stable", src_rev=rev)))

    def test_branch_packages_need_no_regex(self):
        state = PackageState("0-unstable-2026-01-01", "branch", src_rev="x0-unstable-2026-01-01")
        self.assertIsNone(_tag_version_regex(state))

    def test_regex_reaches_nix_update(self):
        ref = PackageRef(
            "flake",
            "packages.x86_64-linux",
            "cargo-bp",
            "packages.x86_64-linux.cargo-bp",
            Path("default.nix"),
        )
        with patch("updater.package_backend.run") as run:
            _run_nix_update(ref, "stable", timeout=None, version_regex="^cargo-bp-v(.+)$")
        command = run.call_args.args[0]
        self.assertIn("--version-regex=^cargo-bp-v(.+)$", command)
        self.assertEqual(command[-1], ref.attr_path)


if __name__ == "__main__":
    unittest.main()
