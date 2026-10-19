#!/usr/bin/env python3
"""Offline tests: kernel pins update together and failed builds block the gate."""

import importlib.util
import json
import os
import re
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = ROOT / "pkgs/linux-cachyos-bore-x86_64-v3"
spec = importlib.util.spec_from_file_location("kernel_update", PACKAGE / "update.py")
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


class KernelUpdateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.snapshot = self.root / "upstream"
        self.snapshot.mkdir()
        self.old = {
            "rev": "a" * 40, "hash": "sha256-" + "A" * 43 + "=",
            "version": "7.2.10",
            "nixpkgs": {"rev": "b" * 40, "narHash": "sha256-" + "B" * 43 + "="},
        }
        (self.snapshot / "source.json").write_text(json.dumps(self.old))
        (self.snapshot / "sentinel").write_text("preserved")
        self.new_rev = "c" * 40

    def response(self, url):
        if "/commits/" in url:
            return {"sha": self.new_rev}
        if url.endswith("version.json"):
            return {"linux-cachyos-bore": {"version": "7.2.11"}}
        return {"nodes": {"root": {"inputs": {"nixpkgs": "kernel-pkgs"}}, "kernel-pkgs": {
            "locked": {"owner": "NixOS", "repo": "nixpkgs", "rev": "d" * 40,
                       "narHash": "sha256-" + "D" * 43 + "="}}}}

    def run_update(self, content=None):
        prefetch = subprocess.CompletedProcess([], 0, json.dumps({"hash": "sha256-" + "C" * 43 + "="}))
        with patch.object(updater, "__file__", str(self.root / "update.py")), \
             patch.object(updater, "request_json", side_effect=self.response), \
             patch.object(updater, "request_bytes", side_effect=content or (lambda _: b"snapshot")), \
             patch.object(updater.subprocess, "run", return_value=prefetch):
            updater.main()

    def test_updates_sources_version_and_compiler_from_one_revision(self):
        seen = []

        def download(url):
            seen.append(url)
            return b"new immutable source"

        self.run_update(download)
        pin = json.loads((self.snapshot / "source.json").read_text())
        self.assertEqual(pin["rev"], self.new_rev)
        self.assertEqual(pin["version"], "7.2.11")
        self.assertEqual(pin["nixpkgs"]["rev"], "d" * 40)
        self.assertEqual(len(seen), len(updater.VENDORED_FILES))
        self.assertTrue(all(f"/{self.new_rev}/" in url for url in seen))
        self.assertFalse((self.snapshot / "sentinel").exists())
        for name in updater.VENDORED_FILES:
            self.assertEqual((self.snapshot / name).read_bytes(), b"new immutable source")

    def test_failed_snapshot_download_preserves_entire_previous_snapshot(self):
        def fail(url):
            raise OSError("upstream unavailable")

        with self.assertRaises(OSError):
            self.run_update(fail)
        self.assertEqual(json.loads((self.snapshot / "source.json").read_text()), self.old)
        self.assertEqual((self.snapshot / "sentinel").read_text(), "preserved")
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), ["upstream"])

    def test_rejects_mutable_refs_invalid_hashes_and_prereleases(self):
        for changes in ({"rev": "master"}, {"hash": "invalid"}, {"version": "7.3-rc1"}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                updater.validate_pin(self.old | changes)


class KernelGateTests(unittest.TestCase):
    def test_gate_needs_kernel_and_rejects_failure_cancelled_or_skipped(self):
        workflow = (ROOT / ".github/workflows/build.yml").read_text()
        gate = workflow.split("  test-gate:\n", 1)[1].split("\n  tests:\n", 1)[0]
        self.assertIn("      - kernel\n", gate)
        self.assertIn("    if: always()", gate)
        script = gate.split("        run: |\n", 1)[1]
        script = "\n".join(line[10:] for line in script.splitlines())
        for job in ("test-update-scripts", "tests", "kernel"):
            for outcome in ("success", "failure", "cancelled", "skipped"):
                with self.subTest(job=job, outcome=outcome):
                    rendered = script
                    for name in ("test-update-scripts", "tests", "kernel"):
                        rendered = rendered.replace(
                            "${{ needs." + name + ".result }}", outcome if name == job else "success"
                        )
                    result = subprocess.run(["bash", "-c", rendered], capture_output=True)
                    self.assertEqual(result.returncode == 0, outcome == "success")
        tests_job = workflow.split("\n  tests:\n", 1)[1]
        self.assertNotIn("needs: test-gate", tests_job)

    def test_publication_is_main_only_and_includes_every_output_and_sources(self):
        workflow = (ROOT / ".github/workflows/kernel.yml").read_text()
        self.assertIn("github.event_name != 'pull_request' && github.ref == 'refs/heads/main'", workflow)
        # Cachix is read-only in the shared setup action (asserted below).
        self.assertIn("uses: ./.github/actions/setup-nix-nixbuild", workflow)
        self.assertIn("linux-cachyos-bore-x86_64-v3^*", workflow)
        self.assertIn("linux-cachyos-bore-x86_64-v3.src", workflow)
        self.assertIn("linux-cachyos-bore-x86_64-v3.urioUpstreamSource", workflow)
        self.assertIn("StorePath: $path", workflow)


class NixbuildCiTests(unittest.TestCase):
    SETUP = "uses: ./.github/actions/setup-nix-nixbuild"
    BUILDS = ("nix build", "nix-build", "update-packages.sh")

    def test_every_building_workflow_uses_nixbuild_without_local_fallback(self):
        for path in sorted((ROOT / ".github/workflows").glob("*.yml")):
            workflow = path.read_text()
            with self.subTest(workflow=path.name):
                if any(command in workflow for command in self.BUILDS):
                    self.assertIn(self.SETUP, workflow)
                    self.assertIn("nixbuild_token: ${{ secrets.NIXBUILD_TOKEN }}", workflow)
                    # Nix must come only from the shared action (no second, local-build setup).
                    self.assertNotIn("cachix/install-nix-action", workflow)
                    self.assertNotIn("cachix/cachix-action", workflow)
                    self.assertNotIn("cores = ", workflow)
                else:
                    self.assertNotIn("nixbuild", workflow.replace("nixbuild.net builder", ""))

    def test_shared_action_requires_token_and_disables_local_builds(self):
        action = (ROOT / ".github/actions/setup-nix-nixbuild/action.yml").read_text()
        steps = ["Require nixbuild.net token", "nixbuild/nix-quick-install-action@",
                 "cachix/cachix-action@", "nixbuild/nixbuild-action@",
                 "Verify that no build can run on the runner"]
        # A multi-user daemon cannot use nixbuild-action's SSH config.
        self.assertNotIn("uses: cachix/install-nix-action", action)
        self.assertIn("daemon-socket", action)
        positions = [action.index(step) for step in steps]
        self.assertEqual(positions, sorted(positions))
        self.assertIn("skipPush: true", action)
        self.assertIn('[ "$max_jobs" = 0 ]', action)
        self.assertNotIn("authToken", action)
        # The script ends at the next step or comment (indented 4 spaces).
        check = re.split(r"\n    \S", action.split("      run: |\n", 1)[1], maxsplit=1)[0]
        check = "\n".join(line[8:] for line in check.splitlines())
        for token, ok in (("", False), ("secret", True)):
            with self.subTest(token=bool(token)):
                result = subprocess.run(["bash", "-c", check], capture_output=True,
                                        env={"NIXBUILD_TOKEN": token, "PATH": os.environ["PATH"]})
                self.assertEqual(result.returncode == 0, ok)

    def test_cachix_writes_are_explicit_and_main_only(self):
        for name in ("build.yml", "kernel.yml"):
            workflow = (ROOT / ".github/workflows" / name).read_text()
            with self.subTest(workflow=name):
                publish = workflow.split("cachix push", 1)[0].rsplit("- name:", 1)[1]
                self.assertIn("github.event_name != 'pull_request' && github.ref == 'refs/heads/main'", publish)


if __name__ == "__main__":
    unittest.main(verbosity=2)
