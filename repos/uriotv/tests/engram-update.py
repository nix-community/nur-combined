#!/usr/bin/env python3
"""Offline tests for Engram release selection and its source-built package."""
import json
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
SELECTOR = ROOT / "pkgs/engram/latest-release.py"
EXPRESSION = ROOT / "pkgs/engram/default.nix"


class EngramReleaseSelectionTests(unittest.TestCase):
    def select(self, releases):
        return subprocess.run(["python3", str(SELECTOR)], input=json.dumps(releases),
                              text=True, capture_output=True, check=False)

    def test_ignores_unrelated_tags_and_prereleases(self):
        # Upstream publishes its own `pi-v*` release line in this repository.
        result = self.select([
            {"tag_name": "pi-v0.9.0", "draft": False, "prerelease": False},
            {"tag_name": "v3.7.1", "draft": False, "prerelease": False},
            {"tag_name": "v4.0.0-rc.1", "draft": False, "prerelease": False},
            {"tag_name": "v3.8.0", "draft": True, "prerelease": False},
        ])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "3.7.1")

    def test_selects_numerically_newest(self):
        result = self.select([
            {"tag_name": "v3.7.9"},
            {"tag_name": "v3.10.0"},
            {"tag_name": "v3.9.9"},
        ])
        self.assertEqual(result.stdout.strip(), "3.10.0")

    def test_fails_without_a_stable_release(self):
        result = self.select([{"tag_name": "pi-v0.9.0"}, {"tag_name": "v1.0.0-beta.1"}])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No stable Engram release", result.stderr)

    def test_rejects_malformed_payload(self):
        result = subprocess.run(["python3", str(SELECTOR)], input="not json",
                                text=True, capture_output=True, check=False)
        self.assertNotEqual(result.returncode, 0)


class EngramPackageTests(unittest.TestCase):
    def test_builds_from_tagged_source(self):
        text = EXPRESSION.read_text()
        self.assertIn("buildGoModule", text)
        self.assertIn('tag = "v${finalAttrs.version}"', text)
        self.assertIn('subPackages = [ "cmd/engram" ]', text)
        self.assertNotIn("fetchurl", text)
        self.assertNotIn("engram_${", text)
        self.assertNotIn("lib.fakeHash", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
