import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import cast
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import maintain


class MaintenanceTests(unittest.TestCase):
    def test_update_command_comes_from_package(self) -> None:
        command = ["nix-update", "-f", ".", "--version=branch=main", "example.source"]
        with patch.object(
            maintain, "run", return_value=json.dumps({"command": command})
        ) as run:
            self.assertEqual(maintain.update_command(Path.cwd(), "example"), command)
        self.assertIn("--argstr", cast(list[str], run.call_args.args[1]))
        with self.assertRaises(ValueError):
            _ = maintain.update_command(Path.cwd(), "../example")

    def test_official_script_forms_and_attrpath(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for declaration in (
                '"/bin/true"',
                '[ "/bin/true" "argument" ]',
                '{ command = [ "/bin/true" ]; attrPath = "nested"; supportedFeatures = [ "commit" ]; }',
            ):
                _ = (root / "default.nix").write_text(
                    '{ ... }: { example = { name = "example-1"; pname = "example"; version = "1"; updateScript = '
                    + declaration
                    + '; }; nested = { name = "nested-2"; pname = "nested"; version = "2"; }; }'
                )
                info = maintain.update_info(root, "example")
                self.assertEqual(cast(list[str], info["command"])[0], "/bin/true")
                if "attrPath" in declaration:
                    self.assertEqual(info["identity"], "2")
                    self.assertEqual(info["supportedFeatures"], ["commit"])
                    self.assertEqual(
                        cast(dict[str, str], info["env"])["UPDATE_NIX_ATTR_PATH"],
                        "nested",
                    )

    def test_check_builds_standard_tests(self) -> None:
        with (
            patch.object(maintain, "update_command"),
            patch.object(maintain, "run") as run,
        ):
            maintain.check(Path.cwd(), "example", run_lint=False)
        run.assert_called_once_with(
            Path.cwd(),
            ["nix", "build", "-f", ".", "example", "example.tests", "--no-link"],
        )

    def test_publish_rejects_outside_and_concurrent_changes(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            folder = root / "pkgs/example"
            folder.mkdir(parents=True)
            target = folder / "default.nix"
            _ = target.write_text("old")
            before = maintain.snapshot(root)
            with self.assertRaisesRegex(ValueError, "outside"):
                maintain.publish(root, before, before | {"outside": b"bad"}, "example")
            _ = target.write_text("concurrent")
            with self.assertRaisesRegex(ValueError, "Working files"):
                maintain.publish(root, before, before, "example")
            self.assertEqual(target.read_text(), "concurrent")

    def test_update_is_isolated_and_validation_precedes_publish(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            folder = root / "pkgs/example"
            folder.mkdir(parents=True)
            target = folder / "default.nix"
            _ = target.write_text("old")

            def run(directory: Path, command: list[str], **_kwargs: object) -> str:
                if command[0] == "nix-update":
                    self.assertNotEqual(directory, root)
                    _ = (directory / "pkgs/example/default.nix").write_text("new")
                return ""

            with (
                patch.object(
                    maintain,
                    "update_info",
                    return_value={"command": ["nix-update", "example"], "env": {}},
                ),
                patch.object(maintain, "run", side_effect=run),
                patch.object(
                    maintain,
                    "check",
                    side_effect=subprocess.CalledProcessError(1, "check"),
                ),
                self.assertRaises(subprocess.CalledProcessError),
            ):
                _ = maintain.update(root, "example")
            self.assertEqual(target.read_text(), "old")
            with (
                patch.object(
                    maintain,
                    "update_info",
                    return_value={"command": ["nix-update", "example"], "env": {}},
                ),
                patch.object(maintain, "run", side_effect=run),
                patch.object(maintain, "check"),
            ):
                self.assertTrue(maintain.update(root, "example"))
            self.assertEqual(target.read_text(), "new")

    def test_failed_custom_script_preserves_working_tree(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            folder = root / "pkgs/example"
            folder.mkdir(parents=True)
            _ = (folder / "default.nix").write_text("old")
            _ = (folder / "update.py").write_text("")
            before = maintain.snapshot(root)

            def run(directory: Path, command: list[str], **kwargs: object) -> str:
                if command[0] == "nix-update":
                    _ = (directory / "pkgs/example/default.nix").write_text("new")
                    self.assertEqual(
                        cast(dict[str, str], kwargs["env"])["NUR_ACCEPT_CONTRACT"], "0"
                    )
                    raise subprocess.CalledProcessError(1, command)
                return ""

            with (
                patch.object(
                    maintain,
                    "update_info",
                    return_value={"command": ["nix-update", "example"], "env": {}},
                ),
                patch.object(maintain, "run", side_effect=run),
                patch.object(maintain, "check") as check,
                self.assertRaises(subprocess.CalledProcessError),
            ):
                _ = maintain.update(root, "example")
            check.assert_not_called()
            self.assertEqual(maintain.snapshot(root), before)

    def test_real_packages_export_update_scripts_and_tests(self) -> None:
        for package in maintain.packages(maintain.ROOT):
            command = maintain.update_command(maintain.ROOT, package)
            self.assertTrue(command[0].startswith("/nix/store/"))
            tests = maintain.run(
                maintain.ROOT,
                [
                    "nix",
                    "eval",
                    "-f",
                    ".",
                    package + ".tests",
                    "--apply",
                    "builtins.attrNames",
                    "--json",
                ],
                capture=True,
            )
            self.assertIn("packaging", cast(list[str], json.loads(tests)))
            self.assertFalse(
                (maintain.ROOT / "pkgs" / package / "maintenance.toml").exists()
            )


if __name__ == "__main__":
    _ = unittest.main()
