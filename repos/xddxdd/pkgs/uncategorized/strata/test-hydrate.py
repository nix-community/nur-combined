import importlib.util
import os
import sys
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("hydrate", sys.argv.pop(1))
hydration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hydration)


class HydrationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.source = self.root / "store-one" / "share" / "strata"
        self.dest = self.root / "fresh" / "data" / "strata"
        self.put(self.source / "setup.py", "code one")
        self.put(self.source / "engine" / "strata", "engine one")
        self.put(self.source / "data" / "profile.bin", "packaged profile")

    def put(self, path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)

    def run_hydration(self):
        hydration.hydrate(self.source, self.dest)

    def test_fresh_parent_and_writable_files(self):
        (self.source / "engine" / "strata").chmod(0o555)
        self.run_hydration()
        self.assertEqual((self.dest / "setup.py").read_text(), "code one")
        self.assertTrue((self.dest / "engine" / "strata").stat().st_mode & 0o200)

    def test_legacy_data_config_and_extra_engine_files_survive(self):
        self.put(self.dest / ".nix-store-version", "old")
        self.put(self.dest / "data" / "profile.bin", "user profile")
        self.put(self.dest / "data" / "models" / "model.gguf", "user model")
        self.put(self.dest / "strata-user.json", "user config")
        self.put(self.dest / "engine" / "custom", "user engine")
        model = self.dest / "data" / "models" / "model.gguf"
        model.chmod(0o444)
        before = model.stat()
        self.run_hydration()
        self.assertEqual(
            (self.dest / "data" / "profile.bin").read_text(), "user profile"
        )
        self.assertEqual(model.read_text(), "user model")
        self.assertEqual(model.stat().st_mode, before.st_mode)
        self.assertEqual(model.stat().st_mtime_ns, before.st_mtime_ns)
        self.assertEqual((self.dest / "strata-user.json").read_text(), "user config")
        self.assertEqual((self.dest / "engine" / "custom").read_text(), "user engine")

    def test_output_identity_refresh_and_backup(self):
        self.run_hydration()
        old = self.source
        self.source = self.root / "store-two" / "share" / "strata"
        self.put(self.source / "setup.py", "code two")
        self.put(self.source / "engine" / "strata", "engine two")
        self.run_hydration()
        self.assertEqual((self.dest / "engine" / "strata").read_text(), "engine two")
        self.assertEqual(
            (self.dest / ".nix-store-path").read_text().strip(), str(self.source)
        )
        backups = list(self.dest.glob(".nix-backup-*/engine/strata"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(
            backups[0].read_text(), (old / "engine" / "strata").read_text()
        )

    def test_repeat_is_noop(self):
        self.run_hydration()
        code = self.dest / "setup.py"
        before = code.stat()
        self.run_hydration()
        self.assertEqual(code.stat().st_ino, before.st_ino)
        self.assertEqual(code.stat().st_mtime_ns, before.st_mtime_ns)
        self.assertFalse(list(self.dest.glob(".nix-backup-*")))

    def test_data_symlink_is_not_followed(self):
        target = self.root / "external-data"
        self.put(target / "profile.bin", "user data")
        self.dest.mkdir(parents=True)
        (self.dest / "data").symlink_to(target, target_is_directory=True)
        before = (target / "profile.bin").stat()
        self.run_hydration()
        self.assertTrue((self.dest / "data").is_symlink())
        self.assertEqual((target / "profile.bin").read_text(), "user data")
        self.assertEqual((target / "profile.bin").stat(), before)

    def test_engine_directory_symlink_fails_closed(self):
        target = self.root / "external-engine"
        self.put(target / "strata", "user engine")
        self.dest.mkdir(parents=True)
        (self.dest / "engine").symlink_to(target, target_is_directory=True)
        with self.assertRaises(RuntimeError):
            self.run_hydration()
        self.assertEqual((target / "strata").read_text(), "user engine")
        self.assertFalse((self.dest / ".nix-store-path").exists())

    def test_destination_symlink_fails_closed(self):
        target = self.root / "external-root"
        target.mkdir()
        self.dest.parent.mkdir(parents=True)
        self.dest.symlink_to(target, target_is_directory=True)
        with self.assertRaises(RuntimeError):
            self.run_hydration()
        self.assertEqual(list(target.iterdir()), [])

    def test_runtime_file_symlink_is_backed_up_not_followed(self):
        target = self.root / "external.py"
        target.write_text("user source")
        self.dest.mkdir(parents=True)
        (self.dest / "setup.py").symlink_to(target)
        self.run_hydration()
        self.assertEqual(target.read_text(), "user source")
        self.assertFalse((self.dest / "setup.py").is_symlink())
        backups = list(self.dest.glob(".nix-backup-*/setup.py"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(os.readlink(backups[0]), str(target))


if __name__ == "__main__":
    unittest.main()
