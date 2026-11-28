#!/usr/bin/env python3
"""Offline checks for the Vantage package layout and its branch-tracking updater."""
import re
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXPRESSION = ROOT / "pkgs/vantage/default.nix"
UPDATER = ROOT / "pkgs/vantage/update.sh"


class VantagePackageTests(unittest.TestCase):
    def setUp(self):
        self.text = EXPRESSION.read_text()

    def test_installs_where_kwin_and_plasma_look_for_it(self):
        self.assertIn("share/kwin/effects/vantage", self.text)
        self.assertIn("share/kwin/scripts/vantage-script", self.text)
        self.assertIn(
            "share/plasma/plasmoids/io.github.vazark.vantage.launcher", self.text)
        self.assertIn(
            "share/plasma/plasmoids/io.github.vazark.vantage.power", self.text)

    def test_keeps_the_tree_together_for_relative_lookups(self):
        # scripts/apply-*.sh resolve presets/ as dirname($0)/.. and
        # tweaks/vantage_config.py reads effect/contents/config/main.xml the same way.
        self.assertIn("tree = \"$out/share/vantage\"", self.text)
        for directory in ("effect", "script", "plasmoid", "scripts", "presets", "tweaks"):
            with self.subTest(directory=directory):
                self.assertRegex(self.text, rf"cp -r [^\n]*\b{directory}\b[^\n]*\$\{{tree\}}")

    def test_replaces_the_missing_qdbus6(self):
        # Upstream calls qdbus6; Qt 6 ships that client as `qdbus` (qttools).
        self.assertIn("qdbus6", self.text)
        self.assertIn("kdePackages.qttools", self.text)
        self.assertIn("kdePackages.kconfig", self.text)  # kwriteconfig6/kreadconfig6

    def test_tweaks_window_is_wrapped_with_pyside6(self):
        self.assertIn("python3.withPackages (ps: [ ps.pyside6 ])", self.text)
        self.assertIn('"$out/bin/vantage-tweaks"', self.text)
        self.assertIn("--add-flags ${tree}/tweaks/vantage-tweaks", self.text)

    def test_desktop_entry_starts_the_wrapper(self):
        self.assertIn('exec = "vantage-tweaks"', self.text)
        self.assertIn("share/applications/vantage-tweaks.desktop", self.text)

    def test_does_not_ship_screenshots_or_agent_docs(self):
        # The repository carries 6.5 MB of screenshots and Claude/agent notes.
        self.assertNotIn("screenshots", self.text)
        self.assertNotIn("CLAUDE.md", self.text)

    def test_version_follows_the_commit_date(self):
        self.assertRegex(self.text, r'version = "0-unstable-\d{4}-\d{2}-\d{2}";')
        self.assertRegex(self.text, r'rev = "[0-9a-f]{40}";')

    def test_updater_tracks_the_branch(self):
        updater = UPDATER.read_text()
        self.assertTrue(UPDATER.stat().st_mode & 0o111)
        self.assertIn("set -euo pipefail", updater)
        self.assertRegex(updater, r"nix-update --flake vantage --version=branch")


if __name__ == "__main__":
    unittest.main(verbosity=2)
