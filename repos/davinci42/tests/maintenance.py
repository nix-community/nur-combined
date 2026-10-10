import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from typing import TYPE_CHECKING, cast, override
from unittest.mock import patch

if TYPE_CHECKING:
    from tools import maintain
else:
    spec = importlib.util.spec_from_file_location(
        "maintain", Path(__file__).resolve().parents[1] / "tools/maintain.py"
    )
    if spec is None or spec.loader is None:
        raise ImportError("Cannot load maintenance tool")
    maintain = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(maintain)


class MaintenanceTests(unittest.TestCase):
    root: Path = Path()
    package: Path = Path()
    commands: list[list[str]]

    def __init__(self, methodName: str = "runTest") -> None:
        super().__init__(methodName)
        self.commands = []

    @override
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.commands = []
        self.package = self.root / "pkgs/example"
        self.package.mkdir(parents=True)
        _ = (self.package / "default.nix").write_text('version = "1";')
        _ = (self.package / "settings-schema.json").write_text(
            json.dumps({"version": "1", "fields": {}})
        )
        _ = (self.package / "maintenance.toml").write_text(
            'files = ["default.nix", "settings-schema.json"]\n'
            + 'sync = ["generate"]\ncontract = ["verify"]\n'
        )

    def fake_run(self, root: Path, command: list[str], **_kwargs: object) -> None:
        self.commands.append(command)
        if command[0] == "nix-update" and "--version=stable" in command:
            _ = (root / "pkgs/example/default.nix").write_text('version = "2";')
        if command == ["generate"]:
            _ = (root / "pkgs/example/settings-schema.json").write_text(
                json.dumps({"version": "2", "fields": {}})
            )

    def test_isolated_update_and_all_hashes(self):
        self.commands = []
        with (
            patch.object(
                maintain,
                "package_info",
                side_effect=[
                    ("1", ["aarch64-linux", "x86_64-linux"]),
                    ("2", ["aarch64-linux", "x86_64-linux"]),
                    ("2", []),
                    ("2", []),
                ],
            ),
            patch.object(maintain, "run", side_effect=self.fake_run),
            patch.object(maintain, "check") as check,
        ):
            maintain.update(self.root, "example", "stable")
        updates = [command for command in self.commands if command[0] == "nix-update"]
        self.assertEqual(len(updates), 3)
        self.assertEqual(
            [command[-1] for command in updates],
            ["--version=stable", "--version=skip", "--version=skip"],
        )
        self.assertEqual(
            [command[-2] for command in updates],
            ["aarch64-linux", "aarch64-linux", "x86_64-linux"],
        )
        self.assertIsNotNone(check.call_args)
        assert check.call_args is not None
        self.assertNotEqual(cast(object, check.call_args.args[0]), self.root)
        self.assertEqual((self.package / "default.nix").read_text(), 'version = "2";')
        self.assertEqual(self.commands[-2:], [["generate"], ["verify"]])

    def test_build_failure_leaves_working_tree_unchanged(self):
        self.commands = []
        before = maintain.snapshot(self.root)
        with (
            patch.object(
                maintain, "package_info", return_value=("2", ["x86_64-linux"])
            ),
            patch.object(maintain, "run", side_effect=self.fake_run),
            patch.object(
                maintain,
                "check",
                side_effect=subprocess.CalledProcessError(1, ["build"]),
            ),
            self.assertRaises(subprocess.CalledProcessError),
        ):
            maintain.update(self.root, "example", "stable")
        self.assertEqual(maintain.snapshot(self.root), before)

    def test_contract_requires_explicit_review(self):
        self.commands = []
        before = maintain.snapshot(self.root)

        def update_contract(root: Path, command: list[str], **kwargs: object) -> None:
            self.fake_run(root, command, **kwargs)
            if command == ["generate"]:
                _ = (root / "pkgs/example/settings-schema.json").write_text(
                    json.dumps({"version": "2", "fields": {"new": "bool"}})
                )

        with (
            patch.object(
                maintain, "package_info", return_value=("2", ["x86_64-linux"])
            ),
            patch.object(maintain, "run", side_effect=update_contract),
            patch.object(maintain, "check") as check,
        ):
            with self.assertRaisesRegex(ValueError, "contract changed"):
                maintain.update(self.root, "example", "stable")
            check.assert_not_called()
            self.assertEqual(maintain.snapshot(self.root), before)
            maintain.update(self.root, "example", "2", accept_contract=True)
            check.assert_called_once()
        self.assertIn(
            "new",
            cast(
                dict[str, dict[str, object]],
                json.loads((self.package / "settings-schema.json").read_text()),
            )["fields"],
        )

    def test_publish_rejects_unlisted_and_concurrent_changes(self):
        before = maintain.snapshot(self.root)
        with self.assertRaisesRegex(ValueError, "undeclared"):
            maintain.publish(self.root, before, before | {"unexpected": b"x"}, set())
        _ = (self.package / "default.nix").write_text("concurrent change")
        with self.assertRaisesRegex(ValueError, "Working files changed"):
            maintain.publish(self.root, before, before, set())
        self.assertEqual(
            (self.package / "default.nix").read_text(), "concurrent change"
        )

    def test_manifest_rejects_path_escape(self):
        with self.assertRaises(ValueError):
            _ = maintain.specification(self.root, "../example")
        _ = (self.package / "maintenance.toml").write_text('files = ["../../outside"]')
        with self.assertRaises(ValueError):
            _ = maintain.specification(self.root, "example")

    def test_no_change_and_version_only_contract(self):
        before = maintain.snapshot(self.root)
        maintain.publish(self.root, before, before, set())
        self.assertFalse(
            maintain.contract_changed(
                b'{"version":"1","fields":{}}', b'{"version":"2","fields":{}}'
            )
        )
        self.assertEqual(maintain.snapshot(self.root), before)

    def test_raw_archive_hash_uses_host_prefetch(self):
        target = self.package / "default.nix"
        _ = target.write_text('hash = "old-arm"; other = "old-x86";')
        source = {
            "url": "https://example.invalid/archive",
            "outputHash": "old-arm",
            "outputHashMode": "flat",
        }
        with patch.object(
            maintain, "run", side_effect=[json.dumps(source), '{"hash":"new-arm"}']
        ) as commands:
            maintain.refresh_raw_source(
                self.root, "example", "aarch64-linux", "default.nix"
            )
        self.assertEqual(target.read_text(), 'hash = "new-arm"; other = "old-x86";')
        self.assertIn(
            'system = "aarch64-linux"',
            cast(list[str], commands.call_args_list[0].args[1])[-1],
        )
        self.assertEqual(
            cast(list[str], commands.call_args_list[1].args[1])[:3],
            ["nix", "store", "prefetch-file"],
        )

    def test_check_all_lints_once_after_package_checks(self):
        other = self.root / "pkgs/second"
        other.mkdir()
        _ = (other / "maintenance.toml").write_text("")
        with (
            patch.object(maintain, "ROOT", self.root),
            patch("sys.argv", ["maintain.py", "check-all"]),
            patch.object(maintain, "specification", return_value={"files": []}),
            patch.object(maintain, "check") as check,
            patch.object(maintain, "run", return_value=""),
            patch.object(maintain, "lint") as lint,
        ):
            maintain.main()
        self.assertEqual([call.args[1] for call in check.call_args_list], ["example", "second"])
        self.assertTrue(all(call.kwargs == {"run_lint": False} for call in check.call_args_list))
        lint.assert_called_once_with(self.root)

    def test_package_check_lints_by_default(self):
        with (
            patch.object(maintain, "package_info", return_value=("1", ["x86_64-linux"])),
            patch.object(maintain, "run", side_effect=['"x86_64-linux"', "/nix/store/example"]),
            patch.object(maintain, "lint") as lint,
        ):
            maintain.check(self.root, "example", {"files": []})
        lint.assert_called_once_with(self.root)

    def test_raw_archive_rejects_ambiguous_hash(self):
        target = self.package / "default.nix"
        _ = target.write_text('hash = "same"; other = "same";')
        source = {
            "url": "https://example.invalid/archive",
            "outputHash": "same",
            "outputHashMode": "flat",
        }
        with (
            patch.object(
                maintain,
                "run",
                side_effect=[json.dumps(source), '{"hash":"different"}'],
            ),
            self.assertRaisesRegex(ValueError, "uniquely"),
        ):
            maintain.refresh_raw_source(
                self.root, "example", "aarch64-linux", "default.nix"
            )
        self.assertEqual(target.read_text(), 'hash = "same"; other = "same";')


if __name__ == "__main__":
    _ = unittest.main()
