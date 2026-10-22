#!/usr/bin/env python3
"""Offline tests for the private attic mirror helper. Stubbed client; no network."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "scripts/attic-push.sh"
TOKEN = "test-token-not-a-secret"
GOOD = ["/nix/store/" + "a" * 32 + "-kernel-out", "/nix/store/" + "b" * 32 + "-kernel-dev"]


class AtticPushTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.calls = self.root / "calls"
        self.paths = self.root / "paths"
        self.paths.write_text("".join(p + "\n" for p in GOOD))
        stub = self.bin / "attic"
        stub.write_text(
            "#!/usr/bin/env python3\n"
            "import os, sys\n"
            "with open(os.environ['CALLS'], 'a') as f:\n"
            "    f.write(repr({'argv': sys.argv[1:], 'config': os.environ.get('XDG_CONFIG_HOME')}) + '\\n')\n"
            "if sys.argv[1] == 'push' and os.environ.get('FAIL_PUSH'):\n"
            "    sys.exit(3)\n"
        )
        stub.chmod(0o755)

    def run_helper(self, paths=None, **env):
        return subprocess.run(
            ["bash", str(HELPER), str(paths or self.paths)], text=True, capture_output=True,
            env={**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}",
                 "CALLS": str(self.calls), "GITHUB_STEP_SUMMARY": str(self.root / "summary"),
                 **env},
        )

    def recorded(self):
        if not self.calls.exists():
            return []
        return [eval(line) for line in self.calls.read_text().splitlines()]

    def test_missing_token_warns_and_never_calls_attic(self):
        result = self.run_helper(ATTIC_TOKEN="")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("::warning::attic push skipped", result.stdout)
        self.assertIn("skipped", (self.root / "summary").read_text())
        self.assertEqual(self.recorded(), [])

    def test_empty_path_list_is_a_noop(self):
        empty = self.root / "empty"
        empty.write_text("")
        result = self.run_helper(paths=empty, ATTIC_TOKEN=TOKEN)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.recorded(), [])

    def test_pushes_only_given_store_paths_with_isolated_config(self):
        result = self.run_helper(ATTIC_TOKEN=TOKEN)
        self.assertEqual(result.returncode, 0, result.stderr)
        login, push = self.recorded()
        self.assertEqual(login["argv"], ["login", "urio", "https://attic.urio.dev", TOKEN])
        self.assertEqual(push["argv"], ["push", "urio", *GOOD])
        config = Path(push["config"])
        self.assertFalse(config.exists(), "temporary attic config must be removed on exit")
        self.assertNotIn(str(ROOT), str(config))

    def test_token_never_appears_in_output(self):
        result = self.run_helper(ATTIC_TOKEN=TOKEN)
        self.assertNotIn(TOKEN, result.stdout)
        self.assertNotIn(TOKEN, result.stderr)
        self.assertNotIn(TOKEN, (self.root / "summary").read_text())

    def test_non_store_paths_are_refused_before_any_client_call(self):
        bad = self.root / "bad"
        bad.write_text("/etc/passwd\n")
        result = self.run_helper(paths=bad, ATTIC_TOKEN=TOKEN)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.recorded(), [])

    def test_push_failure_is_reported_as_failure(self):
        result = self.run_helper(ATTIC_TOKEN=TOKEN, FAIL_PUSH="1")
        self.assertNotEqual(result.returncode, 0)


class AtticIndependenceTests(unittest.TestCase):
    """cachix and attic must fail independently; attic never gates the job."""

    def test_build_script_does_not_call_attic_and_exports_verified_list(self):
        body = (ROOT / "scripts/build-ci.sh").read_text()
        self.assertNotIn("attic-push.sh", body)
        self.assertIn("CI_PUBLISH_LIST_FILE", body)
        export = body.index("CI_PUBLISH_LIST_FILE")
        self.assertLess(export, body.index("cachix push uriotv"))

    def test_build_workflow_attic_step_is_independent_and_non_blocking(self):
        body = (ROOT / ".github/workflows/build.yml").read_text()
        step = body.split("      - name: Push verified outputs to the private attic cache", 1)[1].split("      - name:", 1)[0]
        self.assertIn("always()", step)
        self.assertIn("continue-on-error: true", step)
        self.assertIn("publish-paths.txt", step)
        self.assertNotIn("success()", step)

    def test_kernel_workflow_attic_step_follows_verified_closure_not_cachix(self):
        body = (ROOT / ".github/workflows/kernel.yml").read_text()
        step = body.split("      - name: Push kernel outputs to the private attic cache", 1)[1]
        self.assertIn("continue-on-error: true", step.split("run:", 1)[0])
        self.assertIn("always()", step.split("run:", 1)[0])
        self.assertIn("steps.closure.outcome == 'success'", step.split("run:", 1)[0])
        self.assertIn("id: closure", body)


    def test_kernel_pushes_never_depend_on_skip_or_each_other(self):
        body = (ROOT / ".github/workflows/kernel.yml").read_text()
        cachix = body.split("      - name: Publish to uriotv and verify StorePath", 1)[1].split("      - name:", 1)[0]
        attic = body.split("      - name: Push kernel outputs to the private attic cache", 1)[1]
        attic = attic.split("run:", 1)[0]
        for label, step in ("cachix", cachix), ("attic", attic):
            with self.subTest(step=label):
                self.assertNotIn("published.outputs.skip", step)
                self.assertIn("steps.closure.outcome == 'success'", step)
        self.assertNotIn("steps.attic", cachix)
        self.assertNotIn("steps.publish", attic)
        self.assertIn("always()", cachix)
        self.assertIn("always()", attic)
        self.assertIn("--max-jobs 0", body)
        # Proof that skipped-build outputs were substituted, not compiled.
        self.assertIn("uriotv.cachix.org-1:", body)
        self.assertIn("nix path-info --sigs", body)
        # Daily coverage: the kernel must also run after every scheduled update run.
        self.assertIn("workflows: ['Update packages']", body)
        self.assertIn("github.event.workflow_run.conclusion == 'success'", body)
        self.assertIn("github.event_name == 'workflow_run'", body)
        self.assertIn("id: realise", body)


if __name__ == "__main__":
    unittest.main(verbosity=2)
