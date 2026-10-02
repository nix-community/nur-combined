from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from .models import PackageState
from .package_backend import _update_tangled_revision
from .transactions import FileTransaction


class TangledUpdateTests(unittest.TestCase):
    def test_revision_and_date_follow_default_branch(self) -> None:
        before = PackageState(
            "0.6.0-unstable-2026-07-31",
            "branch",
            src_url="https://tangled.org/did:plc:repository/archive/old",
            src_rev="old",
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "default.nix"
            path.write_text('version = "0.6.0-unstable-2026-07-31"; rev = "old";')
            with patch("updater.package_backend.run") as run:
                run.side_effect = [
                    subprocess.CompletedProcess([], 0, "", ""),
                    subprocess.CompletedProcess([], 0, "new\n2026-09-30\n", ""),
                ]
                self.assertTrue(_update_tangled_revision(path, before, timeout="1m"))
                self.assertEqual(
                    run.call_args_list[0].args[0][3],
                    "https://tangled.org/did:plc:repository",
                )
            self.assertEqual(
                path.read_text(), 'version = "0.6.0-unstable-2026-09-30"; rev = "new";'
            )

    def test_current_revision_does_not_change_file(self) -> None:
        before = PackageState(
            "0.6.0-unstable-2026-09-30",
            "branch",
            src_url="https://tangled.org/did:plc:repository/archive/current",
            src_rev="current",
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "default.nix"
            path.write_text("unchanged")
            with patch("updater.package_backend.run") as run:
                run.side_effect = [
                    subprocess.CompletedProcess([], 0, "", ""),
                    subprocess.CompletedProcess([], 0, "current\n2026-09-30\n", ""),
                ]
                self.assertFalse(_update_tangled_revision(path, before, timeout="1m"))
            self.assertEqual(path.read_text(), "unchanged")

    def test_already_dirty_owned_file_is_detected_and_restored(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "default.nix"
            path.write_text("prior edits")
            with (
                patch("updater.transactions.ROOT", root),
                patch("updater.transactions.git_changed_files", return_value={path}),
                FileTransaction([path]) as transaction,
            ):
                self.assertEqual(transaction.new_changed_files(), set())
                path.write_text("updated")
                self.assertEqual(transaction.new_changed_files(), {path})
                transaction.restore()
                self.assertEqual(path.read_text(), "prior edits")
                self.assertEqual(transaction.new_changed_files(), set())


if __name__ == "__main__":
    unittest.main()
