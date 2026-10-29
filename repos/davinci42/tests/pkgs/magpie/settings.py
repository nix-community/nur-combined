import http.client
import importlib.util
import json
import os
import socket
import subprocess
import tempfile
import time
import unittest
from pathlib import Path
from types import ModuleType
from typing import Protocol, cast

ROOT = Path(__file__).resolve().parents[3]


class Helper(Protocol):
    ConfigurationError: type[Exception]

    def sync_settings(
        self,
        config_dir: str | Path,
        declared_path: str | Path,
        secret_file: str | Path | None = None,
    ) -> dict[str, object]: ...
    def resolve_config_dir(self, explicit: str | None = None) -> Path: ...
    def main(self, argv: list[str] | None = None) -> int: ...


def load_module(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError("Cannot load test module: " + name)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


helper = cast(
    Helper,
    cast(object, load_module("magpie_configure", ROOT / "modules/magpie-configure.py")),
)


class SettingsSyncTests(unittest.TestCase):
    def test_tracked_partial_sync_enforces_and_prunes_without_touching_unmanaged(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            config_dir = root / "config/magpie"
            config_dir.mkdir(parents=True)
            settings_path = config_dir / "settings.json"
            declared_path = root / "declared.json"
            secret_path = root / "secret.json"

            _ = settings_path.write_text(
                json.dumps(
                    {
                        "window": [1024, 768],
                        "agentOrder": ["claude", "codex"],
                        "chinaMirror": False,
                    }
                )
            )

            _ = declared_path.write_text(
                json.dumps({"chinaMirror": True, "redact": True, "ignoredNull": None})
            )
            _ = secret_path.write_text(json.dumps({"githubToken": "ghp_secret"}))

            first = helper.sync_settings(config_dir, declared_path, secret_path)
            self.assertEqual(
                first,
                {
                    "window": [1024, 768],
                    "agentOrder": ["claude", "codex"],
                    "chinaMirror": True,
                    "redact": True,
                    "githubToken": "ghp_secret",
                },
            )
            self.assertEqual(settings_path.stat().st_mode & 0o777, 0o600)

            mutated = dict(first)
            mutated["window"] = [1280, 800]
            mutated["theme"] = "dark"
            mutated["redact"] = False
            _ = settings_path.write_text(json.dumps(mutated))

            _ = declared_path.write_text(json.dumps({"redact": True}))
            second = helper.sync_settings(config_dir, declared_path, None)
            self.assertEqual(
                second,
                {
                    "window": [1280, 800],
                    "agentOrder": ["claude", "codex"],
                    "theme": "dark",
                    "redact": True,
                },
            )

            _ = declared_path.write_text("{}")
            third = helper.sync_settings(config_dir, declared_path, None)
            self.assertEqual(
                third,
                {
                    "window": [1280, 800],
                    "agentOrder": ["claude", "codex"],
                    "theme": "dark",
                },
            )
            self.assertFalse((config_dir / ".nix-managed-keys.json").exists())

    def test_duplicate_keys_between_settings_and_secret_file_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            declared = root / "declared.json"
            secret = root / "secret.json"
            _ = declared.write_text(json.dumps({"proxy": "http://127.0.0.1:7890"}))
            _ = secret.write_text(json.dumps({"proxy": "socks5://127.0.0.1:1080"}))
            with self.assertRaisesRegex(helper.ConfigurationError, "duplicate keys"):
                _ = helper.sync_settings(root / "magpie", declared, secret)

    def test_cli_entry_and_config_dir_resolution(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            declared = root / "declared.json"
            _ = declared.write_text(json.dumps({"noAutoUpdate": True}))
            code = helper.main([str(declared), "--config-dir", str(root / "cfg")])
            self.assertEqual(code, 0)
            self.assertEqual(
                json.loads((root / "cfg/settings.json").read_text()),
                {"noAutoUpdate": True},
            )

    def test_live_gateway_and_cli(self) -> None:
        package = os.environ.get("MAGPIE_TEST_PACKAGE")
        if not package:
            return
        binary = Path(package) / "bin/magpie"
        self.assertTrue(binary.is_file())
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            home = root / "home"
            config_home = root / "config"
            cache_home = root / "cache"
            for folder in (home, config_home, cache_home):
                folder.mkdir(parents=True)

            declared = root / "declared.json"
            _ = declared.write_text(
                json.dumps({"noAutoUpdate": True, "chinaMirror": True})
            )
            _ = helper.sync_settings(config_home / "magpie", declared, None)

            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                sock.bind(("127.0.0.1", 0))
                port = cast(tuple[str, int], sock.getsockname())[1]

            env = os.environ | {
                "HOME": str(home),
                "XDG_CONFIG_HOME": str(config_home),
                "XDG_CACHE_HOME": str(cache_home),
                "MAGPIE_ADDR": f"127.0.0.1:{port}",
                "DO_NOT_TRACK": "1",
                "MAGPIE_NO_STATS": "1",
                "MAGPIE_NO_ACCOUNTS": "1",
            }

            version_out = subprocess.check_output(
                [str(binary), "--version"], env=env, text=True
            ).strip()
            self.assertIn("magpie", version_out)

            process = subprocess.Popen(
                [str(binary), "serve"],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            try:
                deadline = time.monotonic() + 15
                ready = False
                while time.monotonic() < deadline:
                    check = subprocess.run(
                        [str(binary), "healthcheck"],
                        check=False,
                        env=env,
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                    if check.returncode == 0:
                        ready = True
                        break
                    time.sleep(0.2)
                self.assertTrue(ready, "magpie gateway did not become healthy in time")

                connection = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
                try:
                    connection.request("GET", "/v1/models")
                    response = connection.getresponse()
                    payload = cast(
                        dict[str, object], json.loads(response.read().decode())
                    )
                finally:
                    connection.close()
                self.assertEqual(payload.get("object"), "list")
            finally:
                process.terminate()
                try:
                    _ = process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    _ = process.wait(timeout=5)


if __name__ == "__main__":
    _ = unittest.main()
