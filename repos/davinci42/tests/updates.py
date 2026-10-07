import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import cast, override
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import check_updates, maintain


class UpdateTests(unittest.TestCase):
    root: Path = Path()
    release: check_updates.Release
    spec: maintain.Specification

    def __init__(self, methodName: str = "runTest") -> None:
        super().__init__(methodName)
        self.release = {
            "tag_name": "",
            "draft": False,
            "prerelease": False,
            "html_url": "",
            "assets": [],
        }
        self.spec = {"files": []}

    @override
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        folder = self.root / "pkgs/example"
        folder.mkdir(parents=True)
        _ = (folder / "default.nix").write_text('version = "1.0.0";')
        _ = (folder / "maintenance.toml").write_text(
            'files = ["default.nix"]\n'
            + '[release]\nrepository = "owner/project"\n'
            + 'assets = ["app-{version}-x64.tar.gz", "app-{version}-arm64.tar.gz", "SHA256SUMS-server.txt"]\n'
        )
        self.spec = maintain.specification(self.root, "example")
        self.release = {
            "tag_name": "v1.1.0",
            "draft": False,
            "prerelease": False,
            "html_url": "upstream-release",
            "assets": [
                {"name": name, "state": "uploaded", "size": 4}
                for name in [
                    "app-1.1.0-x64.tar.gz",
                    "app-1.1.0-arm64.tar.gz",
                    "SHA256SUMS-server.txt",
                ]
            ],
        }

    def test_candidates_use_numeric_order_and_skip_nonstable_releases(self) -> None:
        releases = [
            self.release | {"tag_name": tag}
            for tag in [
                "v1.2.0",
                "v1.10.0",
                "v1.0.0",
                "v0.9.0",
                "v2.0.0-rc.1",
                "server-v3.0.0",
            ]
        ]
        releases.extend(
            [self.release | {"draft": True}, self.release | {"prerelease": True}]
        )
        with patch.object(check_updates, "github", return_value=json.dumps([releases])):
            result = check_updates.candidates(self.root, "owner/project", "1.0.0")
        self.assertEqual(
            [release["tag_name"] for release in result], ["v1.10.0", "v1.2.0"]
        )
        with self.assertRaises(ValueError):
            _ = check_updates.version_key("1.0.0;false")

    def test_readiness_requires_every_asset_uploaded_and_nonempty(self) -> None:
        assert "release" in self.spec
        self.assertTrue(check_updates.ready(self.release, self.spec["release"]))
        for index in range(3):
            release = self.release.copy()
            release["assets"] = (
                self.release["assets"][:index] + self.release["assets"][index + 1 :]
            )
            self.assertFalse(check_updates.ready(release, self.spec["release"]))
        self.release["assets"][0]["state"] = "new"
        self.assertFalse(check_updates.ready(self.release, self.spec["release"]))
        self.release["assets"][0]["state"] = "uploaded"
        self.release["assets"][0]["size"] = 0
        self.assertFalse(check_updates.ready(self.release, self.spec["release"]))

    def test_read_only_and_update_modes_never_publish(self) -> None:
        with (
            patch.object(
                maintain, "package_info", return_value=("1.0.0", ["x86_64-linux"])
            ),
            patch.object(check_updates, "candidates", return_value=[self.release]),
            patch.object(check_updates, "open_pr") as publish,
            patch.object(maintain, "run", return_value="") as run,
        ):
            check_updates.check_updates(self.root)
            run.assert_not_called()
            check_updates.check_updates(self.root, update=True)
            run.assert_called_once_with(
                self.root, ["just", "update", "example", "1.1.0"]
            )
            publish.assert_not_called()

    def test_current_or_incomplete_release_skips_work(self) -> None:
        with (
            patch.object(
                maintain, "package_info", return_value=("1.0.0", ["x86_64-linux"])
            ),
            patch.object(check_updates, "candidates", return_value=[]) as candidates,
            patch.object(maintain, "run") as run,
        ):
            check_updates.check_updates(self.root, update=True)
            self.release["assets"] = []
            candidates.return_value = [self.release]
            check_updates.check_updates(self.root, update=True)
            run.assert_not_called()

    def test_errors_stop_before_later_packages(self) -> None:
        folder = self.root / "pkgs/another"
        folder.mkdir()
        _ = (folder / "default.nix").write_text("")
        _ = (folder / "maintenance.toml").write_text('files = ["missing.nix"]')
        with (
            patch.object(check_updates, "candidates") as candidates,
            self.assertRaisesRegex(ValueError, "regular files"),
        ):
            check_updates.check_updates(self.root, update=True)
        candidates.assert_not_called()

    def test_pr_requires_clean_checkout_before_network(self) -> None:
        with (
            patch.object(maintain, "run", return_value="modified"),
            patch.object(check_updates, "github") as api,
            self.assertRaisesRegex(ValueError, "clean checkout"),
        ):
            check_updates.check_updates(self.root, pr=True)
        api.assert_not_called()

    def test_existing_pr_skips_update_including_closed_pr(self) -> None:
        with (
            patch.object(
                check_updates, "github", return_value='[{"url":"existing"}]'
            ) as api,
            patch.object(maintain, "run") as run,
        ):
            result = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "example",
                "1.0.0",
                self.release,
                self.spec,
                ["x86_64-linux"],
            )
        run.assert_not_called()
        self.assertIn("existing", result)
        self.assertIn("all", cast(list[str], api.call_args.args[1]))

    def test_validation_failure_never_commits_or_pushes(self) -> None:
        with (
            patch.object(check_updates, "github", return_value="[]") as api,
            patch.object(
                maintain, "run", side_effect=["", ValueError("contract changed"), ""]
            ) as run,
            self.assertRaisesRegex(ValueError, "contract changed"),
        ):
            _ = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "example",
                "1.0.0",
                self.release,
                self.spec,
                ["x86_64-linux"],
            )
        commands = [cast(list[str], call.args[1]) for call in run.call_args_list]
        self.assertEqual(commands[1], ["just", "update", "example", "1.1.0"])
        self.assertEqual(commands[-1][:3], ["git", "worktree", "remove"])
        self.assertFalse(
            any("commit" in command or "push" in command for command in commands)
        )
        api.assert_called_once()

    def test_pr_isolated_branch_title_body_and_command_order(self) -> None:
        with (
            patch.object(check_updates, "github", side_effect=["[]", "new-pr"]) as api,
            patch.object(
                maintain,
                "run",
                side_effect=["", "", "", '"x86_64-linux"', "", "", "", ""],
            ) as run,
        ):
            result = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "example",
                "1.0.0",
                self.release,
                self.spec,
                ["aarch64-linux", "x86_64-linux"],
            )
        self.assertEqual(result, "new-pr")
        commands = [cast(list[str], call.args[1]) for call in run.call_args_list]
        self.assertEqual(commands[0][-1], "HEAD")
        self.assertEqual(commands[1], ["just", "update", "example", "1.1.0"])
        self.assertEqual(commands[4], ["git", "add", "--", "pkgs/example/default.nix"])
        self.assertEqual(
            commands[5], ["git", "commit", "-m", "example: 1.0.0 -> 1.1.0"]
        )
        self.assertEqual(
            commands[6][-1], "HEAD:refs/heads/updates/example-1.0.0-to-1.1.0"
        )
        create = cast(list[str], api.call_args.args[1])
        self.assertEqual(create[create.index("--title") + 1], "example: 1.0.0 -> 1.1.0")
        body = create[create.index("--body") + 1]
        self.assertIn("built on `x86_64-linux`", body)
        self.assertIn("not build-tested: aarch64-linux", body)
        self.assertNotIn("Pinned contract verified", body)

    def test_force_uses_fresh_branches_and_keeps_validation(self) -> None:
        with (
            patch.object(
                check_updates,
                "github",
                side_effect=['[{"url":"existing"}]', "new-pr"] * 2,
            ) as api,
            patch.object(
                maintain,
                "run",
                side_effect=["", "", "", '"x86_64-linux"', "", "", "", ""] * 2,
            ) as run,
        ):
            for _ in range(2):
                self.assertEqual(
                    check_updates.open_pr(
                        self.root,
                        "owner/nur",
                        "main",
                        "example",
                        "1.0.0",
                        self.release,
                        self.spec,
                        ["x86_64-linux"],
                        force=True,
                    ),
                    "new-pr",
                )
        branches: list[str] = []
        for index in range(2):
            commands = [
                cast(list[str], call.args[1])
                for call in run.call_args_list[index * 8 : (index + 1) * 8]
            ]
            self.assertEqual(commands[1], ["just", "update", "example", "1.1.0"])
            self.assertEqual(commands[2], ["git", "diff", "--check"])
            create = cast(list[str], api.call_args_list[index * 2 + 1].args[1])
            branch = create[create.index("--head") + 1]
            self.assertRegex(
                branch, r"^updates/example-1\.0\.0-to-1\.1\.0-force-[0-9a-f]{32}$"
            )
            self.assertEqual(
                commands[6],
                ["git", "push", "-u", "origin", f"HEAD:refs/heads/{branch}"],
            )
            branches.append(branch)
        self.assertNotEqual(*branches)

    def test_force_does_not_bypass_validation_failure(self) -> None:
        with (
            patch.object(
                check_updates, "github", return_value='[{"url":"existing"}]'
            ) as api,
            patch.object(
                maintain, "run", side_effect=["", ValueError("contract changed"), ""]
            ) as run,
            self.assertRaisesRegex(ValueError, "contract changed"),
        ):
            _ = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "example",
                "1.0.0",
                self.release,
                self.spec,
                ["x86_64-linux"],
                force=True,
            )
        commands = [cast(list[str], call.args[1]) for call in run.call_args_list]
        self.assertEqual(commands[1], ["just", "update", "example", "1.1.0"])
        self.assertEqual(commands[-1][:3], ["git", "worktree", "remove"])
        self.assertFalse(
            any("commit" in command or "push" in command for command in commands)
        )
        api.assert_called_once()

    def test_force_requires_pr_before_any_work(self) -> None:
        for update in [False, True]:
            with (
                self.subTest(update=update),
                patch.object(check_updates, "ready_updates") as ready,
                patch.object(maintain, "run") as run,
                self.assertRaisesRegex(ValueError, "--force requires --pr"),
            ):
                check_updates.check_updates(self.root, update=update, force=True)
            ready.assert_not_called()
            run.assert_not_called()

    def test_force_keeps_release_and_clean_checkout_gates(self) -> None:
        with (
            patch.dict(
                os.environ, {"GITHUB_REPOSITORY": "owner/nur", "UPDATE_BASE": "main"}
            ),
            patch.object(maintain, "run", return_value="") as run,
            patch.object(
                maintain, "package_info", return_value=("1.0.0", ["x86_64-linux"])
            ),
            patch.object(check_updates, "candidates", return_value=[]) as candidates,
            patch.object(check_updates, "open_pr") as publish,
        ):
            check_updates.check_updates(self.root, pr=True, force=True)
            self.release["assets"] = []
            candidates.return_value = [self.release]
            check_updates.check_updates(self.root, pr=True, force=True)
            publish.assert_not_called()
            run.return_value = "modified"
            with self.assertRaisesRegex(ValueError, "clean checkout"):
                check_updates.check_updates(self.root, pr=True, force=True)
            publish.assert_not_called()

    def test_force_cli_and_publishing_wiring(self) -> None:
        with (
            patch.object(sys, "argv", ["check_updates.py", "--pr", "--force"]),
            patch.object(check_updates, "check_updates") as check,
        ):
            check_updates.main()
        check.assert_called_once_with(maintain.ROOT, True, False, True, False)
        with (
            patch.dict(
                os.environ, {"GITHUB_REPOSITORY": "owner/nur", "UPDATE_BASE": "main"}
            ),
            patch.object(maintain, "run", return_value=""),
            patch.object(
                check_updates,
                "ready_updates",
                return_value=[
                    ("example", self.spec, "1.0.0", ["x86_64-linux"], self.release)
                ],
            ),
            patch.object(check_updates, "open_pr", return_value="new-pr") as publish,
        ):
            check_updates.check_updates(self.root, pr=True, force=True)
        publish.assert_called_once_with(
            self.root,
            "owner/nur",
            "main",
            "example",
            "1.0.0",
            self.release,
            self.spec,
            ["x86_64-linux"],
            force=True,
        )

    def test_body_reports_only_declared_checks(self) -> None:
        spec = self.spec.copy()
        spec["sync"] = ["generate"]
        spec["contract"] = ["verify"]
        spec["tests"] = [["python3", "tests/settings.py", "-v"]]
        body = check_updates.pr_body(
            "example", self.release, spec, ["x86_64-linux"], "x86_64-linux"
        )
        checks = [line for line in body.splitlines() if line.startswith("- ")]
        self.assertEqual(len(checks), 8)
        self.assertTrue(all(line.startswith("- [x] ") for line in checks))
        self.assertFalse(any("not run" in line for line in checks))
        for text in [
            "generate",
            "verify",
            "python3 tests/settings.py -v",
            "VM tests were not run",
            "zero errors and warnings",
        ]:
            self.assertIn(text, body)

    def test_multiple_prs_share_base_not_each_others_changes(self) -> None:
        folder = self.root / "pkgs/second"
        folder.mkdir()
        _ = (folder / "default.nix").write_text("")
        _ = (folder / "maintenance.toml").write_text(
            (self.root / "pkgs/example/maintenance.toml").read_text()
        )
        with (
            patch.dict(
                os.environ, {"GITHUB_REPOSITORY": "owner/nur", "UPDATE_BASE": "main"}
            ),
            patch.object(maintain, "run", return_value=""),
            patch.object(
                maintain, "package_info", return_value=("1.0.0", ["x86_64-linux"])
            ),
            patch.object(check_updates, "candidates", return_value=[self.release]),
            patch.object(check_updates, "open_pr", return_value="pr") as publish,
        ):
            check_updates.check_updates(self.root, pr=True)
        self.assertEqual(
            [call.args[3] for call in publish.call_args_list], ["example", "second"]
        )
        self.assertTrue(
            all(
                call.args[0] == self.root and call.args[2] == "main"
                for call in publish.call_args_list
            )
        )

    def test_nonrelease_packages_are_skipped(self) -> None:
        _ = (self.root / "pkgs/example/maintenance.toml").write_text(
            'files = ["default.nix"]'
        )
        with patch.object(maintain, "package_info") as info:
            self.assertEqual(list(check_updates.ready_updates(self.root)), [])
        info.assert_not_called()

    def configure_snapshot(self) -> None:
        folder = self.root / "pkgs/example"
        _ = (folder / "spotx.nix").write_text("")
        _ = (folder / "maintenance.toml").write_text(
            'files = ["default.nix", "spotx.nix"]\ncheckIntervalHours = 168\n'
            + '[snapshot]\nrepository = "SpotX-Official/SpotX-Bash"\nbranch = "main"\n'
            + 'attribute = "spotify-spotx.spotx"\ncommand = ["just", "update-spotx"]\n'
            + 'files = ["spotx.nix"]\n'
        )
        self.spec = maintain.specification(self.root, "example")
        info = patch.object(
            maintain, "package_info", return_value=("1.0.0", ["x86_64-linux"])
        )
        _ = info.start()
        self.addCleanup(info.stop)
        self.release["tag_name"] = "b" * 40

    def test_spotx_readonly_and_current_never_update(self) -> None:
        self.configure_snapshot()
        with (
            patch.object(check_updates, "snapshot_revision", return_value="a" * 40),
            patch.object(check_updates, "github", return_value="b" * 40) as api,
            patch.object(maintain, "run") as run,
        ):
            check_updates.check_updates(self.root)
            api.return_value = "a" * 40
            check_updates.check_updates(self.root, update=True)
        run.assert_not_called()

    def test_spotx_update_checks_without_publishing(self) -> None:
        self.configure_snapshot()
        with (
            patch.object(
                check_updates, "snapshot_revision", side_effect=["a" * 40, "b" * 40]
            ),
            patch.object(check_updates, "github", return_value="b" * 40),
            patch.object(maintain, "run", return_value="") as run,
            patch.object(check_updates, "open_pr") as publish,
        ):
            check_updates.check_updates(self.root, update=True)
        self.assertEqual(
            [call.args[1] for call in run.call_args_list],
            [["just", "update-spotx"], ["just", "check", "example"]],
        )
        publish.assert_not_called()

    def test_spotx_rejects_invalid_and_moving_revision(self) -> None:
        self.configure_snapshot()
        with (
            patch.object(check_updates, "snapshot_revision", return_value="a" * 40),
            patch.object(check_updates, "github", return_value="invalid"),
            patch.object(maintain, "run") as run,
            self.assertRaisesRegex(ValueError, "Invalid upstream"),
        ):
            check_updates.check_updates(self.root, update=True)
        run.assert_not_called()
        with (
            patch.object(
                check_updates, "snapshot_revision", side_effect=["a" * 40, "c" * 40]
            ),
            patch.object(check_updates, "github", return_value="b" * 40),
            patch.object(maintain, "run", return_value="") as run,
            self.assertRaisesRegex(ValueError, "moved"),
        ):
            check_updates.check_updates(self.root, update=True)
        run.assert_called_once_with(self.root, ["just", "update-spotx"])

    def test_spotx_pr_validates_before_publishing(self) -> None:
        self.configure_snapshot()
        release = self.release
        with (
            patch.object(check_updates, "github", side_effect=["[]", "pr"]) as api,
            patch.object(check_updates, "snapshot_revision", return_value="b" * 40),
            patch.object(
                maintain,
                "run",
                side_effect=[
                    "",
                    "",
                    "",
                    "",
                    '"x86_64-linux"',
                    "pkgs/spotify-spotx/spotx.nix",
                    "",
                    "",
                    "",
                    "",
                ],
            ) as run,
        ):
            _ = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "spotify-spotx",
                "a" * 40,
                release,
                self.spec,
                ["x86_64-linux"],
            )
        commands = [call.args[1] for call in run.call_args_list]
        self.assertEqual(
            commands[1:3],
            [["just", "update-spotx"], ["just", "check", "spotify-spotx"]],
        )
        self.assertEqual(
            commands[6], ["git", "add", "--", "pkgs/spotify-spotx/spotx.nix"]
        )
        create = cast(list[str], api.call_args.args[1])
        body = create[create.index("--body") + 1]
        self.assertIn("Playback, ad blocking, and VM tests were not run", body)
        self.assertNotIn("assets", body)

    def test_spotx_failed_validation_never_publishes(self) -> None:
        self.configure_snapshot()
        with (
            patch.object(check_updates, "github", return_value="[]") as api,
            patch.object(check_updates, "snapshot_revision", return_value="b" * 40),
            patch.object(
                maintain, "run", side_effect=["", "", ValueError("failed check"), ""]
            ) as run,
            self.assertRaisesRegex(ValueError, "failed check"),
        ):
            _ = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "spotify-spotx",
                "a" * 40,
                self.release,
                self.spec,
                ["x86_64-linux"],
            )
        self.assertFalse(
            any(
                "push" in call.args[1] or "commit" in call.args[1]
                for call in run.call_args_list
            )
        )
        api.assert_called_once()

    def test_spotx_existing_pr_and_dirty_checkout(self) -> None:
        self.configure_snapshot()
        with (
            patch.object(check_updates, "github", return_value='[{"url":"existing"}]'),
            patch.object(maintain, "run") as run,
        ):
            result = check_updates.open_pr(
                self.root,
                "owner/nur",
                "main",
                "spotify-spotx",
                "a" * 40,
                self.release,
                self.spec,
                ["x86_64-linux"],
            )
        self.assertIn("existing", result)
        run.assert_not_called()
        with (
            patch.object(maintain, "run", return_value="modified"),
            patch.object(check_updates, "ready_updates") as check,
            self.assertRaisesRegex(ValueError, "clean checkout"),
        ):
            check_updates.check_updates(self.root, pr=True)
        check.assert_not_called()

    def test_spotx_cli(self) -> None:
        with (
            patch.object(sys, "argv", ["check_updates.py", "--scheduled", "--pr"]),
            patch.object(check_updates, "check_updates") as check,
        ):
            check_updates.main()
        check.assert_called_once_with(maintain.ROOT, True, False, False, True)

    def test_scheduled_interval_and_manual_bypass(self) -> None:
        self.configure_snapshot()
        state = self.root / "state"
        stamp = state / "example"
        with (
            patch.dict(os.environ, {"UPDATE_STATE_DIR": str(state)}),
            patch("tools.check_updates.time.time", return_value=1000000) as clock,
            patch.object(check_updates, "ready_package", return_value=None) as ready,
        ):
            check_updates.check_updates(self.root, scheduled=True)
            self.assertEqual(stamp.read_text(), "1000000")
            clock.return_value = 1000000 + 168 * 3600 - 1
            check_updates.check_updates(self.root, scheduled=True)
            ready.assert_called_once()
            check_updates.check_updates(self.root)
            self.assertEqual(ready.call_count, 2)
            self.assertEqual(stamp.read_text(), "1000000")
            clock.return_value = 1000000 + 168 * 3600
            check_updates.check_updates(self.root, scheduled=True)
            self.assertEqual(ready.call_count, 3)

    def test_failed_scheduled_check_is_retried(self) -> None:
        state = self.root / "state"
        with (
            patch.dict(os.environ, {"UPDATE_STATE_DIR": str(state)}),
            patch.object(
                check_updates, "ready_package", side_effect=ValueError("network")
            ),
            self.assertRaisesRegex(ValueError, "network"),
        ):
            check_updates.check_updates(self.root, scheduled=True)
        self.assertFalse((state / "example").exists())
        with (
            patch.dict(os.environ, {"UPDATE_STATE_DIR": str(state)}),
            patch.object(
                check_updates,
                "ready_package",
                return_value=("1.0.0", ["x86_64-linux"], self.release),
            ),
            patch.object(maintain, "run", side_effect=ValueError("validation")),
            self.assertRaisesRegex(ValueError, "validation"),
        ):
            check_updates.check_updates(self.root, update=True, scheduled=True)
        self.assertFalse((state / "example").exists())

    def test_interval_does_not_skip_other_due_packages(self) -> None:
        self.configure_snapshot()
        folder = self.root / "pkgs/frequent"
        folder.mkdir()
        _ = (folder / "default.nix").write_text("")
        _ = (folder / "maintenance.toml").write_text(
            'files = ["default.nix"]\ncheckIntervalHours = 4\n'
            + '[release]\nrepository = "owner/project"\nassets = ["app"]\n'
        )
        state = self.root / "state"
        state.mkdir()
        for package in ("example", "frequent"):
            _ = (state / package).write_text("1000000")
        with (
            patch.dict(os.environ, {"UPDATE_STATE_DIR": str(state)}),
            patch("tools.check_updates.time.time", return_value=1000000 + 4 * 3600),
            patch.object(check_updates, "ready_package", return_value=None) as ready,
        ):
            check_updates.check_updates(self.root, scheduled=True)
        self.assertEqual([call.args[1] for call in ready.call_args_list], ["frequent"])

    def test_monitor_fields_are_required_and_validated(self) -> None:
        self.configure_snapshot()
        assert "snapshot" in self.spec
        monitors: dict[str, dict[str, object]] = {
            "release": {"repository": "owner/project", "assets": ["app"]},
            "snapshot": dict(self.spec["snapshot"]),
        }
        invalid_values: list[object] = [None, "", [], 1]
        for kind, fields in monitors.items():
            maintain.validate_monitor(kind, fields)
            for key in fields:
                for invalid in invalid_values:
                    with (
                        self.subTest(kind=kind, key=key, value=invalid),
                        self.assertRaises(ValueError),
                    ):
                        maintain.validate_monitor(kind, fields | {key: invalid})
                with (
                    self.subTest(kind=kind, missing=key),
                    self.assertRaises(ValueError),
                ):
                    maintain.validate_monitor(
                        kind,
                        {name: value for name, value in fields.items() if name != key},
                    )
            with self.subTest(kind=kind, unknown=True), self.assertRaises(ValueError):
                maintain.validate_monitor(kind, fields | {"unknown": "value"})

    def test_monitor_metadata_validation(self) -> None:
        manifest = self.root / "pkgs/example/maintenance.toml"
        for value in ("0", "-1", "true", '"weekly"', "1.5"):
            with self.subTest(value=value):
                _ = manifest.write_text(
                    'files = ["default.nix"]\ncheckIntervalHours = ' + value
                )
                with self.assertRaisesRegex(ValueError, "checkIntervalHours"):
                    _ = maintain.specification(self.root, "example")
        self.configure_snapshot()
        content = manifest.read_text()
        for old, new in (
            ('branch = "main"', 'branch = "main?invalid"'),
            ('attribute = "spotify-spotx.spotx"', 'attribute = "bad/path"'),
            ('command = ["just", "update-spotx"]', "command = []"),
            ('files = ["spotx.nix"]', 'files = ["undeclared.nix"]'),
        ):
            _ = manifest.write_text(content.replace(old, new))
            with self.subTest(new=new), self.assertRaises(ValueError):
                _ = maintain.specification(self.root, "example")

    def test_workflow_uses_metadata_schedule(self) -> None:
        workflow = (maintain.ROOT / ".github/workflows/updates.yml").read_text()
        self.assertEqual(workflow.count("cron:"), 1)
        self.assertIn("just check-updates --pr --scheduled", workflow)
        self.assertIn(
            'UPDATE_STATE_DIR="$HOME/.local/state/nur-updates/$GITHUB_REPOSITORY"',
            workflow,
        )
        self.assertNotIn("--spotx", workflow)
        self.assertNotIn("17 3 * * 1", workflow)
        self.assertIn("just check-updates --update", workflow)

    def test_github_errors_propagate(self) -> None:
        with (
            patch.object(
                subprocess, "run", side_effect=subprocess.CalledProcessError(1, ["gh"])
            ),
            self.assertRaises(subprocess.CalledProcessError),
        ):
            _ = check_updates.github(self.root, ["api", "repos/owner/project/releases"])


if __name__ == "__main__":
    _ = unittest.main()
