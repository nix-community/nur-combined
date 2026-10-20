#!/usr/bin/env python3
"""Mock all HTTP/retry waits; distinguish throttling from successful notification."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class NurNotificationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.calls = self.root / "calls"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        curl = self.bin / "curl"
        curl.write_text('''#!/usr/bin/env python3
import os, pathlib, sys
p = pathlib.Path(os.environ['CALLS'])
calls = p.read_text().splitlines() if p.exists() else []
sequence = os.environ['HTTP_SEQUENCE'].split(',')
status = sequence[min(len(calls), len(sequence)-1)]
with p.open('a') as f: f.write(' '.join(sys.argv[1:])+'\\n')
if status == 'network': sys.exit(7)
print(status, end='')
''')
        curl.chmod(0o755)
        sleep = self.bin / "sleep"
        sleep.write_text("#!/usr/bin/env bash\nexit 0\n")
        sleep.chmod(0o755)

    def run_notify(self, sequence="204", event="push", ref="refs/heads/main", repo="urio-nur"):
        return subprocess.run(["bash", str(ROOT / "scripts/notify-nur.sh"), repo],
                              text=True, capture_output=True, env={
                                  **os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}",
                                  "HTTP_SEQUENCE": sequence, "CALLS": str(self.calls),
                                  "GITHUB_EVENT_NAME": event, "GITHUB_REF": ref,
                                  "GITHUB_STEP_SUMMARY": str(self.root / "summary"),
                              })

    def test_accepted_refresh_is_reported(self):
        result = self.run_notify()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("accepted", result.stdout)
        self.assertEqual(len(self.calls.read_text().splitlines()), 1)

    def test_rate_limit_is_deferred_warning_not_claimed_successful_post(self):
        result = self.run_notify("429")
        self.assertEqual(result.returncode, 0)
        self.assertIn("::warning::", result.stdout)
        self.assertIn("no refresh was accepted", (self.root / "summary").read_text())
        self.assertEqual(len(self.calls.read_text().splitlines()), 1)

    def test_server_and_transport_errors_retry_and_remain_failures(self):
        for code in ("503", "network"):
            with self.subTest(code=code):
                self.calls.unlink(missing_ok=True)
                result = self.run_notify(code)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("::error::", result.stdout)
                self.assertEqual(len(self.calls.read_text().splitlines()), 3)

    def test_transient_failure_can_recover(self):
        result = self.run_notify("503,204")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(len(self.calls.read_text().splitlines()), 2)

    def test_authentication_errors_are_not_silenced_or_retried(self):
        result = self.run_notify("403")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("HTTP 403", result.stdout)
        self.assertEqual(len(self.calls.read_text().splitlines()), 1)

    def test_prs_feature_branches_and_invalid_names_never_make_request(self):
        for args in (("pull_request", "refs/heads/main", "urio-nur"),
                     ("workflow_dispatch", "refs/heads/feature", "urio-nur"),
                     ("push", "refs/heads/main", "../bad?x=y")):
            with self.subTest(args=args):
                self.run_notify(event=args[0], ref=args[1], repo=args[2])
                self.assertFalse(self.calls.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
