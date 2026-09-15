#!/usr/bin/env python3

import base64
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from refresh_forgejo_flake_hash import RefreshError, refresh, validate_file

FILE = Path("packages/trev-mono/default.nix")
DEP_NAME = "llc/trev-mono"
URL = "https://trev.zip/llc/trev-mono"
REV = "1f63c59eed00f9cf6327c80bd9d89e75ad6c60d7"
ARCHIVE_URL = f"{URL}/archive/{REV}.tar.gz"
OLD_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
NEW_HASH = "sha256-i6vLGIrZrH9YiFS4UNnJBLOI6sjLANqn1LkEbjGu4M0="


def flake_block(
    *,
    url: str = URL,
    rev: str = REV,
    nar_hash: str = OLD_HASH,
    version: str = "v0.2.5",
) -> str:
    return (
        "(getForgejoFlake {\n"
        f'  url = "{url}";\n'
        f'  rev = "{rev}"; # {version}\n'
        f'  hash = "{nar_hash}";\n'
        "})"
    )


class RefreshForgejoFlakeHashTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        self.path = self.root / FILE
        self.path.parent.mkdir(parents=True)

    def write_flakes(self, *flakes: str) -> None:
        self.path.write_text("\n".join(flakes))

    def prefetch_result(
        self, nar_hash: str = NEW_HASH
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(
            args=["nix"], returncode=0, stdout=json.dumps({"hash": nar_hash}), stderr=""
        )

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_refreshes_hash(self, run: mock.Mock) -> None:
        self.write_flakes(flake_block())
        run.return_value = self.prefetch_result()

        changed = refresh(FILE, DEP_NAME, self.root)

        self.assertTrue(changed)
        self.assertIn(f'hash = "{NEW_HASH}";', self.path.read_text())
        run.assert_called_once_with(
            ["nix", "flake", "prefetch", "--json", ARCHIVE_URL],
            check=True,
            capture_output=True,
            text=True,
        )

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_supports_other_origins_and_dependencies(self, run: mock.Mock) -> None:
        dep_name = "acme/another-flake"
        url = f"https://forgejo.example.com:8443/{dep_name}"
        self.write_flakes(flake_block(url=url))
        run.return_value = self.prefetch_result()

        changed = refresh(FILE, dep_name, self.root)

        self.assertTrue(changed)
        run.assert_called_once_with(
            ["nix", "flake", "prefetch", "--json", f"{url}/archive/{REV}.tar.gz"],
            check=True,
            capture_output=True,
            text=True,
        )

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_preserves_raw_base64_characters(self, run: mock.Mock) -> None:
        self.write_flakes(flake_block())
        nar_hash = f"sha256-{base64.b64encode(bytes([251]) * 32).decode()}"
        run.return_value = self.prefetch_result(nar_hash)

        refresh(FILE, DEP_NAME, self.root)

        content = self.path.read_text()
        self.assertIn(f'hash = "{nar_hash}";', content)
        self.assertNotIn("%2B", content)
        self.assertNotIn("%2F", content)
        self.assertNotIn("%3D", content)

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_updates_only_requested_dependency(self, run: mock.Mock) -> None:
        other_hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
        self.write_flakes(
            flake_block(),
            flake_block(
                url="https://forgejo.example.com/acme/other",
                nar_hash=other_hash,
            ),
        )
        run.return_value = self.prefetch_result()

        refresh(FILE, DEP_NAME, self.root)

        content = self.path.read_text()
        self.assertIn(f'hash = "{NEW_HASH}";', content)
        self.assertIn(f'hash = "{other_hash}";', content)

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_is_idempotent(self, run: mock.Mock) -> None:
        self.write_flakes(flake_block(nar_hash=NEW_HASH))
        run.return_value = self.prefetch_result()

        changed = refresh(FILE, DEP_NAME, self.root)

        self.assertFalse(changed)

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_rejects_missing_or_ambiguous_target(self, run: mock.Mock) -> None:
        for content in (
            flake_block(url="https://trev.zip/other/repository"),
            f"{flake_block()}\n{flake_block()}",
        ):
            with self.subTest(content=content):
                self.path.write_text(content)
                original = self.path.read_bytes()
                with self.assertRaises(RefreshError):
                    refresh(FILE, DEP_NAME, self.root)
                self.assertEqual(original, self.path.read_bytes())
                run.assert_not_called()

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_rejects_invalid_flake_fields(self, run: mock.Mock) -> None:
        cases = (
            flake_block(url="https://user@trev.zip/llc/trev-mono"),
            flake_block(url="https://trev.zip/llc/trev-mono?ref=main"),
            flake_block(rev="not-a-revision"),
            flake_block(nar_hash="sha256-invalid"),
        )

        for content in cases:
            with self.subTest(content=content):
                self.path.write_text(content)
                with self.assertRaises(RefreshError):
                    refresh(FILE, DEP_NAME, self.root)
                run.assert_not_called()

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_rejects_invalid_prefetch_output(self, run: mock.Mock) -> None:
        self.write_flakes(flake_block())

        for stdout in ("not json", "{}", "[]", '{"hash":"sha256-invalid"}'):
            with self.subTest(stdout=stdout):
                run.return_value = subprocess.CompletedProcess(
                    args=["nix"], returncode=0, stdout=stdout, stderr=""
                )
                with self.assertRaises(RefreshError):
                    refresh(FILE, DEP_NAME, self.root)

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_reports_prefetch_failure(self, run: mock.Mock) -> None:
        self.write_flakes(flake_block())
        run.side_effect = subprocess.CalledProcessError(
            returncode=1, cmd=["nix"], stderr="download failed"
        )

        with self.assertRaisesRegex(RefreshError, "download failed"):
            refresh(FILE, DEP_NAME, self.root)

    def test_rejects_unsafe_inputs(self) -> None:
        self.write_flakes(flake_block())

        with self.assertRaises(RefreshError):
            refresh(FILE, "../trev-mono", self.root)

        with self.assertRaises(RefreshError):
            validate_file(self.root, Path("../default.nix"))

        symlink = self.root / "packages/trev-mono/link.nix"
        symlink.symlink_to(self.path)
        with self.assertRaises(RefreshError):
            validate_file(self.root, symlink.relative_to(self.root))


if __name__ == "__main__":
    unittest.main()
