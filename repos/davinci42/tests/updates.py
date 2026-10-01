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
        _ = (folder / "maintenance.toml").write_text('files = ["default.nix"]')
        with (
            patch.object(check_updates, "candidates") as candidates,
            self.assertRaisesRegex(ValueError, "another"),
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
