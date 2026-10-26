from __future__ import annotations

import shutil
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from .transactions import FileTransaction


class FileTransactionTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.path = self.root / "default.nix"
        self.path.write_text("original")
        changed = patch("updater.transactions.git_changed_files", return_value=set())
        changed.start()
        self.addCleanup(changed.stop)

    def test_uncommitted_changes_are_restored(self):
        with FileTransaction([self.root]):
            self.path.write_text("updated")
            (self.root / "new.txt").write_text("new")
        self.assertEqual(self.path.read_text(), "original")
        self.assertFalse((self.root / "new.txt").exists())

    def test_explicit_commit_keeps_changes(self):
        with FileTransaction([self.path]) as transaction:
            self.path.write_text("updated")
            transaction.commit()
        self.assertEqual(self.path.read_text(), "updated")

    def test_exception_restores_even_after_commit(self):
        with (
            self.assertRaisesRegex(ValueError, "failed"),
            FileTransaction([self.path]) as transaction,
        ):
            self.path.write_text("updated")
            transaction.commit()
            raise ValueError("failed")
        self.assertEqual(self.path.read_text(), "original")

    def test_snapshot_is_taken_on_entry(self):
        transaction = FileTransaction([self.path])
        self.path.write_text("edited before entry")
        with transaction:
            self.path.write_text("updated")
        self.assertEqual(self.path.read_text(), "edited before entry")

    def test_deleted_directories_are_restored(self):
        nested = self.root / "nested"
        nested.mkdir()
        (nested / "file").write_text("nested original")
        with FileTransaction([self.root]):
            shutil.rmtree(nested)
        self.assertEqual((nested / "file").read_text(), "nested original")

    def test_backup_names_cannot_collide(self):
        nested = self.root / "a"
        nested.mkdir()
        first = nested / "b"
        second = self.root / "a__b"
        first.write_text("first")
        second.write_text("second")
        with FileTransaction([self.root]):
            first.write_text("changed")
            second.write_text("changed")
        self.assertEqual(first.read_text(), "first")
        self.assertEqual(second.read_text(), "second")

    def test_new_owned_path_is_removed(self):
        new_path = self.root / "new.txt"
        with FileTransaction([new_path]):
            new_path.write_text("new")
        self.assertFalse(new_path.exists())

    def test_changed_files_compare_against_entry_not_clean_checkout(self):
        with (
            patch("updater.transactions.git_changed_files", return_value={self.path}),
            FileTransaction([self.path]) as transaction,
        ):
            self.assertEqual(transaction.new_changed_files(), set())
            self.path.write_text("updated")
            self.assertEqual(transaction.new_changed_files(), {self.path})


if __name__ == "__main__":
    unittest.main()
