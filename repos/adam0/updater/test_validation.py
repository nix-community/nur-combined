from __future__ import annotations

import unittest
from dataclasses import replace
from unittest.mock import patch

from .models import PackageState
from .validation import validate_transition


class SourceTransitionTests(unittest.TestCase):
    def validate(self, before, after):
        with patch("updater.validation.version_is_older", return_value=False):
            return validate_transition(
                before, after, package_files_changed=True, unrelated_files_changed=False
            )

    def test_release_bump_cannot_keep_the_old_commit_and_hash(self):
        before = PackageState(
            version="0.12.1", version_mode="stable", src_rev="old", src_hash="sha256-old"
        )
        result = self.validate(before, replace(before, version="0.13.0"))
        self.assertFalse(result.accepted)
        self.assertEqual(result.reason, "rejected version change without source change")

    def test_hash_only_change_does_not_make_a_release_bump_valid(self):
        before = PackageState(version="0.12.1", version_mode="stable", src_rev="old")
        result = self.validate(before, replace(before, version="0.13.0", src_hash="sha256-new"))
        self.assertFalse(result.accepted)

    def test_release_bump_with_new_source_allows_dependency_refresh(self):
        before = PackageState(version="0.12.1", version_mode="stable", src_rev="old")
        result = self.validate(before, replace(before, version="0.13.0", src_rev="new"))
        self.assertTrue(result.accepted)
        self.assertTrue(result.dependency_hash_refresh_allowed)

    def test_packages_without_a_source_can_change_version(self):
        before = PackageState(version="1", version_mode="stable")
        self.assertTrue(self.validate(before, replace(before, version="2")).accepted)


class ValidationStatusTests(unittest.TestCase):
    def test_status_classification(self):
        stable = PackageState("1.0", "stable", src_rev="old", dependency_hash="old")
        branch = PackageState("1.0-unstable-2026-01-01", "branch", src_rev="old")
        cases = [
            (stable, stable, False, False, "skipped"),
            (stable, stable, True, True, "invalid"),
            (stable, replace(stable, dependency_hash="new"), True, False, "skipped"),
            (branch, replace(branch, version="2.0-unstable-2026-01-01"), True, False, "skipped"),
            (branch, replace(branch, version="1.0-unstable-2026-01-02"), True, False, "skipped"),
            (
                branch,
                replace(branch, version="2.0-unstable-2026-01-02", src_rev="new"),
                True,
                False,
                "invalid",
            ),
            (branch, replace(branch, version="unrecognized"), True, False, "invalid"),
            (stable, replace(stable, version="2.0"), True, False, "invalid"),
            (stable, replace(stable, src_rev="new"), True, False, "updated"),
        ]
        with patch("updater.validation.version_is_older", return_value=False):
            for before, after, changed, unrelated, expected in cases:
                with self.subTest(after=after, changed=changed, unrelated=unrelated):
                    result = validate_transition(
                        before,
                        after,
                        package_files_changed=changed,
                        unrelated_files_changed=unrelated,
                    )
                    self.assertEqual(result.status, expected)
                    self.assertEqual(result.accepted, expected == "updated")

    def test_downgrade_is_skipped(self):
        before = PackageState("2.0", "stable", src_rev="old")
        with patch("updater.validation.version_is_older", return_value=True):
            result = validate_transition(
                before,
                replace(before, version="1.0", src_rev="new"),
                package_files_changed=True,
                unrelated_files_changed=False,
            )
        self.assertEqual(result.status, "skipped")


if __name__ == "__main__":
    unittest.main()
