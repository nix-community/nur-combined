#!/usr/bin/env python3
"""Offline tests for the kernel closure publication gate."""
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/check-kernel-closure.py"
spec = importlib.util.spec_from_file_location("kernel_closure_gate", SCRIPT)
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)

A = "/nix/store/00000000000000000000000000000000-kernel-out"
B = "/nix/store/11111111111111111111111111111111-kernel-modules"
C = "/nix/store/22222222222222222222222222222222-runtime"
UNKNOWN = "/nix/store/33333333333333333333333333333333-unknown"


class GateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.manifest = {"roots": [A, B], "entries": [
            self.entry(A, "kernel", True, ["GPL-2.0-only"]),
            self.entry(B, "modules", True, ["GPL-2.0-only"]),
            self.entry(C, "runtime", True, ["MIT"]),
        ]}
        self.closure = [A, B, C]
        self.built = [A, B]
        self.expected = [A, B]

    @staticmethod
    def entry(path, name, allowed, licenses):
        return {"path": path, "name": name, "redistributable": allowed, "licenses": licenses}

    def run_gate(self):
        files = {
            "manifest.json": json.dumps(self.manifest),
            "closure.txt": "".join(p + "\n" for p in self.closure),
            "built.txt": "".join(p + "\n" for p in self.built),
            "expected.json": json.dumps(self.expected),
        }
        for name, content in files.items():
            (self.base / name).write_text(content, encoding="utf-8")
        return gate.run(*(str(self.base / name) for name in
                          ("manifest.json", "closure.txt", "built.txt", "expected.json")))

    def test_all_outputs_and_used_dependencies_pass(self):
        self.assertEqual(self.run_gate(), (2, 3))

    def test_unknown_closure_path_blocks(self):
        self.closure.append(UNKNOWN)
        with self.assertRaises(gate.GateError) as raised:
            self.run_gate()
        # The log must name the path, not only count it.
        self.assertIn(UNKNOWN.removeprefix("/nix/store/"), str(raised.exception))

    def test_used_unfree_dependency_blocks(self):
        self.manifest["entries"][2]["redistributable"] = False
        with self.assertRaises(gate.GateError):
            self.run_gate()

    def test_empty_license_metadata_blocks_used_path(self):
        self.manifest["entries"][0]["licenses"] = []
        with self.assertRaises(gate.GateError):
            self.run_gate()

    def test_malformed_empty_data_blocks(self):
        self.closure = []
        with self.assertRaises(gate.GateError):
            self.run_gate()
        self.closure = [A, B, C]
        self.manifest["roots"] = []
        with self.assertRaises(gate.GateError):
            self.run_gate()

    def test_contradictory_duplicate_entry_blocks(self):
        self.manifest["entries"].append(self.entry(C, "runtime", False, ["MIT"]))
        with self.assertRaises(gate.GateError):
            self.run_gate()

    def test_incomplete_output_lists_block(self):
        self.built = [A]
        with self.assertRaises(gate.GateError):
            self.run_gate()
        self.built = [A, B]
        self.expected = [A]
        with self.assertRaises(gate.GateError):
            self.run_gate()

    def test_root_absent_from_closure_blocks(self):
        self.closure.remove(B)
        with self.assertRaises(gate.GateError):
            self.run_gate()

    def test_unused_unfree_metadata_does_not_block(self):
        self.manifest["entries"].append(self.entry(
            "/nix/store/44444444444444444444444444444444-unused", "unused", False, ["LicenseRef-Proprietary"]))
        self.assertEqual(self.run_gate(), (2, 3))

    def test_malformed_store_path_blocks(self):
        self.closure[2] = "/nix/store/not-a-store-path"
        with self.assertRaises(gate.GateError):
            self.run_gate()


if __name__ == "__main__":
    unittest.main()
