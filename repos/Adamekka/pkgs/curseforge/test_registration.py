import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import register_desktop


class DesktopRegistrationTests(unittest.TestCase):
    def setUp(self):
        directory = self.enterContext(tempfile.TemporaryDirectory())
        self.root = Path(directory)
        self.home = self.root / "home with spaces"
        self.home.mkdir()
        self.data = self.root / "data with spaces"
        self.source = self.root / "release one" / "curseforge.desktop"
        self.source.parent.mkdir()
        self.source.write_text("[Desktop Entry]\nName=CurseForge\nExec=/first/bin/curseforge %U\n")
        self.builder = self.root / "update-desktop-database"
        self.preferences = self.home / ".config" / "mimeapps.list"
        self.preferences.parent.mkdir()
        self.preferences.write_text("[Default Applications]\nx-scheme-handler/curseforge=custom.desktop;\n")
        self.original_preferences = self.preferences.read_bytes()
        self.enterContext(patch.dict(os.environ, {
            "HOME": str(self.home),
            "XDG_DATA_HOME": str(self.data),
        }, clear=True))
        self.build_database = self.enterContext(patch.object(register_desktop.subprocess, "run"))

    def register(self, source):
        with patch.object(sys, "argv", [register_desktop.__file__, str(source), str(self.builder)]):
            register_desktop.main()

    def assert_registered(self, source, data):
        managed = data / "curseforge-nix" / "curseforge.desktop"
        desktop = data / "applications" / "curseforge.desktop"
        self.assertTrue(managed.is_symlink())
        self.assertEqual(managed.readlink(), source)
        self.assertTrue(desktop.is_symlink())
        self.assertEqual(desktop.readlink(), managed)
        self.assertEqual(desktop.read_bytes(), source.read_bytes())
        self.assertEqual(self.preferences.read_bytes(), self.original_preferences)

    def test_registers_desktop_and_rebuilds_database_with_spaces_in_paths(self):
        self.register(self.source)

        self.assert_registered(self.source, self.data)
        self.build_database.assert_called_once_with(
            [str(self.builder), str(self.data / "applications")], check=True,
        )

    def test_upgrade_keeps_public_link_and_updates_managed_target(self):
        self.register(self.source)
        desktop = self.data / "applications" / "curseforge.desktop"
        stable_target = desktop.readlink()
        upgraded = self.root / "release two" / "curseforge.desktop"
        upgraded.parent.mkdir()
        upgraded.write_text("[Desktop Entry]\nName=CurseForge\nExec=/second/bin/curseforge %U\n")

        self.register(upgraded)

        self.assert_registered(upgraded, self.data)
        self.assertEqual(desktop.readlink(), stable_target)
        self.assertEqual(self.build_database.call_count, 2)

    def test_profile_upgrade_is_followed_without_registering_new_package(self):
        first_release = self.root / "installed first"
        second_release = self.root / "installed second"
        for release, executable in (
            (first_release, "/first-profile/bin/curseforge"),
            (second_release, "/second-profile/bin/curseforge"),
        ):
            entry = release / "share" / "applications" / "curseforge.desktop"
            entry.parent.mkdir(parents=True)
            entry.write_text(
                "[Desktop Entry]\nName=CurseForge\nX-Nix-CurseForge=true\n"
                f"Exec={executable} %U\n"
            )
        profile = self.home / ".nix-profile"
        profile.symlink_to(first_release)
        installed = profile / "share" / "applications" / "curseforge.desktop"
        os.environ["XDG_DATA_DIRS"] = str(profile / "share")

        self.register(first_release / "share" / "applications" / "curseforge.desktop")

        self.assert_registered(installed, self.data)
        profile.unlink()
        profile.symlink_to(second_release)
        self.assert_registered(installed, self.data)
        self.assertIn("Exec=/second-profile/bin/curseforge %U", installed.read_text())
        self.build_database.assert_called_once()

    def test_unmarked_installed_desktop_does_not_replace_running_package(self):
        installed_data = self.root / "system share"
        installed = installed_data / "applications" / "curseforge.desktop"
        installed.parent.mkdir(parents=True)
        os.environ["XDG_DATA_DIRS"] = str(installed_data)
        for marker in ("", "X-Nix-CurseForge=false\n"):
            with self.subTest(marker=marker):
                installed.write_text(
                    "[Desktop Entry]\nName=CurseForge\nExec=/foreign/bin/curseforge %U\n" + marker
                )

                self.register(self.source)

                self.assert_registered(self.source, self.data)

    def test_first_marked_installed_entry_in_search_order_wins(self):
        first_data = self.root / "first share"
        second_data = self.root / "second share"
        foreign_data = self.root / "foreign share"
        for directory, marker in (
            (first_data, "X-Nix-CurseForge=true\n"),
            (second_data, "X-Nix-CurseForge=true\n"),
            (foreign_data, ""),
        ):
            entry = directory / "applications" / "curseforge.desktop"
            entry.parent.mkdir(parents=True)
            entry.write_text("[Desktop Entry]\nName=CurseForge\nExec=/installed/bin/curseforge %U\n" + marker)
        for preferred, other in ((first_data, second_data), (second_data, first_data)):
            with self.subTest(preferred=preferred):
                os.environ["XDG_DATA_DIRS"] = os.pathsep.join(map(str, (foreign_data, preferred, other)))

                self.register(self.source)

                self.assert_registered(preferred / "applications" / "curseforge.desktop", self.data)

    def test_own_registration_is_excluded_from_installed_entries_including_aliases(self):
        self.source.write_text(self.source.read_text() + "X-Nix-CurseForge=true\n")
        self.register(self.source)
        alias = self.root / "data alias"
        alias.symlink_to(self.data)
        for directory in (self.data, alias):
            with self.subTest(directory=directory):
                os.environ["XDG_DATA_DIRS"] = str(directory)

                self.register(self.source)

                self.assert_registered(self.source, self.data)

    def test_installed_entry_does_not_hide_missing_running_package_source(self):
        installed_data = self.root / "installed share"
        installed = installed_data / "applications" / "curseforge.desktop"
        installed.parent.mkdir(parents=True)
        installed.write_text("[Desktop Entry]\nName=CurseForge\nX-Nix-CurseForge=true\n")
        os.environ["XDG_DATA_DIRS"] = str(installed_data)
        missing = self.root / "missing.desktop"

        with self.assertRaises((OSError, RuntimeError)) as failure:
            self.register(missing)

        self.assertIn(str(missing), str(failure.exception))
        self.build_database.assert_not_called()
        self.assertFalse(self.data.exists())

    def test_repeated_registration_rebuilds_cache_without_changing_links(self):
        self.register(self.source)

        self.register(self.source)

        self.assert_registered(self.source, self.data)
        self.assertEqual(self.build_database.call_count, 2)

    def test_unset_or_empty_data_home_uses_home_local_share(self):
        for value in (None, ""):
            with self.subTest(value=value):
                if value is None:
                    os.environ.pop("XDG_DATA_HOME")
                else:
                    os.environ["XDG_DATA_HOME"] = value
                self.register(self.source)
                self.assert_registered(self.source, self.home / ".local" / "share")
                self.build_database.assert_called_with(
                    [str(self.builder), str(self.home / ".local" / "share" / "applications")], check=True,
                )

    def test_missing_empty_or_relative_home_fails_clearly(self):
        for value in (None, "", "relative/home"):
            with self.subTest(value=value):
                if value is None:
                    os.environ.pop("HOME")
                else:
                    os.environ["HOME"] = value
                with self.assertRaisesRegex(RuntimeError, "HOME"):
                    self.register(self.source)
                self.build_database.assert_not_called()
                self.assertFalse(self.data.exists())

    def test_relative_data_home_fails_without_creating_state(self):
        os.environ["XDG_DATA_HOME"] = "relative/data"

        with self.assertRaisesRegex(RuntimeError, "XDG_DATA_HOME"):
            self.register(self.source)

        self.build_database.assert_not_called()
        self.assertFalse(self.data.exists())

    def test_relative_data_dirs_fail_without_creating_state(self):
        os.environ["XDG_DATA_DIRS"] = "/usr/share:relative/data"

        with self.assertRaisesRegex(RuntimeError, "XDG_DATA_DIRS"):
            self.register(self.source)

        self.build_database.assert_not_called()
        self.assertFalse(self.data.exists())

    def test_foreign_desktop_file_and_symlinks_are_preserved(self):
        desktop = self.data / "applications" / "curseforge.desktop"
        desktop.parent.mkdir(parents=True)
        foreign_source = self.root / "custom.desktop"
        foreign_source.write_text("User-owned desktop entry\n")
        for kind in ("regular file", "absolute symlink", "relative dangling symlink"):
            with self.subTest(kind=kind):
                if kind == "regular file":
                    desktop.write_text("User-owned registration\n")
                    original = desktop.read_bytes()
                elif kind == "absolute symlink":
                    desktop.symlink_to(foreign_source)
                    original = desktop.readlink()
                else:
                    desktop.symlink_to("missing-user-entry.desktop")
                    original = desktop.readlink()
                with self.assertRaisesRegex(RuntimeError, "[Cc]onflict|[Rr]efus|[Aa]lready|[Ee]xist"):
                    self.register(self.source)
                if kind == "regular file":
                    self.assertFalse(desktop.is_symlink())
                    self.assertEqual(desktop.read_bytes(), original)
                else:
                    self.assertTrue(desktop.is_symlink())
                    self.assertEqual(desktop.readlink(), original)
                self.assertEqual(self.preferences.read_bytes(), self.original_preferences)
                self.build_database.assert_not_called()
                desktop.unlink()

    def test_regular_file_at_managed_location_is_preserved(self):
        managed = self.data / "curseforge-nix" / "curseforge.desktop"
        managed.parent.mkdir(parents=True)
        managed.write_text("Unmanaged existing contents\n")

        with self.assertRaisesRegex(RuntimeError, "[Cc]onflict|[Rr]efus|[Aa]lready|[Ee]xist"):
            self.register(self.source)

        self.assertFalse(managed.is_symlink())
        self.assertEqual(managed.read_text(), "Unmanaged existing contents\n")
        self.build_database.assert_not_called()
        self.assertEqual(self.preferences.read_bytes(), self.original_preferences)

    def test_migrates_legacy_nix_profile_symlink(self):
        desktop = self.data / "applications" / "curseforge.desktop"
        desktop.parent.mkdir(parents=True)
        desktop.symlink_to(self.home / ".nix-profile" / "share" / "applications" / "curseforge.desktop")

        self.register(self.source)

        self.assert_registered(self.source, self.data)
        self.build_database.assert_called_once()

    def test_missing_source_or_directory_fails_before_registering(self):
        for source in (self.root / "missing.desktop", self.source.parent):
            with self.subTest(source=source):
                with self.assertRaises((OSError, RuntimeError)) as failure:
                    self.register(source)
                self.assertIn(str(source), str(failure.exception))
                self.build_database.assert_not_called()
                self.assertFalse(self.data.exists())

    def test_database_failure_surfaces_and_next_launch_can_retry(self):
        self.build_database.side_effect = subprocess.CalledProcessError(1, [str(self.builder)])

        with self.assertRaises(subprocess.CalledProcessError):
            self.register(self.source)

        self.assertEqual(self.preferences.read_bytes(), self.original_preferences)
        self.build_database.side_effect = None
        self.register(self.source)
        self.assert_registered(self.source, self.data)
        self.assertEqual(self.build_database.call_count, 2)

    def test_concurrent_launches_serialize_registration_and_cache_rebuild(self):
        events = self.root / "builder events.log"
        self.builder.write_text(
            f"#!{sys.executable}\n"
            "import os\n"
            "from pathlib import Path\n"
            "import time\n"
            f"events = Path({str(events)!r})\n"
            "with events.open('a') as output:\n"
            "    output.write(f'start {os.getpid()}\\n')\n"
            "time.sleep(0.1)\n"
            "with events.open('a') as output:\n"
            "    output.write(f'end {os.getpid()}\\n')\n"
        )
        self.builder.chmod(0o755)
        command = [sys.executable, register_desktop.__file__, str(self.source), str(self.builder)]
        children = [
            subprocess.Popen(command, env=os.environ.copy(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            for _ in range(2)
        ]
        try:
            for child in children:
                stdout, stderr = child.communicate(timeout=10)
                self.assertEqual(child.returncode, 0, stdout + stderr)
        finally:
            for child in children:
                if child.poll() is None:
                    child.kill()
                child.wait(timeout=5)

        self.assert_registered(self.source, self.data)
        records = [line.split() for line in events.read_text().splitlines()]
        self.assertEqual([event for event, _ in records], ["start", "end", "start", "end"])
        self.assertEqual(records[0][1], records[1][1])
        self.assertEqual(records[2][1], records[3][1])
        self.assertNotEqual(records[0][1], records[2][1])


if __name__ == "__main__":
    unittest.main()
