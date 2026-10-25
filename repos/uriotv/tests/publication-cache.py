#!/usr/bin/env python3
# Offline tests for the cache-branch gate: publication-status.sh and
# promote-cache-branch.sh, with a fake `gh` that records every API call.
import json
import os
import pathlib
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
STATUS = ROOT / "scripts/publication-status.sh"
PROMOTE = ROOT / "scripts/promote-cache-branch.sh"
SHA = "a" * 40
OLD = "b" * 40

FAKE_GH = """#!/usr/bin/env bash
printf '%s\\n' "$*" >> "$FAKE_LOG"
case "$*" in
  *"git/ref/heads/main"*) echo "$FAKE_MAIN_SHA" ;;
  *"/status"*) echo "$FAKE_STATUSES" ;;
  *"git/ref/heads/cache"*) if [[ -n "${FAKE_CACHE_SHA:-}" ]]; then echo "$FAKE_CACHE_SHA"; else exit 1; fi ;;
esac
"""

ALL_GREEN = {
    "cache/packages": "success",
    "cache/kernel/linux-cachyos-latest-x86_64-v3": "success",
    "cache/kernel/linux-cachyos-bore-x86_64-v3": "success",
}


class GateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.tmp.name)
        (self.root / "bin").mkdir()
        gh = self.root / "bin/gh"
        gh.write_text(FAKE_GH)
        gh.chmod(0o755)
        self.log = self.root / "calls.log"

    def tearDown(self):
        self.tmp.cleanup()

    def run_script(self, script, args=(), **env):
        full = {
            **os.environ,
            "PATH": f"{self.root / 'bin'}{os.pathsep}{os.environ['PATH']}",
            "FAKE_LOG": str(self.log),
            "GITHUB_REPOSITORY": "urioTV/urio-nur",
            "GITHUB_SHA": SHA,
            "REPO": "urioTV/urio-nur",
            "GH_TOKEN": "test-token",
            "FAKE_MAIN_SHA": SHA,
            "FAKE_STATUSES": json.dumps(ALL_GREEN),
            "FAKE_CACHE_SHA": OLD,
        }
        for key, value in env.items():
            if value is None:
                full.pop(key, None)
            else:
                full[key] = value
        return subprocess.run(["bash", str(script), *args], capture_output=True, text=True,
                              env=full)

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []


class PublicationStatusTests(GateTests):
    def test_all_success_records_success_on_the_checked_out_commit(self):
        result = self.run_script(STATUS, ["cache/packages", "success", "success"])
        self.assertEqual(result.returncode, 0, result.stderr)
        call = self.calls()[-1]
        self.assertIn(f"repos/urioTV/urio-nur/statuses/{SHA}", call)
        self.assertIn("-f state=success", call)
        self.assertIn("-f context=cache/packages", call)

    def test_any_unsuccessful_outcome_records_failure(self):
        for outcome in ("failure", "cancelled", "skipped", ""):
            with self.subTest(outcome=outcome):
                self.log.unlink(missing_ok=True)
                result = self.run_script(STATUS, ["cache/packages", "success", outcome])
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("-f state=failure", self.calls()[-1])

    def test_requires_context_and_commit(self):
        self.assertNotEqual(self.run_script(STATUS, ["cache/packages"]).returncode, 0)
        self.assertNotEqual(self.run_script(STATUS, [], GITHUB_SHA=None).returncode, 0)


class PromoteTests(GateTests):
    def test_moves_cache_fast_forward_when_every_publication_succeeded(self):
        result = self.run_script(PROMOTE)
        self.assertEqual(result.returncode, 0, result.stderr)
        patch = [c for c in self.calls() if "--method PATCH" in c]
        self.assertEqual(len(patch), 1)
        self.assertIn("git/refs/heads/cache", patch[0])
        self.assertIn(f"-f sha={SHA}", patch[0])
        self.assertIn("-F force=false", patch[0])

    def test_creates_cache_branch_when_missing(self):
        result = self.run_script(PROMOTE, FAKE_CACHE_SHA=None)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any("--method POST" in c and "refs/heads/cache" in c for c in self.calls()))

    def test_one_missing_or_failed_publication_leaves_cache_unchanged(self):
        for context in ALL_GREEN:
            for state in ("failure", "missing"):
                with self.subTest(context=context, state=state):
                    self.log.unlink(missing_ok=True)
                    statuses = {**ALL_GREEN}
                    if state == "missing":
                        del statuses[context]
                    else:
                        statuses[context] = state
                    result = self.run_script(PROMOTE, FAKE_STATUSES=json.dumps(statuses))
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn("::notice::cache branch not moved", result.stdout)
                    self.assertFalse(any("--method" in c for c in self.calls()))

    def test_no_write_when_cache_already_at_main(self):
        result = self.run_script(PROMOTE, FAKE_CACHE_SHA=SHA)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any("--method" in c for c in self.calls()))

    def test_never_force_pushes(self):
        self.assertIn("force=false", PROMOTE.read_text())
        self.assertNotIn("force=true", PROMOTE.read_text())


if __name__ == "__main__":
    unittest.main(verbosity=2)
