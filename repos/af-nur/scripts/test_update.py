"""Regression coverage for source discovery and transactional dependency updates."""

import http.server
import subprocess
import tempfile
import threading
import tomllib
import unittest
from pathlib import Path

from update import Transaction


class UpdateTransactionTests(unittest.TestCase):
    def test_unexpected_failure_restores_sources_and_secondary_locks(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sources = root / "_sources"
            (sources / "old").mkdir(parents=True)
            metadata = sources / "generated.nix"
            metadata.write_text('lockFile = ./old/Cargo.lock;\n')
            cargo = sources / "old/Cargo.lock"
            cargo.write_text("old cargo dependencies\n")
            bun = root / "bun.nix"
            bun.write_text("old bun dependencies\n")
            created = root / "new-output.nix"

            with self.assertRaisesRegex(OSError, "secondary update failed"):
                with Transaction([sources, bun, created]):
                    cargo.unlink()
                    (sources / "new").mkdir()
                    (sources / "new/Cargo.lock").write_text("new cargo dependencies\n")
                    metadata.write_text('lockFile = ./new/Cargo.lock;\n')
                    bun.write_text("new bun dependencies\n")
                    created.write_text("partial output\n")
                    raise OSError("secondary update failed")

            self.assertEqual(metadata.read_text(), 'lockFile = ./old/Cargo.lock;\n')
            self.assertEqual(cargo.read_text(), "old cargo dependencies\n")
            self.assertEqual(bun.read_text(), "old bun dependencies\n")
            self.assertFalse((sources / "new").exists())
            self.assertFalse(created.exists())

    def test_success_keeps_updated_lock_and_new_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lock = root / "flake.lock"
            lock.write_text("old toolchain\n")
            created = root / "bun.nix"
            with Transaction([lock, created]):
                lock.write_text("new toolchain\n")
                created.write_text("matching dependencies\n")
            self.assertEqual(lock.read_text(), "new toolchain\n")
            self.assertEqual(created.read_text(), "matching dependencies\n")


class AiotVersionTests(unittest.TestCase):
    def test_download_version_ignores_unrelated_prefetched_chunks(self):
        config = tomllib.loads(
            (Path(__file__).resolve().parents[1] / "nvfetcher.toml").read_text()
        )
        requests = []
        pages = {
            "/zh/guide/start/use-ide.html": (
                '<link rel="prefetch" href="/assets/js/1.aaaa.js">'
                '<link rel="preload" href="/assets/js/29.bbbb.js" as="script">'
                '<script src="/assets/js/5.cccc.js" defer></script>'
                '<script src="/assets/js/29.bbbb.js" defer></script>'
            ),
            "/assets/js/1.aaaa.js": 'ubuntu:"AIoT_IDE_ubuntu",version:"9.9.9"',
            "/assets/js/5.cccc.js": 'version:"2.0.0"',
            "/assets/js/29.bbbb.js": 'ubuntu:"AIoT_IDE_ubuntu",version:"1.7.0"',
        }

        class Handler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                requests.append(self.path)
                body = pages.get(self.path)
                self.send_response(200 if body is not None else 404)
                self.end_headers()
                if body is not None:
                    self.wfile.write(body.encode())

            def log_message(self, *args):
                pass

        with http.server.HTTPServer(("127.0.0.1", 0), Handler) as server:
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            command = config["aiot-ide"]["src"]["cmd"].replace(
                "https://iot.mi.com/vela/quickapp",
                f"http://127.0.0.1:{server.server_port}",
            )
            try:
                result = subprocess.run(
                    ["sh", "-c", command],
                    capture_output=True, text=True, timeout=10,
                )
            finally:
                server.shutdown()
                thread.join()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "1.7.0\n")
        self.assertEqual(requests, [
            "/zh/guide/start/use-ide.html",
            "/assets/js/5.cccc.js",
            "/assets/js/29.bbbb.js",
        ])


if __name__ == "__main__":
    unittest.main()
