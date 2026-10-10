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
                "0.51.01",
                "v01.2.3",
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

    def test_source_only_release_uses_the_validated_update_flow(self) -> None:
        _ = (self.root / "pkgs/example/maintenance.toml").write_text(
            'files = ["default.nix"]\n'
            + '[release]\nrepository = "owner/project"\nassets = []\n'
        )
        self.spec = maintain.specification(self.root, "example")
        self.release["assets"] = []
        assert "release" in self.spec
        self.assertTrue(check_updates.ready(self.release, self.spec["release"]))
        body = check_updates.pr_body(
            "example", self.release, self.spec, ["x86_64-linux"], "x86_64-linux"
        )
        self.assertIn("Source-only release", body)
        self.assertNotIn("assets are uploaded", body)
        with (
            patch.object(
                maintain, "package_info", return_value=("1.0.0", ["x86_64-linux"])
            ),
            patch.object(check_updates, "candidates", return_value=[self.release]),
            patch.object(maintain, "run", return_value="") as run,
            patch.object(check_updates, "open_pr") as publish,
        ):
            check_updates.check_updates(self.root, update=True)
        run.assert_called_once_with(self.root, ["just", "update", "example", "1.1.0"])
        publish.assert_not_called()

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
        for snapshot in (False, True):
            if snapshot:
                self.configure_snapshot()
            with (
                self.subTest(snapshot=snapshot),
                patch.object(maintain, "run", return_value="modified"),
                patch.object(check_updates, "github") as api,
                patch.object(check_updates, "ready_updates") as ready,
                self.assertRaisesRegex(ValueError, "clean checkout"),
            ):
                check_updates.check_updates(self.root, pr=True)
            api.assert_not_called()
            ready.assert_not_called()

    def test_existing_pr_skips_update_including_closed_pr(self) -> None:
        for snapshot in (False, True):
            if snapshot:
                self.configure_snapshot()
            with (
                self.subTest(snapshot=snapshot),
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
                    "a" * 40 if snapshot else "1.0.0",
                    self.release,
                    self.spec,
                    ["x86_64-linux"],
                )
            run.assert_not_called()
            self.assertIn("existing", result)
            self.assertIn("all", cast(list[str], api.call_args.args[1]))

    def test_validation_failure_never_commits_or_pushes(self) -> None:
        for snapshot in (False, True):
            if snapshot:
                self.configure_snapshot()
            for force in (False, True):
                results: list[object] = [""] * (2 if snapshot else 1)
                results.extend([ValueError("failed check"), ""])
                with (
                    self.subTest(snapshot=snapshot, force=force),
                    patch.object(
                        check_updates,
                        "github",
                        return_value='[{"url":"existing"}]' if force else "[]",
                    ) as api,
                    patch.object(
                        check_updates, "snapshot_date", return_value="2026-10-03"
                    ),
                    patch.object(
                        check_updates, "snapshot_revision", return_value="b" * 40
                    ),
                    patch.object(maintain, "run", side_effect=results) as run,
                    self.assertRaisesRegex(ValueError, "failed check"),
                ):
                    _ = check_updates.open_pr(
                        self.root,
                        "owner/nur",
                        "main",
                        "example",
                        "a" * 40 if snapshot else "1.0.0",
                        self.release,
                        self.spec,
                        ["x86_64-linux"],
                        force=force,
                    )
                commands = [
                    cast(list[str], call.args[1]) for call in run.call_args_list
                ]
                expected = (
                    [["just", "update-spotx"], ["just", "check", "example"]]
                    if snapshot
                    else [["just", "update", "example", "1.1.0"]]
                )
                self.assertEqual(commands[1:-1], expected)
                self.assertEqual(commands[-1][:3], ["git", "worktree", "remove"])
                self.assertFalse(
                    any(
                        "commit" in command or "push" in command for command in commands
                    )
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
        check.assert_called_once_with(maintain.ROOT, True, False, True)
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
        spec["tests"] = [["python3", "tests/pkgs/fluxdown/settings.py", "-v"]]
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
            "python3 tests/pkgs/fluxdown/settings.py -v",
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
            'files = ["default.nix", "spotx.nix"]\n'
            + '[snapshot]\nname = "SpotX"\nrepository = "SpotX-Official/SpotX-Bash"\nbranch = "main"\n'
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
            patch.object(
                check_updates, "snapshot_date", side_effect=["2026-09-28", "2026-10-03"]
            ),
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
        self.assertIn("2026-09-28 -> 2026-10-03", body)
        self.assertIn("a" * 40, body)
        self.assertIn("b" * 40, body)
        title = create[create.index("--title") + 1]
        self.assertEqual(title, "spotify-spotx: SpotX 2026-10-03 (bbbbbbb)")
        self.assertEqual(commands[7], ["git", "commit", "-m", title])

    def test_snapshot_dates_use_pinned_commits(self) -> None:
        with patch.object(
            check_updates, "github", return_value="2026-10-03T21:39:36Z"
        ) as api:
            self.assertEqual(
                check_updates.snapshot_date(self.root, "owner/project", "b" * 40),
                "2026-10-03",
            )
        self.assertIn(
            "repos/owner/project/commits/" + "b" * 40,
            cast(list[str], api.call_args.args[1]),
        )
        with (
            patch.object(check_updates, "github", return_value="invalid"),
            self.assertRaises(ValueError),
        ):
            _ = check_updates.snapshot_date(self.root, "owner/project", "b" * 40)

    def test_same_day_snapshot_titles_differ(self) -> None:
        self.configure_snapshot()
        titles: list[str] = []
        for revision in ("b" * 40, "c" * 40):
            release = self.release.copy()
            release["tag_name"] = revision
            with (
                patch.object(check_updates, "github", side_effect=["[]", "pr"]) as api,
                patch.object(check_updates, "snapshot_date", return_value="2026-10-03"),
                patch.object(check_updates, "update_package"),
                patch.object(
                    maintain,
                    "run",
                    side_effect=[
                        "",
                        "",
                        '"x86_64-linux"',
                        "pkgs/spotify-spotx/spotx.nix",
                        "",
                        "",
                        "",
                        "",
                    ],
                ),
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
            create = cast(list[str], api.call_args.args[1])
            titles.append(create[create.index("--title") + 1])
        self.assertEqual(
            titles,
            [
                "spotify-spotx: SpotX 2026-10-03 (bbbbbbb)",
                "spotify-spotx: SpotX 2026-10-03 (ccccccc)",
            ],
        )

    def test_every_run_checks_all_packages(self) -> None:
        self.configure_snapshot()
        folder = self.root / "pkgs/second"
        folder.mkdir()
        _ = (folder / "default.nix").write_text("")
        _ = (folder / "maintenance.toml").write_text(
            'files = ["default.nix"]\n'
            + '[release]\nrepository = "owner/project"\nassets = []\n'
        )
        with patch.object(check_updates, "ready_package", return_value=None) as ready:
            check_updates.check_updates(self.root)
            check_updates.check_updates(self.root)
        self.assertEqual(
            [call.args[1] for call in ready.call_args_list],
            ["example", "second", "example", "second"],
        )

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
                    if key == "assets" and invalid == []:
                        continue
                    with (
                        self.subTest(kind=kind, key=key, value=invalid),
                        self.assertRaises(ValueError),
                    ):
                        maintain.validate_monitor(kind, fields | {key: invalid})
                if key == "name":
                    maintain.validate_monitor(
                        kind,
                        {name: value for name, value in fields.items() if name != key},
                    )
                    continue
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

    def test_workflow_runs_daily_or_manually(self) -> None:
        workflow = (maintain.ROOT / ".github/workflows/updates.yml").read_text()
        self.assertEqual(workflow.count("cron:"), 1)
        self.assertIn("cron: '0 0 * * *'", workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn("just check-updates --pr", workflow)
        self.assertIn("just check-updates --pr --force", workflow)
        self.assertNotIn("--scheduled", workflow)
        self.assertNotIn("UPDATE_STATE_DIR", workflow)
        self.assertIn("just check-all && just check-updates --update", workflow)

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
