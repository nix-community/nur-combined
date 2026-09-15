#!/usr/bin/env python3

import base64
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock
from urllib.parse import quote

from refresh_forgejo_flake_hash import (
    REGISTRY_URL,
    RefreshError,
    refresh,
    validate_file,
)

FILE = Path("packages/trev-mono/default.nix")
DEP_NAME = "llc/trev-mono"
DIGEST = "1f63c59eed00f9cf6327c80bd9d89e75ad6c60d7"
ARCHIVE_URL = f"{REGISTRY_URL}/{DEP_NAME}/archive/{DIGEST}.tar.gz"
OLD_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D"
NEW_HASH = "sha256-i6vLGIrZrH9YiFS4UNnJBLOI6sjLANqn1LkEbjGu4M0="


class RefreshForgejoFlakeHashTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        self.path = self.root / FILE
        self.path.parent.mkdir(parents=True)

    def write_flake(
        self,
        *,
        dep_name: str = DEP_NAME,
        digest: str = DIGEST,
        nar_hash: str = OLD_HASH,
    ) -> None:
        self.path.write_text(
            "{ system }:\n"
            "(builtins.getFlake\n"
            f'  "{REGISTRY_URL}/{dep_name}/archive/{digest}.tar.gz?narHash={nar_hash}" # v0.2.5\n'
            ').packages."${system}".default\n'
        )

    def prefetch_result(
        self, nar_hash: str = NEW_HASH
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.CompletedProcess(
            args=["nix"], returncode=0, stdout=json.dumps({"hash": nar_hash}), stderr=""
        )

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_refreshes_hash(self, run: mock.Mock) -> None:
        self.write_flake()
        run.return_value = self.prefetch_result()

        changed = refresh(FILE, DEP_NAME, self.root)

        self.assertTrue(changed)
        self.assertIn(f"narHash={quote(NEW_HASH, safe='-._~')}", self.path.read_text())
        run.assert_called_once_with(
            ["nix", "flake", "prefetch", "--json", ARCHIVE_URL],
            check=True,
            capture_output=True,
            text=True,
        )

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_supports_other_forgejo_dependencies(self, run: mock.Mock) -> None:
        dep_name = "acme/another-flake"
        self.write_flake(dep_name=dep_name)
        run.return_value = self.prefetch_result()

        changed = refresh(FILE, dep_name, self.root)

        self.assertTrue(changed)
        run.assert_called_once_with(
            [
                "nix",
                "flake",
                "prefetch",
                "--json",
                f"{REGISTRY_URL}/{dep_name}/archive/{DIGEST}.tar.gz",
            ],
            check=True,
            capture_output=True,
            text=True,
        )

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_percent_encodes_base64_characters(self, run: mock.Mock) -> None:
        self.write_flake()
        nar_hash = f"sha256-{base64.b64encode(bytes([251]) * 32).decode()}"
        run.return_value = self.prefetch_result(nar_hash)

        refresh(FILE, DEP_NAME, self.root)

        encoded = quote(nar_hash, safe="-._~")
        self.assertIn("%2B", encoded)
        self.assertIn("%2F", encoded)
        self.assertIn("%3D", encoded)
        self.assertIn(f"narHash={encoded}", self.path.read_text())

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_is_idempotent(self, run: mock.Mock) -> None:
        encoded = quote(NEW_HASH, safe="-._~")
        self.write_flake(nar_hash=encoded)
        run.return_value = self.prefetch_result()

        changed = refresh(FILE, DEP_NAME, self.root)

        self.assertFalse(changed)

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_rejects_wrong_or_ambiguous_target(self, run: mock.Mock) -> None:
        for content in (
            f'"{REGISTRY_URL}/other/repository/archive/{DIGEST}.tar.gz?narHash={OLD_HASH}"',
            "\n".join(
                [
                    f'"{ARCHIVE_URL}?narHash={OLD_HASH}"',
                    f'"{ARCHIVE_URL}?narHash={OLD_HASH}"',
                ]
            ),
        ):
            with self.subTest(content=content):
                self.path.write_text(content)
                original = self.path.read_bytes()
                with self.assertRaises(RefreshError):
                    refresh(FILE, DEP_NAME, self.root)
                self.assertEqual(original, self.path.read_bytes())
                run.assert_not_called()

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_rejects_invalid_prefetch_output(self, run: mock.Mock) -> None:
        self.write_flake()

        for stdout in ("not json", "{}", "[]", '{"hash":"sha256-invalid"}'):
            with self.subTest(stdout=stdout):
                run.return_value = subprocess.CompletedProcess(
                    args=["nix"], returncode=0, stdout=stdout, stderr=""
                )
                with self.assertRaises(RefreshError):
                    refresh(FILE, DEP_NAME, self.root)

    @mock.patch("refresh_forgejo_flake_hash.subprocess.run")
    def test_reports_prefetch_failure(self, run: mock.Mock) -> None:
        self.write_flake()
        run.side_effect = subprocess.CalledProcessError(
            returncode=1, cmd=["nix"], stderr="download failed"
        )

        with self.assertRaisesRegex(RefreshError, "download failed"):
            refresh(FILE, DEP_NAME, self.root)

    def test_rejects_unsafe_inputs(self) -> None:
        self.write_flake()

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
