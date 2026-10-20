#!/usr/bin/env python3
"""Compatibility tests are offline and never install/resolve Bun dependencies."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("storyforge_compatibility", ROOT / "pkgs/storyforge/compatibility.py")
compat = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compat)


class CompatibilityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.lock = {
            "lockfileVersion": 2, "configVersion": 1,
            "workspaces": {"": {"dependencies": {"better-auth": "^1.7.6"}}},
            "packages": {"better-auth": ["better-auth@1.7.7", "", {}, "sha512-test"]},
        }
        self.package = {"dependencies": {"better-auth": "^1.7.7"}}
        self.write()

    def write(self):
        (self.root / "bun.lock").write_text(json.dumps(self.lock))
        (self.root / "package.json").write_text(json.dumps(self.package))

    def test_jsonc_comments_commas_and_escaped_strings(self):
        text = r'''{"url":"https://example.org/a,]", // comment
                    "escaped":"a\"/*not-comment*/", /* block */ "list":[1,2,],}'''
        self.assertEqual(compat.parse_jsonc(text), {
            "url": "https://example.org/a,]", "escaped": 'a"/*not-comment*/', "list": [1, 2],
        })

    def test_duplicates_and_unknown_json_syntax_are_rejected(self):
        for text in ('{"x":1,"x":2}', '{/* unterminated', "{'json5':true}"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                compat.parse_jsonc(text)

    def test_plan_changes_only_header_and_reviewed_requirement(self):
        before = copy.deepcopy(self.lock)
        plan = compat.make_plan(self.root)
        compat.apply_plan(self.root, plan)
        after = compat.parse_jsonc((self.root / "bun.lock").read_text())
        before["lockfileVersion"] = 1
        self.assertEqual(before, after)
        self.assertEqual(after["packages"]["better-auth"][0], "better-auth@1.7.7")
        self.assertEqual(json.loads((self.root / "package.json").read_text())["dependencies"]["better-auth"], "^1.7.6")

    def test_fixed_upstream_dependency_needs_no_adjustment(self):
        self.package["dependencies"]["better-auth"] = "^1.7.6"
        self.write()
        original = (self.root / "package.json").read_bytes()
        plan = compat.make_plan(self.root)
        self.assertIsNone(plan["betterAuth"])
        compat.apply_plan(self.root, plan)
        self.assertEqual(original, (self.root / "package.json").read_bytes())

    def test_version_one_and_removed_auth_dependency_are_valid_noops(self):
        self.lock["lockfileVersion"] = 1
        self.lock["workspaces"][""]["dependencies"] = {}
        self.package["dependencies"] = {}
        self.write()
        before = {n: (self.root / n).read_bytes() for n in ("bun.lock", "package.json")}
        compat.apply_plan(self.root, compat.make_plan(self.root))
        self.assertEqual(before, {n: (self.root / n).read_bytes() for n in before})

    def test_changed_input_or_arbitrary_plan_cannot_be_applied(self):
        plan = compat.make_plan(self.root)
        forged = copy.deepcopy(plan)
        forged["betterAuth"]["to"] = "*"
        with self.assertRaises(ValueError):
            compat.apply_plan(self.root, forged)
        (self.root / "bun.lock").write_text((self.root / "bun.lock").read_text() + "\n")
        with self.assertRaises(ValueError):
            compat.apply_plan(self.root, plan)

    def test_unknown_compatibility_schemas_and_mismatches_fail_closed(self):
        for failure in ("header", "config", "auth", "packages", "workspace"):
            with self.subTest(failure=failure):
                lock, package = copy.deepcopy(self.lock), copy.deepcopy(self.package)
                if failure == "header":
                    self.lock["lockfileVersion"] = 3
                elif failure == "config":
                    self.lock["configVersion"] = 2
                elif failure == "auth":
                    self.package["dependencies"]["better-auth"] = "^9.0.0"
                elif failure == "packages":
                    self.lock.pop("packages")
                else:
                    self.lock.pop("workspaces")
                self.write()
                with self.assertRaises(ValueError):
                    compat.make_plan(self.root)
                self.lock, self.package = lock, package

    def test_check_only_preserves_every_byte(self):
        before = {p.name: p.read_bytes() for p in self.root.iterdir()}
        compat.apply_plan(self.root, compat.make_plan(self.root), check_only=True)
        self.assertEqual(before, {p.name: p.read_bytes() for p in self.root.iterdir()})


if __name__ == "__main__":
    unittest.main(verbosity=2)
