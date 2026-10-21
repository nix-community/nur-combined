#!/usr/bin/env python3
"""Offline tests for the CachyOS kernel updater: stubbed git/curl/nix, no network."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = "linux-cachyos-latest-x86_64-v3"
PINNED = "a" * 40
LATEST = "b" * 40
OLD_HASH = "sha256-OLDOLDOLDOLDOLDOLDOLDOLDOLDOLDOLDOLDOLDOLDO="
NEW_HASH = "sha256-NEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWN="
DEFAULT_NIX = f'''{{ lib, fetchFromGitHub }}:
let
  upstream = fetchFromGitHub {{
    owner = "xddxdd";
    repo = "nix-cachyos-kernel";
    rev = "{PINNED}";
    hash = "{OLD_HASH}";
  }};
in
upstream
'''


class KernelUpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.package = self.root / "pkgs" / PACKAGE
        self.package.mkdir(parents=True)
        shutil.copy(ROOT / "pkgs" / PACKAGE / "update.py", self.package / "update.py")
        (self.package / "default.nix").write_text(DEFAULT_NIX)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.calls = self.root / "calls"
        self._stub("git", 'print(os.environ["LATEST_REV"] + "\\trefs/heads/master")')
        self._stub("curl", '''url = sys.argv[-1]
rev = url.split("/")[-3]
version = os.environ["VERSION_" + rev[:1]]
print(json.dumps({"linux-cachyos": {"version": version}, "linux-cachyos-lts": {"version": "6.18.1"}}))''')
        self._stub("nix", '''if sys.argv[1:3] == ["store", "prefetch-file"]:
    print(json.dumps({"hash": os.environ["NEW_HASH"], "storePath": "/nix/store/x"}))
else:
    print(os.environ["EVAL_VERSION"])''')

    def _stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env python3\nimport json, os, sys\n"
                        f"open({str(self.calls)!r}, 'a').write({name!r} + ' ' + ' '.join(sys.argv[1:]) + '\\n')\n"
                        + body + "\n")
        path.chmod(0o755)

    def run_updater(self, latest=LATEST, pinned_version="7.2.11", latest_version="7.2.11",
                    eval_version=None):
        env = {**os.environ, "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
               "LATEST_REV": latest, "VERSION_a": pinned_version, "VERSION_b": latest_version,
               "NEW_HASH": NEW_HASH, "EVAL_VERSION": eval_version or latest_version}
        return subprocess.run(["python3", "-B", str(self.package / "update.py")],
                              env=env, text=True, capture_output=True)

    def nix_text(self):
        return (self.package / "default.nix").read_text()

    def test_same_revision_is_noop_without_downloads(self):
        result = self.run_updater(latest=PINNED)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.nix_text(), DEFAULT_NIX)
        self.assertNotIn("curl", self.calls.read_text())

    def test_new_revision_with_same_kernel_version_is_ignored(self):
        result = self.run_updater(latest_version="7.2.11")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("non-kernel changes ignored", result.stdout)
        self.assertEqual(self.nix_text(), DEFAULT_NIX)
        self.assertNotIn("prefetch-file", self.calls.read_text())

    def test_older_kernel_version_is_not_a_downgrade(self):
        result = self.run_updater(latest_version="7.2.9")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.nix_text(), DEFAULT_NIX)

    def test_newer_kernel_version_moves_rev_and_hash_together(self):
        for newer in ("7.2.12", "7.3", "7.10.1"):
            with self.subTest(version=newer):
                (self.package / "default.nix").write_text(DEFAULT_NIX)
                result = self.run_updater(latest_version=newer)
                self.assertEqual(result.returncode, 0, result.stderr)
                text = self.nix_text()
                self.assertIn(f'rev = "{LATEST}";', text)
                self.assertIn(f'hash = "{NEW_HASH}";', text)
                self.assertNotIn(PINNED, text)
                self.assertIn(f"7.2.11 -> {newer}", result.stdout)

    def test_evaluated_version_mismatch_fails(self):
        result = self.run_updater(latest_version="7.2.12", eval_version="7.2.11")
        self.assertNotEqual(result.returncode, 0)

    def test_malformed_upstream_version_fails(self):
        result = self.run_updater(latest_version="7.2.12-rc1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.nix_text(), DEFAULT_NIX)


if __name__ == "__main__":
    unittest.main(verbosity=2)
