"""Regression coverage for source/lock consistency across failed updates."""

import tempfile
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


if __name__ == "__main__":
    unittest.main()
