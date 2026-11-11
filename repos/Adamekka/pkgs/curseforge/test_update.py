import base64
import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import update


class UpdateTests(unittest.TestCase):
    def setUp(self):
        directory = self.enterContext(tempfile.TemporaryDirectory())
        self.source = Path(directory) / "source.json"
        self.pinned_payload = b"previous Debian release"
        self.payload = b"new downloaded Debian release"
        self.current = {
            "hash": "sha256-" + base64.b64encode(hashlib.sha256(self.pinned_payload).digest()).decode(),
            "url": "https://curseforge.overwolf.com/electron/linux/CurseForge_1.9.0-99_amd64.deb",
            "version": "1.9.0-99",
        }
        self.original = json.dumps(self.current, indent="\t")
        self.source.write_text(self.original)
        self.metadata = "Package: curseforge\nVersion: 1.10.0~100-100\nArchitecture: amd64\n"

        def download(command, *, stdout, check):
            self.assertTrue(check)
            self.assertEqual(
                command[-1],
                "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.deb",
            )
            stdout.write(self.payload)

        def inspect_package(command, *, text):
            self.assertTrue(text)
            self.assertEqual(command[:2], ["dpkg-deb", "--field"])
            self.assertEqual(Path(command[2]).read_bytes(), self.payload)
            return self.metadata

        self.enterContext(patch.object(update, "__file__", str(Path(directory) / "update.py")))
        self.download = self.enterContext(patch.object(update.subprocess, "run", side_effect=download))
        self.inspect = self.enterContext(
            patch.object(update.subprocess, "check_output", side_effect=inspect_package)
        )
        self.enterContext(patch("builtins.print"))

    def test_update_pins_versioned_official_url_and_downloaded_hash(self):
        update.main()

        self.assertEqual(json.loads(self.source.read_text()), {
            "hash": "sha256-" + base64.b64encode(hashlib.sha256(self.payload).digest()).decode(),
            "url": "https://curseforge.overwolf.com/electron/linux/CurseForge_1.10.0-100_amd64.deb",
            "version": "1.10.0-100",
        })
        self.assertEqual(self.download.call_count, 1)
        self.assertEqual(self.inspect.call_count, 1)

    def test_build_numbers_are_compared_numerically(self):
        self.current["version"] = "1.10.0-9"
        self.source.write_text(json.dumps(self.current))
        self.metadata = "Package: curseforge\nVersion: 1.10.0~10-10\nArchitecture: amd64\n"

        update.main()

        self.assertEqual(json.loads(self.source.read_text())["version"], "1.10.0-10")

    def test_unchanged_pin_does_not_write_or_reformat(self):
        self.payload = self.pinned_payload
        self.metadata = "Package: curseforge\nVersion: 1.9.0~99-99\nArchitecture: amd64\n"

        with patch.object(Path, "write_text") as write:
            update.main()

        write.assert_not_called()
        self.assertEqual(self.source.read_text(), self.original)

    def test_same_version_can_migrate_to_versioned_url_with_same_hash(self):
        self.current["url"] = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.deb"
        self.source.write_text(json.dumps(self.current))
        self.payload = self.pinned_payload
        self.metadata = "Package: curseforge\nVersion: 1.9.0~99-99\nArchitecture: amd64\n"

        update.main()

        self.assertEqual(json.loads(self.source.read_text()), {
            **self.current,
            "url": "https://curseforge.overwolf.com/electron/linux/CurseForge_1.9.0-99_amd64.deb",
        })

    def test_wrong_package_or_architecture_does_not_write(self):
        for metadata in (
            "Package: unrelated\nVersion: 1.10.0~100-100\nArchitecture: amd64\n",
            "Package: curseforge\nVersion: 1.10.0~100-100\nArchitecture: arm64\n",
            "Version: 1.10.0~100-100\nArchitecture: amd64\n",
        ):
            with self.subTest(metadata=metadata):
                self.metadata = metadata
                with (
                    patch.object(Path, "write_text") as write,
                    self.assertRaisesRegex(RuntimeError, "Unexpected Debian package identity"),
                ):
                    update.main()
                write.assert_not_called()
                self.assertEqual(self.source.read_text(), self.original)

    def test_invalid_version_or_mismatched_debian_build_does_not_write(self):
        for version in (
            "1.10.0~100-101",
            "1.10.0-100",
            "1.10.0~100-100-extra",
            "1.10.0-beta~100-100",
            "2:1.10.0~100-100",
            "",
        ):
            with self.subTest(version=version):
                self.metadata = f"Package: curseforge\nVersion: {version}\nArchitecture: amd64\n"
                with (
                    patch.object(Path, "write_text") as write,
                    self.assertRaisesRegex(RuntimeError, "Unexpected Debian version"),
                ):
                    update.main()
                write.assert_not_called()
                self.assertEqual(self.source.read_text(), self.original)

    def test_numeric_downgrades_do_not_write(self):
        self.current["version"] = "1.10.0-100"
        original = json.dumps(self.current)
        self.source.write_text(original)
        for version in ("1.9.9~999-999", "1.10.0~99-99"):
            with self.subTest(version=version):
                self.metadata = f"Package: curseforge\nVersion: {version}\nArchitecture: amd64\n"
                with (
                    patch.object(Path, "write_text") as write,
                    self.assertRaisesRegex(RuntimeError, "Refusing to downgrade CurseForge"),
                ):
                    update.main()
                write.assert_not_called()
                self.assertEqual(self.source.read_text(), original)

    def test_changed_archive_with_same_version_does_not_write(self):
        self.metadata = "Package: curseforge\nVersion: 1.9.0~99-99\nArchitecture: amd64\n"

        with (
            patch.object(Path, "write_text") as write,
            self.assertRaisesRegex(RuntimeError, "Archive changed without a version bump"),
        ):
            update.main()

        write.assert_not_called()
        self.assertEqual(self.source.read_text(), self.original)

    def test_partial_download_failure_does_not_inspect_or_write(self):
        def fail_download(command, *, stdout, check):
            stdout.write(b"incomplete archive")
            raise subprocess.CalledProcessError(28, command)

        self.download.side_effect = fail_download
        with patch.object(Path, "write_text") as write, self.assertRaises(subprocess.CalledProcessError):
            update.main()

        self.inspect.assert_not_called()
        write.assert_not_called()
        self.assertEqual(self.source.read_text(), self.original)

    def test_invalid_archive_or_unavailable_dpkg_does_not_write(self):
        for error in (subprocess.CalledProcessError(2, ["dpkg-deb"]), FileNotFoundError("dpkg-deb")):
            with self.subTest(error=error):
                self.inspect.side_effect = error
                with patch.object(Path, "write_text") as write, self.assertRaises(type(error)):
                    update.main()
                write.assert_not_called()
                self.assertEqual(self.source.read_text(), self.original)

    def test_invalid_pinned_version_does_not_download_or_write(self):
        self.current["version"] = "1.9.0"
        original = json.dumps(self.current)
        self.source.write_text(original)

        with (
            patch.object(Path, "write_text") as write,
            self.assertRaisesRegex(RuntimeError, "Unexpected pinned version"),
        ):
            update.main()

        self.download.assert_not_called()
        self.inspect.assert_not_called()
        write.assert_not_called()
        self.assertEqual(self.source.read_text(), original)


if __name__ == "__main__":
    unittest.main()
