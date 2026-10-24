#!/usr/bin/env python3
"""Offline tests for the README package version table (no Nix)."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = REPO_ROOT / "scripts/readme-versions.py"

README = """# title

| Package | Version | Description | Public cache |
|---|---|---|---|
| `alpha` | `0.1` | First | Yes |
| `beta` |  | Second | No: unfree |

After the table.
"""


class ReadmeVersionsTests(unittest.TestCase):
    def run_script(self, mode, readme, versions):
        with tempfile.TemporaryDirectory() as directory:
            readme_path = Path(directory) / "README.md"
            manifest_path = Path(directory) / "manifest.json"
            readme_path.write_text(readme)
            manifest_path.write_text(json.dumps(versions))
            result = subprocess.run(
                ["python3", "-B", str(SCRIPT), mode,
                 "--manifest", str(manifest_path), "--readme", str(readme_path)],
                text=True,
                capture_output=True,
                check=False,
            )
            return result, readme_path.read_text()

    def test_write_fills_versions_from_ci_manifest(self):
        manifest = [{"name": "alpha", "version": "0.2"}, {"name": "beta", "version": "1.0"}]

        result, readme = self.run_script("--write", README, manifest)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("| `alpha` | `0.2` | First | Yes |", readme)
        self.assertIn("| `beta` | `1.0` | Second | No: unfree |", readme)
        self.assertTrue(readme.endswith("After the table.\n"))

    def test_check_fails_on_stale_version_without_writing(self):
        result, readme = self.run_script("--check", README, {"alpha": "0.2", "beta": "1.0"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("stale", result.stderr)
        self.assertEqual(readme, README)

    def test_check_passes_when_current(self):
        _, current = self.run_script("--write", README, {"alpha": "0.1", "beta": "1.0"})

        result, _ = self.run_script("--check", current, {"alpha": "0.1", "beta": "1.0"})

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_registry_package_missing_from_readme_fails(self):
        result, _ = self.run_script(
            "--write", README, {"alpha": "0.1", "beta": "1.0", "gamma": "2"}
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("gamma", result.stderr)

    def test_readme_row_without_registry_package_fails(self):
        result, _ = self.run_script("--write", README, {"alpha": "0.1"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("beta", result.stderr)

    def test_unknown_version_fails(self):
        result, _ = self.run_script("--write", README, {"alpha": "unknown", "beta": "1.0"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("alpha", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
