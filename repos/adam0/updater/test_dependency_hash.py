from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from .models import PackageRef, PackageState
from .package_backend import (
    _fake_hash,
    _refresh_dependency_hashes,
    package_hash_files,
    update_package,
)
from .process import CommandError


def _completed(
    returncode: int, stderr: str = "", stdout: str = ""
) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess([], returncode, stdout, stderr)


def _mismatch(declared: str, derived: str) -> str:
    return (
        "error: hash mismatch in fixed-output derivation '/nix/store/abc-drv':\n"
        f"         specified: {declared}\n"
        f"             got:    {derived}\n"
    )


def _package_ref(root: Path) -> PackageRef:
    return PackageRef(
        source_kind="file",
        attrset="albedo-git",
        attr="albedo-git",
        attr_path="albedo-git",
        file_path=root / "default.nix",
    )


class PackageHashFilesTests(unittest.TestCase):
    def test_directory_package_reports_its_entry_file_and_siblings(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "default.nix").write_text("")
            (root / "client.nix").write_text("")
            (root / "sub").mkdir()
            (root / "sub" / "plugin.nix").write_text("")
            (root / "release.json").write_text("{}")

            self.assertEqual(
                package_hash_files(root / "default.nix"),
                [root / "client.nix", root / "default.nix", root / "sub" / "plugin.nix"],
            )

    def test_flat_package_reports_only_its_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "pkg.nix").write_text("")

            self.assertEqual(package_hash_files(root / "pkg.nix"), [root / "pkg.nix"])


