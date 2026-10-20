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


if __name__ == "__main__":
    unittest.main()
