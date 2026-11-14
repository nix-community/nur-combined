#!/usr/bin/env python3
"""Offline tests: one pull request per updated package.

Uses throwaway git repositories (a real bare origin) and stubs `gh`/`nix`, so the
branch, commit and cleanup logic runs for real without network access.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/open-update-prs.sh"


class OpenUpdatePrsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.origin = self.root / "origin.git"
        self.repo = self.root / "repo"
        self.bin = self.root / "bin"
        self.bin.mkdir()

        subprocess.run(["git", "init", "--quiet", "--bare", str(self.origin)], check=True)
        self.repo.mkdir()
        for name in ("alpha", "beta"):
            directory = self.repo / "pkgs" / name
            directory.mkdir(parents=True)
            (directory / "default.nix").write_text(f"# {name} 1.0\n")
        (self.repo / "scripts").mkdir()
        # The real script refreshes the README through this file; a stub keeps the
        # test independent of Nix evaluation.
        (self.repo / "scripts" / "readme-versions.py").write_text(
            "from pathlib import Path\n"
            "Path('README.md').write_text('| package | version |\\n|---|---|\\n| row | 2.0 |\\n')\n")
        (self.repo / "README.md").write_text("| package | version |\n|---|---|\n")
        self.git("init", "--quiet")
        self.git("add", "-A")
        self.git("-c", "user.email=t@example.com", "-c", "user.name=t",
                 "commit", "--quiet", "-m", "initial")
        self.git("remote", "add", "origin", str(self.origin))
        self.git("push", "--quiet", "origin", "HEAD:refs/heads/main")
        self.base = self.git("rev-parse", "HEAD").stdout.strip().strip()

        self.gh_calls = self.root / "gh-calls"
        self._stub("gh", '''import os, sys
args = sys.argv[1:]
with open(os.environ["GH_CALLS"], "a") as f: f.write(" ".join(args) + "\\n")
if args[:2] == ["pr", "list"]:
    print(os.environ.get("EXISTING_PR", "")); sys.exit(0)
if args[:2] == ["pr", "create"] and os.environ.get("FAIL_CREATE"):
    sys.exit(1)
sys.exit(0)
''')
        self._stub("nix", "print('2.0')\n")

    def _stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env python3\n" + body)
        path.chmod(0o755)

    def git(self, *args, cwd=None):
        return subprocess.run(["git", *args], cwd=cwd or self.repo, check=True,
                              text=True, capture_output=True)

    def edit(self, name, text="# updated 2.0\n"):
        (self.repo / "pkgs" / name / "default.nix").write_text(text)

    def run_script(self, **extra):
        self.outputs = self.root / "github-output"
        env = {
            **os.environ,
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "GH_CALLS": str(self.gh_calls),
            "GITHUB_OUTPUT": str(self.outputs),
            "GH_TOKEN": "mock-token",
            "GITHUB_REPOSITORY": "urioTV/urio-nur",
            "BUILD_LOG_URL": "https://example.invalid/run/1",
            **extra,
        }
        return subprocess.run(["bash", str(SCRIPT)], cwd=self.repo, env=env,
                              text=True, capture_output=True)

    def calls(self):
        return self.gh_calls.read_text().splitlines() if self.gh_calls.exists() else []

    def branch_files(self, branch):
        # Files the branch changes relative to the base commit.
        out = self.git("diff", "--name-only", self.base, branch, cwd=self.origin).stdout
        return out.splitlines()

    def test_one_pull_request_per_package(self):
        self.edit("alpha")
        self.edit("beta")
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        # Every branch is based on the base commit and carries only its own package.
        for name in ("alpha", "beta"):
            files = self.branch_files(f"auto-update/{name}")
            self.assertIn(f"pkgs/{name}/default.nix", files)
            other = "beta" if name == "alpha" else "alpha"
            self.assertNotIn(f"pkgs/{other}/default.nix", files)
            self.assertIn("README.md", files)
        creates = [c for c in self.calls() if c.startswith("pr create")]
        self.assertEqual(len(creates), 2)
        self.assertTrue(any("auto-update/alpha" in c and "chore(alpha): update to 2.0" in c for c in creates))
        self.assertTrue(any("auto-update/beta" in c and "chore(beta): update to 2.0" in c for c in creates))
        merges = [c for c in self.calls() if c.startswith("pr merge")]
        self.assertEqual(merges, ["pr merge auto-update/alpha --squash --auto --delete-branch",
                                  "pr merge auto-update/beta --squash --auto --delete-branch"])
        # The working tree is handed back clean for the next step.
        self.assertEqual(self.git("status", "--porcelain").stdout, "")
        self.assertEqual(self.outputs.read_text().splitlines(),
                         ["pull_requests=2", "pull_request_packages=alpha beta"])

    def test_existing_open_pull_request_is_updated_not_duplicated(self):
        self.edit("alpha")
        result = self.run_script(EXISTING_PR="42")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual([c for c in self.calls() if c.startswith("pr create")], [])
        edits = [c for c in self.calls() if c.startswith("pr edit")]
        self.assertEqual(len(edits), 1)
        self.assertIn("42", edits[0])

    def test_unwritable_remote_fails_before_any_work(self):
        self.edit("alpha")
        self.git("remote", "set-url", "origin", str(self.root / "missing.git"))
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("cannot push branches", result.stdout)
        self.assertEqual(self.calls(), [])
        self.assertFalse((self.root / "github-output").exists())

    def test_no_changes_opens_nothing(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("nothing to open", result.stdout)
        self.assertEqual(self.calls(), [])
        self.assertEqual(self.outputs.read_text().splitlines(), ["pull_requests=0"])

    def test_one_failing_pull_request_does_not_stop_the_others(self):
        self.edit("alpha")
        self.edit("beta")
        result = self.run_script(FAIL_CREATE="1")
        self.assertNotEqual(result.returncode, 0)
        # Both packages still reached their own branch.
        self.assertIn("pkgs/alpha/default.nix", self.branch_files("auto-update/alpha"))
        self.assertIn("pkgs/beta/default.nix", self.branch_files("auto-update/beta"))
        self.assertEqual(self.git("status", "--porcelain").stdout, "")


if __name__ == "__main__":
    unittest.main(verbosity=2)
