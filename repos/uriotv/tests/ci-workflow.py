#!/usr/bin/env python3
"""Offline regression tests: fake Nix/Cachix/HTTP; no builds or network calls."""
import itertools
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "scripts/build-ci.sh"
FREE = ["/nix/store/" + "a" * 32 + "-free-out", "/nix/store/" + "b" * 32 + "-free-dev"]
UNFREE = "/nix/store/" + "c" * 32 + "-unfree-out"
LOCAL = "/nix/store/" + "d" * 32 + "-local-out"
MANIFEST = [
    {"name": "freepkg", "buildable": True, "cacheable": True,
     "reason": "redistributable license", "outputs": FREE},
    {"name": "unfree", "buildable": True, "cacheable": False,
     "reason": "license does not explicitly permit redistribution", "outputs": [UNFREE]},
    {"name": "localpkg", "buildable": True, "cacheable": True,
     "reason": "redistributable license", "outputs": [LOCAL]},
    {"name": "broken", "buildable": False, "cacheable": False,
     "reason": "marked broken", "outputs": []},
]


class BuildCiTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.manifest = self.root / "manifest.json"
        self.manifest.write_text(json.dumps(MANIFEST))
        self.calls = self.root / "nix-calls"
        self.cache_calls = self.root / "cache-calls"
        self.curl_calls = self.root / "curl-calls"
        self.outputs = self.root / "outputs"
        self._stub("nix", '''import json, os, re, sys
rows = json.load(open(os.environ["FIXTURE_MANIFEST"]))
if sys.argv[1] == "eval":
    print(json.dumps(rows)); sys.exit(0)
with open(os.environ["NIX_CALLS"], "a") as f: f.write(json.dumps(sys.argv[1:]) + "\\n")
name = re.search(r'\\."([^"]+)"\\^\\*$', sys.argv[-1]).group(1)
if name == os.environ.get("FAIL_PACKAGE"): sys.exit(1)
if name == os.environ.get("BAD_JSON"): print("not json"); sys.exit(0)
paths = next(p["outputs"] for p in rows if p["name"] == name)
if name == os.environ.get("WRONG_OUTPUT"): paths = ["/nix/store/" + "e"*32 + "-wrong"]
outputs = {str(i): {"path": p} if os.environ.get("OBJECT_FORMAT") else p for i, p in enumerate(paths)}
print("Nix progress/warning on stderr", file=sys.stderr)
print(json.dumps([{"outputs": outputs}]))
''')
        self._stub("cachix", '''import json, os, sys
with open(os.environ["CACHE_CALLS"], "a") as f:
    f.write(json.dumps({"args": sys.argv[1:], "paths": sys.stdin.read().splitlines()}) + "\\n")
sys.exit(1 if os.environ.get("FAIL_CACHIX") else 0)
''')
        self._stub("curl", '''import json, os, sys
url = sys.argv[-1]
with open(os.environ["CURL_CALLS"], "a") as f: f.write(url + "\\n")
if os.environ.get("FAIL_CURL"): sys.exit(22)
if os.environ.get("WRONG_NARINFO"): print("StorePath: /nix/store/wrong"); sys.exit(0)
key = url.rsplit("/", 1)[-1]
for p in json.load(open(os.environ["FIXTURE_MANIFEST"])):
    for path in p["outputs"]:
        if key == path.rsplit("/",1)[-1].split("-",1)[0] + ".narinfo":
            print("StorePath: " + path); sys.exit(0)
sys.exit(22)
''')

    def _stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env python3\n" + body)
        path.chmod(0o755)

    def run_helper(self, event="pull_request", ref="refs/pull/1/merge", publish=False, **extra):
        env = {
            **os.environ, "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "CI_MANIFEST_PATH": str(self.manifest), "FIXTURE_MANIFEST": str(self.manifest),
            "CI_BUILT_OUTPUTS_FILE": str(self.outputs),
            "RUNNER_TEMP": str(self.root), "NIX_CALLS": str(self.calls),
            "CACHE_CALLS": str(self.cache_calls), "CURL_CALLS": str(self.curl_calls),
            "GITHUB_EVENT_NAME": event, "GITHUB_REF": ref,
            "GITHUB_STEP_SUMMARY": str(self.root / "summary.md"),
            "CI_PUBLISH_ONLY": "true" if publish else "false",
            **extra,
        }
        if publish:
            env["CACHIX_AUTH_TOKEN"] = "mock-token"
        return subprocess.run(["bash", str(HELPER)], env=env, text=True, capture_output=True)

    def built_names(self):
        return [re.search(r'\."([^"]+)"\^\*$', json.loads(line)[-1]).group(1)
                for line in self.calls.read_text().splitlines()]

    def test_builds_all_outputs_of_every_buildable_package(self):
        for fmt in ("", "1"):
            with self.subTest(object_format=fmt):
                result = self.run_helper(OBJECT_FORMAT=fmt)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(set(self.outputs.read_text().splitlines()), set(FREE + [UNFREE, LOCAL]))
                self.assertEqual(self.built_names()[-3:], ["freepkg", "unfree", "localpkg"])
                self.assertIn("Nix progress/warning", result.stderr)
                self.assertFalse(self.cache_calls.exists())
                self.assertTrue(self.manifest.exists())

    def test_build_failure_continues_other_packages_and_removes_output_list(self):
        self.outputs.write_text("stale success\n")
        result = self.run_helper(FAIL_PACKAGE="freepkg")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.built_names(), ["freepkg", "unfree", "localpkg"])
        self.assertFalse(self.outputs.exists())
        self.assertFalse(self.cache_calls.exists())
        self.assertIn("| freepkg | failed |", (self.root / "summary.md").read_text())

    def test_bad_or_unexpected_build_outputs_fail(self):
        for key in ("BAD_JSON", "WRONG_OUTPUT"):
            with self.subTest(key=key):
                result = self.run_helper(**{key: "freepkg"})
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.outputs.exists())

    def test_empty_or_invalid_manifest_fails_before_building(self):
        for value in ("[]", "not json", json.dumps([MANIFEST[0], MANIFEST[0]])):
            with self.subTest(value=value):
                self.manifest.write_text(value)
                result = self.run_helper()
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.calls.exists())

    def test_publish_pushes_only_redistributable_roots_and_checks_hash_and_storepath(self):
        self.assertEqual(self.run_helper().returncode, 0)
        result = self.run_helper("push", "refs/heads/main", publish=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        pushed = json.loads(self.cache_calls.read_text())
        self.assertEqual(pushed["args"], ["push", "uriotv"])
        self.assertEqual(set(pushed["paths"]), set(FREE + [LOCAL]))
        self.assertNotIn(UNFREE, pushed["paths"])
        urls = self.curl_calls.read_text().splitlines()
        self.assertEqual(len(urls), 3)
        self.assertTrue(all(re.fullmatch(r"https://uriotv.cachix.org/[a-z0-9]{32}\.narinfo", u) for u in urls))
        self.assertTrue(self.manifest.exists())

    def test_publish_requires_complete_build_results(self):
        self.run_helper()
        self.outputs.write_text("\n".join(FREE))
        result = self.run_helper("push", "refs/heads/main", publish=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.cache_calls.exists())

    def test_publication_errors_are_not_ignored(self):
        self.run_helper()
        for key in ("FAIL_CACHIX", "FAIL_CURL", "WRONG_NARINFO"):
            with self.subTest(key=key):
                result = self.run_helper("push", "refs/heads/main", publish=True, **{key: "1"})
                self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_forbidden_events_never_publish(self):
        for event, ref in (("pull_request", "refs/heads/main"),
                           ("workflow_dispatch", "refs/heads/feature"),
                           ("update", "refs/heads/main")):
            with self.subTest(event=event, ref=ref):
                result = self.run_helper(event, ref, publish=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(self.cache_calls.exists())


class WorkflowPolicyTests(unittest.TestCase):
    def test_gate_requires_both_jobs_and_rejects_all_unsuccessful_results(self):
        body = (ROOT / ".github/workflows/build.yml").read_text()
        gate = body.split("  test-gate:\n", 1)[1]
        self.assertIn("needs: [test-update-scripts, tests]", gate)
        self.assertIn("if: always()", gate)
        script = "\n".join(line[10:] for line in gate.split("        run: |\n", 1)[1].splitlines())
        for a, b in itertools.product(("success", "failure", "cancelled", "skipped"), repeat=2):
            with self.subTest(a=a, b=b):
                result = subprocess.run(["bash", "-c", script], capture_output=True,
                                        env={**os.environ, "UPDATE_RESULT": a, "TESTS_RESULT": b})
                self.assertEqual(result.returncode == 0, a == b == "success")

    def test_write_credentials_only_available_in_main_publish_step(self):
        body = (ROOT / ".github/workflows/build.yml").read_text()
        self.assertIn("skipPush: true", body)
        before, after = body.split("      - name: Publish eligible outputs", 1)
        self.assertNotIn("CACHIX_AUTH_TOKEN", before)
        self.assertIn("github.ref == 'refs/heads/main'", after)
        self.assertNotIn("nixos-unstable.tar.gz", body)
        self.assertIn("needs: test-update-scripts", before)
        update = (ROOT / ".github/workflows/update.yml").read_text()
        self.assertNotIn("CACHIX_AUTH_TOKEN", update)
        self.assertNotIn("|| secrets.GITHUB_TOKEN", update)
        self.assertIn("steps.cpr.outputs.pull-request-number", update)
        self.assertIn("steps.update.outputs.update_failures", update)


if __name__ == "__main__":
    unittest.main(verbosity=2)
