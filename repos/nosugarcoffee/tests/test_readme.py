"""The README's package table lists exactly the packages under pkgs/."""

from __future__ import annotations

import re
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]


class ReadmeTableTest(unittest.TestCase):
    def test_table_matches_pkgs(self) -> None:
        readme = (REPO / "README.md").read_text()
        listed = set(re.findall(r"^\| \[`([^`]+)`\]", readme, flags=re.MULTILINE))
        packages = {p.name for p in (REPO / "pkgs").iterdir() if p.is_dir()}
        self.assertEqual(listed, packages, "README.md package table is out of sync with pkgs/")


if __name__ == "__main__":
    unittest.main()
