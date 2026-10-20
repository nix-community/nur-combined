#!/usr/bin/env python3
"""Offline Nix evaluation tests. No fetching or building; needs only the Nix CLI."""
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def evaluate(expression, check=True):
    return subprocess.run(["nix", "eval", "--offline", "--impure", "--json",
                           "--extra-experimental-features", "nix-command", "--expr", expression],
                          capture_output=True, text=True, check=check)


class RegistryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copy(ROOT / "pkgs/default.nix", self.root / "default.nix")

    def names(self, check=True):
        return evaluate(f'''builtins.attrNames (import {self.root} {{
          pkgs.callPackage = path: args: {{ }};
        }})''', check)

    def package(self, name):
        p = self.root / name
        p.mkdir()
        (p / "default.nix").write_text("{}")

    def test_new_package_is_automatically_registered_and_nonpackages_are_ignored(self):
        self.package("alpha")
        (self.root / "scratch").mkdir()
        (self.root / "not-a-directory.nix").write_text("{}")
        self.assertEqual(json.loads(self.names().stdout), ["alpha"])
        self.package("new-package")
        self.assertEqual(json.loads(self.names().stdout), ["alpha", "new-package"])
        (self.root / "symlink").symlink_to(self.root / "alpha", target_is_directory=True)
        self.assertEqual(json.loads(self.names().stdout), ["alpha", "new-package"])

    def test_reserved_and_invalid_names_are_rejected(self):
        for name in ("lib", "rimsort", "bad name"):
            with self.subTest(name=name):
                self.package(name)
                self.assertNotEqual(self.names(check=False).returncode, 0)
                shutil.rmtree(self.root / name)

    def test_nur_overlay_and_registry_export_the_same_packages(self):
        data = json.loads(evaluate(f'''let
          pkgs = {{ callPackage = path: args: {{ }}; lib = {{ }}; }};
          names = builtins.attrNames;
        in {{
          registry = names (import {ROOT}/pkgs {{ inherit pkgs; }});
          nur = builtins.filter (n: !(builtins.elem n [ "lib" "modules" "overlays" ]))
            (names (import {ROOT} {{ inherit pkgs; }}));
          overlay = builtins.filter (n: n != "rimsort")
            (names ((import {ROOT}/overlays).default pkgs {{ }}));
        }}''').stdout)
        self.assertEqual(data["registry"], data["nur"])
        self.assertEqual(data["registry"], data["overlay"])
        self.assertEqual(data["registry"], sorted(p.name for p in (ROOT / "pkgs").iterdir()
                                                 if p.is_dir() and (p / "default.nix").is_file()))


if __name__ == "__main__":
    unittest.main(verbosity=2)
