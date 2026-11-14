#!/usr/bin/env python3
"""Offline tests for Meitou launcher release selection and NuGet refresh."""
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
        self.global_json = self.root / "global.json"
        # Exact upstream launcher-v1.10.0/global.json contents.
        self.global_json.write_text(json.dumps({"sdk": {"rollForward": "latestFeature", "version": "11.0.100"}}))
        self.stub("curl", 'case "$*" in *raw.githubusercontent.com*) exec cat "$GLOBAL_JSON" ;; *) exec cat "$FIXTURE" ;; esac')
        self.stub("nix", 'if [ "$1" = eval ]; then if [[ "$*" == *dotnetSdkVersion* ]]; then printf "%s\\n" "$SDK_VERSION"; else printf "%s\\n" "$CURRENT"; fi; else printf "%s\\n" "$STUBDIR/fetch-deps"; fi')
        self.stub("nix-update", 'printf "nix-update %s\\n" "$*" >> "$CALLS"')
        self.stub("fetch-deps", 'printf "fetch-deps %s\\n" "$*" >> "$CALLS"')

    def stub(self, name, body):
        p = self.bin / name
        p.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + body + "\n")
        p.chmod(0o755)

    def run_updater(self, version, script=SCRIPT, sdk_version="11.0.100"):
        env = {**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}", "FIXTURE": str(self.fixture),
               "GLOBAL_JSON": str(self.global_json), "CURRENT": version, "SDK_VERSION": sdk_version,
               "CALLS": str(self.log), "STUBDIR": str(self.bin)}
        return subprocess.run(["bash", str(script)], cwd=self.root, env=env, text=True, capture_output=True)

    def test_same_or_older_upstream_never_downgrades(self):
        for version in ("1.10.0", "1.11.0"):
            with self.subTest(version=version):
                result = self.run_updater(version)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(self.log.exists())

    def test_launcher_selects_launcher_release_and_refreshes_deps(self):
        result = self.run_updater("1.9.0")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.log.read_text().splitlines(), [
            "nix-update --flake meitou-launcher --version 1.10.0",
            "fetch-deps pkgs/meitou-launcher/deps.json",
        ])

    def test_launcher_ignores_game_releases(self):
        self.fixture.write_text(json.dumps([{"tag_name": "v999.0.0", "draft": False, "prerelease": False}]))
        result = self.run_updater("1.9.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No stable launcher release found", result.stderr)
        self.assertFalse(self.log.exists())

    def test_sdk_latest_feature_accepts_newer_stable_feature_band(self):
        result = self.run_updater("1.9.0", sdk_version="11.0.200")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.log.exists())

    def test_sdk_accepts_prerelease_of_the_required_band(self):
        # nixpkgs can pin a release candidate of the band until Microsoft's GA
        # metadata lands; the package build ignores upstream's exact pin.
        for sdk in ("11.0.100-rc.3.26522.148", "11.0.100-rc.1", "11.0.200-preview.1"):
            with self.subTest(sdk=sdk):
                result = self.run_updater("1.9.0", sdk_version=sdk)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(self.log.exists())
                self.log.unlink()

    def test_sdk_rejects_older_and_different_major_before_mutation(self):
        for sdk in ("10.0.403", "11.0.99", "12.0.100"):
            with self.subTest(sdk=sdk):
                result = self.run_updater("1.9.0", sdk_version=sdk)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Unsupported upstream .NET SDK", result.stderr)
                self.assertFalse(self.log.exists())

    def test_unknown_sdk_policy_does_not_allow_roll_forward(self):
        self.global_json.write_text(json.dumps({"sdk": {"rollForward": "newPolicy", "version": "11.0.100"}}))
        result = self.run_updater("1.9.0", sdk_version="11.0.200")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_sdk_rejects_prerelease_requirement_upstream(self):
        self.global_json.write_text(json.dumps({"sdk": {"rollForward": "latestFeature", "version": "11.0.100-rc.1"}}))
        result = self.run_updater("1.9.0", sdk_version="11.0.100-rc.3.26522.148")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unsupported upstream .NET SDK", result.stderr)
        self.assertFalse(self.log.exists())

    def test_upstream_global_json_sdk_must_match_package_sdk(self):
        self.global_json.write_text(json.dumps({"sdk": {"rollForward": "latestFeature", "version": "12.0.100"}}))
        result = self.run_updater("1.9.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unsupported upstream .NET SDK 12.0.100", result.stderr)
        self.assertFalse(self.log.exists())


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