class DependencyHashRefreshTests(unittest.TestCase):
    def test_vendored_hash_of_a_sibling_file_follows_the_source(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "default.nix").write_text('src = {rev = "new";};\n')
            client = root / "client.nix"
            client.write_text('buildGoModule {\n  vendorHash = "sha256-old";\n}\n')
            reports = [
                _completed(1, stderr=_mismatch(_fake_hash(0), "sha256-vendored")),
                _completed(0),
            ]

            with patch("updater.package_backend.run", side_effect=reports) as run:
                self.assertTrue(_refresh_dependency_hashes(_package_ref(root), timeout="1m"))

            self.assertEqual(
                client.read_text(), 'buildGoModule {\n  vendorHash = "sha256-vendored";\n}\n'
            )
            self.assertEqual(run.call_count, 2)
            self.assertEqual(
                run.call_args.args[0], ["nix-build", "-A", "albedo-git", "--no-out-link"]
            )

    def test_unchanged_reported_hash_still_advances_the_refresh(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            entry = root / "default.nix"
            entry.write_text('cargoHash = "sha256-current";\n')
            reports = [
                _completed(1, stderr=_mismatch(_fake_hash(0), "sha256-current")),
                _completed(0),
            ]
            with patch("updater.package_backend.run", side_effect=reports) as run:
                self.assertFalse(_refresh_dependency_hashes(_package_ref(root), timeout="1m"))
            self.assertEqual(run.call_count, 2)
            self.assertEqual(entry.read_text(), 'cargoHash = "sha256-current";\n')

    def test_unchanged_hash_does_not_block_other_dependency_hashes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            entry = root / "default.nix"
            entry.write_text('vendorHash = "sha256-current";\ncargoHash = "sha256-old";\n')
            reports = [
                _completed(1, stderr=_mismatch(_fake_hash(0), "sha256-current")),
                _completed(1, stderr=_mismatch(_fake_hash(1), "sha256-new")),
                _completed(0),
            ]
            with patch("updater.package_backend.run", side_effect=reports) as run:
                self.assertTrue(_refresh_dependency_hashes(_package_ref(root), timeout="1m"))
            self.assertEqual(run.call_count, 3)
            self.assertEqual(
                entry.read_text(), 'vendorHash = "sha256-current";\ncargoHash = "sha256-new";\n'
            )

    def test_every_reported_dependency_hash_is_refreshed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "default.nix").write_text("")
            client = root / "client.nix"
            client.write_text('vendorHash = "sha256-old";\n')
            render = root / "render.nix"
            render.write_text('cargoHash = "sha256-older";\n')
            reports = [
                _completed(1, stderr=_mismatch(_fake_hash(1), "sha256-cargo")),
                _completed(1, stderr=_mismatch(_fake_hash(0), "sha256-vendor")),
                _completed(0),
            ]

            with patch("updater.package_backend.run", side_effect=reports) as run:
                self.assertTrue(_refresh_dependency_hashes(_package_ref(root), timeout="1m"))

            self.assertEqual(client.read_text(), 'vendorHash = "sha256-vendor";\n')
            self.assertEqual(render.read_text(), 'cargoHash = "sha256-cargo";\n')
            self.assertEqual(run.call_count, 3)

    def test_declared_hash_is_faked_before_the_build(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "default.nix").write_text("")
            client = root / "client.nix"
            client.write_text('vendorHash = "sha256-old";\n')
            seen: list[str] = []

            def fake_run(command: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
                seen.append(client.read_text())
                if len(seen) == 1:
                    return _completed(1, stderr=_mismatch(_fake_hash(0), "sha256-vendored"))
                return _completed(0)

            with patch("updater.package_backend.run", side_effect=fake_run):
                _refresh_dependency_hashes(_package_ref(root), timeout="1m")

            self.assertEqual(seen[0], f'vendorHash = "{_fake_hash(0)}";\n')
            self.assertEqual(seen[1], 'vendorHash = "sha256-vendored";\n')
            self.assertEqual(client.read_text(), 'vendorHash = "sha256-vendored";\n')

    def test_hash_no_build_derives_keeps_its_declared_value(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "default.nix").write_text("")
            plugin = root / "plugin.nix"
            plugin.write_text('vendorHash = "sha256-untouched";\n')

            with patch("updater.package_backend.run", return_value=_completed(0)):
                self.assertFalse(_refresh_dependency_hashes(_package_ref(root), timeout="1m"))

            self.assertEqual(plugin.read_text(), 'vendorHash = "sha256-untouched";\n')

    def test_package_without_declared_hashes_is_left_alone(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            entry = root / "default.nix"
            entry.write_text("pkgs.hello\n")

            with patch("updater.package_backend.run") as run:
                self.assertFalse(_refresh_dependency_hashes(_package_ref(root), timeout="1m"))

            run.assert_not_called()
            self.assertEqual(entry.read_text(), "pkgs.hello\n")

    def test_build_failure_without_a_reported_hash_restores_the_declaration(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "default.nix").write_text("")
            client = root / "client.nix"
            client.write_text('vendorHash = "sha256-old";\n')

            with (
                patch(
                    "updater.package_backend.run",
                    return_value=_completed(1, stderr="error: build of albedo-git failed\n"),
                ),
                self.assertRaises(CommandError),
            ):
                _refresh_dependency_hashes(_package_ref(root), timeout="1m")

            self.assertEqual(client.read_text(), 'vendorHash = "sha256-old";\n')


class UpdatePackageHashRefreshTests(unittest.TestCase):
    def update(self, refresh: object) -> tuple[str, str, Path]:
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        entry = root / "default.nix"
        entry.write_text("pkg\n")
        ref = PackageRef("file", "pkg", "pkg", "pkg", entry)
        before = PackageState("1.0.0", "stable", src_rev="old", src_hash="sha256-old")
        after = PackageState("1.0.0", "stable", src_rev="new", src_hash="sha256-new")

        def apply_update(*args: object, **kwargs: object) -> None:
            entry.write_text("pkg\n# new source\n")

        with (
            patch("updater.transactions.ROOT", root),
            patch("updater.transactions.git_changed_files", return_value=set()),
            patch("updater.validation.version_is_older", return_value=False),
            patch("updater.package_backend.read_state", side_effect=[before, after]),
            patch("updater.package_backend._run_nix_update", side_effect=apply_update),
            patch("updater.package_backend._update_source_with_verification", return_value=None),
            patch("updater.package_backend._refresh_dependency_hashes", refresh),
        ):
            result = update_package(ref, timeout="1m")

        return result.status, result.reason, entry

    def test_refreshed_hashes_are_accepted(self) -> None:
        status, reason, entry = self.update(lambda *args, **kwargs: True)

        self.assertEqual(status, "updated")
        self.assertEqual(reason, "accepted source/package transition")
        self.assertEqual(entry.read_text(), "pkg\n# new source\n")

    def test_failed_refresh_rejects_the_update(self) -> None:
        failure = CommandError(["nix", "build"], _completed(1, stderr="error: no hash reported"))
        status, reason, entry = self.update(lambda *args, **kwargs: (_ for _ in ()).throw(failure))

        self.assertEqual(status, "failed")
        self.assertIn("dependencyHash refresh failed", reason)
        self.assertEqual(entry.read_text(), "pkg\n")


if __name__ == "__main__":
    unittest.main()
