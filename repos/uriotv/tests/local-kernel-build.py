#!/usr/bin/env python3
"""Offline smoke tests for the local kernel build/publish command."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/build-and-cache-kernel.sh"


class LocalKernelBuildTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        # Redirect the system root so tests never inspect real host credentials.
        self.script = self.root / "build.sh"
        self.script.write_text(SCRIPT.read_text().replace(
            "roots=(/run/secrets)", f'roots=("{self.root / "system-secrets"}")'
        ))
        self.manifest = self.root / "manifest.json"
        self.paths = {
            name: "/nix/store/" + char * 32 + "-kernel-" + name
            for name, char in (("out", "a"), ("dev", "b"), ("modules", "c"), ("source", "d"))
        }
        self.manifest.write_text(json.dumps([{"outputs": self.paths}]))
        self.env = {
            **os.environ,
            "PATH": str(self.bin) + os.pathsep + os.environ["PATH"],
            "KERNEL_FLAKE": "path:/immutable-source",
            "CACHIX_SOPS_SECRETS_DIR": str(self.root / "secrets"),
            "TEST_ROOT": str(self.root),
            "XDG_CONFIG_HOME": str(self.root / "config"),
        }
        self.env.pop("CACHIX_AUTH_TOKEN", None)
        self.env.pop("CACHIX_AUTH_TOKEN_FILE", None)
        self.stub("nix", '''
[[ -z "${CACHIX_AUTH_TOKEN:-}" && -z "${CACHIX_AUTH_TOKEN_FILE:-}" ]] || exit 9
printf '%s\\n' "$@" > "$TEST_ROOT/nix-args"
cat "$TEST_ROOT/manifest.json"
''')
        self.stub("du", "exit 0")
        self.stub("cachix", '''
[[ -n "${CACHIX_AUTH_TOKEN:-}" ]] || exit 10
cat > "$TEST_ROOT/pushed-paths"
''')
        # Return real-shaped narinfo for each fake output; no networking occurs.
        lines = "".join("echo 'StorePath: " + path + "'\n" for path in self.paths.values())
        self.stub("curl", lines)

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + body)
        path.chmod(0o755)

    def run_script(self, *args, **extra_env):
        return subprocess.run(
            ["bash", str(self.script), *args], env=self.env | extra_env,
            capture_output=True, text=True,
        )

    def test_build_only_needs_no_token_and_builds_all_outputs_and_sources(self):
        result = self.run_script("--build-only", "--cores", "8")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = (self.root / "nix-args").read_text().splitlines()
        self.assertIn("8", args)
        base = "path:/immutable-source#packages.x86_64-linux.linux-cachyos-bore-x86_64-v3"
        self.assertIn(base + "^*", args)
        self.assertIn(base + ".src", args)
        self.assertIn(base + ".urioUpstreamSource", args)
        self.assertFalse((self.root / "pushed-paths").exists())

    def test_missing_token_stops_before_expensive_build(self):
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "nix-args").exists())

    def test_token_file_publishes_every_output_without_leaking_token(self):
        token = self.root / "token"
        token.write_text("test-only-secret\n")
        result = self.run_script("--token-file", str(token), "--cores", "4")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            set((self.root / "pushed-paths").read_text().splitlines()), set(self.paths.values())
        )
        self.assertNotIn("test-only-secret", result.stdout + result.stderr)

    def test_sops_token_is_detected_automatically(self):
        secrets = self.root / "secrets"
        secrets.mkdir()
        (secrets / "cachix_auth_token").write_text("automatic-test-secret\n")
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.root / "pushed-paths").exists())
        self.assertNotIn("automatic-test-secret", result.stdout + result.stderr)

    def test_home_manager_runtime_secret_is_detected(self):
        self.env.pop("CACHIX_SOPS_SECRETS_DIR")
        runtime = self.root / "runtime"
        secrets = runtime / "secrets"
        secrets.mkdir(parents=True)
        (secrets / "cachix_token").write_text("runtime-test-secret\n")
        result = self.run_script(XDG_RUNTIME_DIR=str(runtime))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.root / "pushed-paths").exists())

    def test_explicit_missing_file_never_falls_back_to_auto_token(self):
        secrets = self.root / "secrets"
        secrets.mkdir()
        (secrets / "cachix_auth_token").write_text("auto-token\n")
        result = self.run_script("--token-file", str(self.root / "missing"))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "nix-args").exists())

    def test_build_only_does_not_read_a_sops_token(self):
        secrets = self.root / "secrets"
        secrets.mkdir()
        (secrets / "cachix_auth_token").write_text("unused-test-secret\n")
        result = self.run_script("--build-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.root / "pushed-paths").exists())
        self.assertNotIn("unused-test-secret", result.stdout + result.stderr)

    def test_wrong_remote_store_path_is_a_failure(self):
        self.stub("curl", "echo 'StorePath: /nix/store/wrong-kernel'")
        result = self.run_script(CACHIX_AUTH_TOKEN="test-only-secret")
        self.assertNotEqual(result.returncode, 0)

    def test_invalid_core_count_and_missing_option_value_are_rejected(self):
        for args in (("--cores", "0"), ("--cores", "native"), ("--token-file",)):
            with self.subTest(args=args):
                self.assertEqual(self.run_script(*args).returncode, 2)

    def test_help_needs_no_token_or_build(self):
        result = self.run_script("--help")
        self.assertEqual(result.returncode, 0)
        self.assertFalse((self.root / "nix-args").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
