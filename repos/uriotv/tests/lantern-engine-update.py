#!/usr/bin/env python3
"""Regression tests for Lantern Engine's upstream Avalonia resource URI change."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LanternEngineUpdateTests(unittest.TestCase):
    def test_launcher_does_not_require_obsolete_resource_uri(self):
        launcher = (ROOT / "pkgs/lantern-engine/launcher.nix").read_text()
        self.assertNotIn("avares://Lantern Engine/", launcher)
        self.assertNotIn("--replace-fail 'avares://", launcher)

    def test_package_tracks_latest_known_stable_version_and_source_hash(self):
        package = (ROOT / "pkgs/lantern-engine/default.nix").read_text()
        self.assertIn('version = "0.9.42";', package)
        self.assertRegex(package, r'hash = "sha256-[A-Za-z0-9+/]{43}=";')

    def test_updater_refreshes_version_and_nuget_lock(self):
        updater = (ROOT / "pkgs/lantern-engine/update.sh").read_text()
        self.assertIn("releases/latest", updater)
        self.assertIn("nix-update --flake lantern-engine", updater)
        self.assertIn("launcher.fetch-deps", updater)
        self.assertIn("deps.json", updater)


if __name__ == "__main__":
    unittest.main()
