#!/usr/bin/env python3
"""Offline tests for rolling back package updates that do not build.

Uses a throwaway git repository and stubs `nix`: no builds, no network.
"""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/revert-broken-updates.sh"

PACKAGES = {
    "alpha": None,
    "beta": None,
    "kernel": None,
}


class RevertBrokenUpdatesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "repo"
        self.repo.mkdir()
        self.bin = self.repo / "bin"
        self.bin.mkdir()
        for name in PACKAGES:
            directory = self.repo / "pkgs" / name
            directory.mkdir(parents=True)
            (directory / "default.nix").write_text(f'# {name} 1.0\n')
        self._git("init", "--quiet")
        self._git("add", "-A")
        self._git("-c", "user.email=t@example.com", "-c", "user.name=t",
                  "commit", "--quiet", "-m", "initial")

        self.nix_calls = self.repo / "nix-calls"
        self._stub("nix", '''import os, sys
with open(os.environ["NIX_CALLS"], "a") as f: f.write(" ".join(sys.argv[1:]) + "\\n")
args = sys.argv[1:]
installable = args[-1]
if installable.endswith("^*"):
    installable = installable[:-2]
name = installable.rsplit(".", 1)[-1].strip('"')
if args[0] == "eval":
    if name in os.environ.get("EVAL_FAIL", "").split(","):
        print(f"error: evaluation aborted for {name}", file=sys.stderr); sys.exit(1)
    print("no" if name == os.environ.get("OUT_OF_BAND") else "yes"); sys.exit(0)
if "--dry-run" in args:
    heavy = name in os.environ.get("HEAVY", "").split(",")
    if heavy:
        print("these 2 derivations will be built:", file=sys.stderr)
        print("  /nix/store/" + "f"*32 + "-" + name + "-2.0.drv", file=sys.stderr)
        print("  /nix/store/" + "9"*32 + "-dotnet-vmr-8.0.134.drv", file=sys.stderr)
    sys.exit(0)
print(f"building {name}")
if name in os.environ.get("FAIL_BUILD", "").split(","):
    print(f"error: builder for {name} failed", file=sys.stderr); sys.exit(1)
sys.exit(0)
''')

    def _git(self, *args):
        return subprocess.run(["git", *args], cwd=self.repo, check=True,
                              text=True, capture_output=True)

    def _stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env python3\n" + body)
        path.chmod(0o755)

    def edit(self, name, text="# updated 2.0\n"):
        (self.repo / "pkgs" / name / "default.nix").write_text(text)

    def content(self, name):
        return (self.repo / "pkgs" / name / "default.nix").read_text()

    def run_script(self, **extra):
        self.outputs = self.repo / "github-output"
        self.summary = self.repo / "summary.md"
        self.body = self.repo / "pr-body.md"
        self.body.write_text("This PR was automatically created by the update workflow.\n")
        env = {
            **os.environ,
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "NIX_CALLS": str(self.nix_calls),
            "GITHUB_OUTPUT": str(self.outputs),
            "GITHUB_STEP_SUMMARY": str(self.summary),
            "PR_BODY_PATH": str(self.body),
            **extra,
        }
        return subprocess.run(["bash", str(SCRIPT)], cwd=self.repo, env=env,
                              text=True, capture_output=True)

    def calls(self):
        return self.nix_calls.read_text().splitlines() if self.nix_calls.exists() else []

    def test_rolls_back_only_the_update_that_does_not_build(self):
        for name in PACKAGES:
            self.edit(name)
        (self.repo / "pkgs/beta/extra.json").write_text("{}\n")
        result = self.run_script(FAIL_BUILD="beta", OUT_OF_BAND="kernel")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.content("alpha"), "# updated 2.0\n")
        self.assertEqual(self.content("beta"), "# beta 1.0\n")
        self.assertFalse((self.repo / "pkgs/beta/extra.json").exists())
        # The out-of-band package is neither built nor reverted.
        self.assertEqual(self.content("kernel"), "# updated 2.0\n")
        self.assertFalse([c for c in self.calls() if c.startswith("build") and "kernel" in c])
        self.assertIn("beta update reverted", result.stdout)
        self.assertEqual(self.outputs.read_text().splitlines(),
                         ["reverted_count=1", "reverted_packages=beta"])
        for report in (self.summary.read_text(), self.body.read_text()):
            self.assertIn("Rolled back updates", report)
            self.assertIn("`beta`", report)
            self.assertNotIn("`alpha`", report)

    def test_toolchain_bootstrap_is_reverted_without_building(self):
        self.edit("alpha")
        result = self.run_script(HEAVY="alpha")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.content("alpha"), "# alpha 1.0\n")
        build = [c for c in self.calls() if c.startswith("build") and "--dry-run" not in c]
        self.assertFalse([c for c in build if "alpha" in c], build)
        self.assertIn("dotnet-vmr", result.stdout)

    def test_unevaluable_package_is_decided_by_the_build(self):
        self.edit("alpha")
        self.edit("beta")
        result = self.run_script(EVAL_FAIL="alpha,beta", FAIL_BUILD="beta")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("letting the build decide", result.stdout)
        self.assertEqual(self.content("alpha"), "# updated 2.0\n")
        self.assertEqual(self.content("beta"), "# beta 1.0\n")

    def test_no_changed_package_is_a_noop(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("nothing rolled back", result.stdout)
        self.assertEqual(self.calls(), [])
        self.assertNotIn("Rolled back updates", self.body.read_text())

    def test_invalid_build_timeout_is_rejected(self):
        self.edit("alpha")
        for value in ("0", "abc", "1.5"):
            with self.subTest(value=value):
                result = self.run_script(UPDATE_BUILD_TIMEOUT_SECONDS=value)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("UPDATE_BUILD_TIMEOUT_SECONDS", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
