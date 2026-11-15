#!/usr/bin/env python3
"""Offline tests for Meitou launcher release selection and the AppImage package."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "pkgs/meitou-launcher/update.sh"


class MeitouUpdaterTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        (self.root / "pkgs/meitou-launcher").mkdir(parents=True)
        self.log = self.root / "calls"
        self.fixture = self.root / "releases.json"
        self.fixture.write_text(json.dumps([
            {"tag_name": "launcher-v1.9.0", "draft": False, "prerelease": False},
            {"tag_name": "launcher-v1.10.0", "draft": False, "prerelease": False},
            {"tag_name": "launcher-v1.11.0", "draft": True, "prerelease": False},
            {"tag_name": "launcher-v1.12.0-nightly", "draft": False, "prerelease": True},
            {"tag_name": "v99.0.0", "draft": False, "prerelease": False},
        ]))
        self.stub("curl", 'printf "curl %s\\n" "$*" >> "$CALLS.curl"; exec cat "$FIXTURE"')
        self.stub("nix", 'printf "%s\\n" "$CURRENT"')
        self.stub("nix-update", 'printf "nix-update %s\\n" "$*" >> "$CALLS"')

    def stub(self, name, body):
        p = self.bin / name
        p.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + body + "\n")
        p.chmod(0o755)

    def run_updater(self, version, script=SCRIPT, token=None):
        env = {**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}", "FIXTURE": str(self.fixture),
               "CURRENT": version, "CALLS": str(self.log)}
        env.pop("GITHUB_TOKEN", None)
        if token:
            env["GITHUB_TOKEN"] = token
        return subprocess.run(["bash", str(script)], cwd=self.root, env=env, text=True, capture_output=True)

    def test_same_or_older_upstream_never_downgrades(self):
        for version in ("1.10.0", "1.11.0"):
            with self.subTest(version=version):
                result = self.run_updater(version)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(self.log.exists())

    def test_launcher_selects_launcher_release(self):
        result = self.run_updater("1.9.0")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.log.read_text().splitlines(), [
            "nix-update --flake meitou-launcher --version 1.10.0",
        ])

    def test_github_api_is_authenticated_when_a_token_is_available(self):
        self.run_updater("1.10.0", token="secret-token")
        self.assertIn("Authorization: Bearer secret-token", Path(f"{self.log}.curl").read_text())

    def test_launcher_ignores_game_releases(self):
        self.fixture.write_text(json.dumps([{"tag_name": "v999.0.0", "draft": False, "prerelease": False}]))
        result = self.run_updater("1.9.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No stable launcher release found", result.stderr)
        self.assertFalse(self.log.exists())


class MeitouPackageTests(unittest.TestCase):
    def test_package_wraps_the_upstream_appimage_without_dotnet(self):
        expression = (ROOT / "pkgs/meitou-launcher/default.nix").read_text()
        self.assertIn("MeitouLauncher-linux-x64.AppImage", expression)
        self.assertIn("appimageTools.extractType2", expression)
        self.assertNotIn("buildDotnetModule", expression)
        self.assertFalse((ROOT / "pkgs/meitou-launcher/deps.json").exists())

    def test_appimage_is_never_run_as_a_mounted_appimage(self):
        # Velopack only self-updates an installed AppImage, detected via $APPIMAGE.
        expression = (ROOT / "pkgs/meitou-launcher/default.nix").read_text()
        self.assertIn("unset APPIMAGE APPDIR", expression)
        self.assertIn('runScript = "${contents}/usr/bin/meitou-launcher";', expression)


class MeitouVulkanPolicyTests(unittest.TestCase):
    def test_software_driver_filter_respects_explicit_user_selection(self):
        expression = (ROOT / "pkgs/meitou-launcher/default.nix").read_text()
        profile = expression.split("  profile = ''\n", 1)[1].split("\n  '';", 1)[0]
        profile = profile.replace("''${", "${")
        variables = ("VK_LOADER_DRIVERS_DISABLE", "VK_LOADER_DRIVERS_SELECT", "VK_DRIVER_FILES",
                     "VK_ICD_FILENAMES", "MESA_VK_DEVICE_SELECT")
        clean_env = {k: v for k, v in os.environ.items() if k not in variables}
        def result(extra):
            cmd = profile + '\nprintf "%s" "${VK_LOADER_DRIVERS_DISABLE-unset}"'
            return subprocess.run(["bash", "-c", cmd], env={**clean_env, **extra}, text=True,
                                  capture_output=True, check=True).stdout
        self.assertEqual(result({}), "*lvp*")
        self.assertEqual(result({"VK_LOADER_DRIVERS_DISABLE": ""}), "")
        self.assertEqual(result({"VK_LOADER_DRIVERS_DISABLE": "custom"}), "custom")
        for variable in variables[1:]:
            with self.subTest(variable=variable):
                self.assertEqual(result({variable: "explicit"}), "unset")


if __name__ == "__main__":
    unittest.main(verbosity=2)
