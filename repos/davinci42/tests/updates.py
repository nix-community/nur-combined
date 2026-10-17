import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import cast
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import check_updates, maintain


class UpdateTests(unittest.TestCase):
    def test_detection_uses_package_script_without_hash_downloads(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with (
                patch.object(maintain, "copy_repository"),
                patch.object(
                    maintain,
                    "update_info",
                    side_effect=[
                        {"snapshot": True, "identity": "old"},
                        {"identity": "new"},
                    ],
                ) as info,
                patch.object(maintain, "execute_update") as execute,
                patch.object(maintain, "run", return_value="1") as run,
            ):
                self.assertEqual(check_updates.detect(root, "example"), ("old", "new"))
            self.assertEqual(info.call_count, 2)
            self.assertEqual(
                execute.call_args.kwargs["info"], {"snapshot": True, "identity": "old"}
            )
            self.assertTrue(execute.call_args.kwargs["detect"])
            self.assertNotEqual(execute.call_args.args[0], root)
            run.assert_not_called()

    def test_current_and_older_versions_are_skipped(self) -> None:
        for target in ("1.0.0", "0.9.0"):
            with (
                patch.object(maintain, "copy_repository"),
                patch.object(
                    maintain,
                    "update_info",
                    side_effect=[
                        {"snapshot": False, "identity": "1.0.0"},
                        {"identity": target},
                    ],
                ),
                patch.object(maintain, "execute_update"),
                patch.object(maintain, "run", return_value="-1"),
            ):
                self.assertIsNone(check_updates.detect(Path.cwd(), "example"))

    def test_readonly_never_updates_or_publishes(self) -> None:
        with (
            patch.object(maintain, "packages", return_value=["example"]),
            patch.object(check_updates, "detect", return_value=("1", "2")),
            patch.object(maintain, "update") as update,
            patch.object(check_updates, "open_pr") as publish,
        ):
            check_updates.check_updates(Path.cwd())
        update.assert_not_called()
        publish.assert_not_called()

    def test_update_mode_does_not_publish(self) -> None:
        with (
            patch.object(maintain, "packages", return_value=["example"]),
            patch.object(check_updates, "detect", return_value=("1", "2")),
            patch.object(maintain, "update_info", return_value={"snapshot": False}),
            patch.object(maintain, "update") as update,
            patch.object(check_updates, "open_pr") as publish,
        ):
            check_updates.check_updates(Path.cwd(), update=True)
        update.assert_called_once_with(Path.cwd(), "example", "2")
        publish.assert_not_called()

    def test_pr_requires_clean_checkout_and_force_requires_pr(self) -> None:
        with self.assertRaises(ValueError):
            check_updates.check_updates(Path.cwd(), force=True)
        with (
            patch.object(maintain, "run", return_value="dirty"),
            self.assertRaises(ValueError),
        ):
            check_updates.check_updates(Path.cwd(), pr=True)

    def test_failed_validation_never_pushes_and_removes_worktree(self) -> None:
        with (
            patch.dict(
                os.environ, {"GITHUB_REPOSITORY": "owner/repo", "UPDATE_BASE": "main"}
            ),
            patch.object(check_updates, "github", return_value=""),
            patch.object(maintain, "update_info", return_value={"snapshot": False}),
            patch.object(
                maintain,
                "update",
                side_effect=subprocess.CalledProcessError(1, "check"),
            ),
            patch.object(maintain, "run") as run,
            self.assertRaises(subprocess.CalledProcessError),
        ):
            _ = check_updates.open_pr(Path.cwd(), "example", "1", "2", False)
        self.assertEqual(run.call_count, 2)
        self.assertEqual(run.call_args.args[1][:3], ["git", "worktree", "remove"])

    def test_existing_pr_is_not_repeated(self) -> None:
        with (
            patch.dict(
                os.environ, {"GITHUB_REPOSITORY": "owner/repo", "UPDATE_BASE": "main"}
            ),
            patch.object(check_updates, "github", return_value="existing"),
            patch.object(maintain, "update") as update,
        ):
            self.assertEqual(
                check_updates.open_pr(Path.cwd(), "example", "1", "2", False),
                "existing PR: existing",
            )
        update.assert_not_called()

    def test_failure_does_not_skip_later_packages(self) -> None:
        with (
            patch.object(maintain, "packages", return_value=["first", "second"]),
            patch.object(
                check_updates, "detect", side_effect=[ValueError("network"), ("1", "2")]
            ) as detect,
            patch.object(check_updates, "report") as report,
            self.assertRaisesRegex(ValueError, "first"),
        ):
            check_updates.check_updates(Path.cwd())
        self.assertEqual(detect.call_count, 2)
        self.assertIn("second", cast(str, report.call_args.args[0]))

    def test_pr_uses_template_and_actual_source_refs(self) -> None:
        before: dict[str, object] = {
            "snapshot": False,
            "upstream": "https://github.com/DIYgod/RSSHub",
            "sourceRef": "v2026.10.10-8410.c3dfdf4",
            "system": "x86_64-linux",
        }
        after = before | {"sourceRef": "v2026.10.11-8411.a7d4000"}
        with (
            patch.dict(
                os.environ,
                {
                    "GITHUB_REPOSITORY": "DaVinci42/nur-packages",
                    "UPDATE_BASE": "main",
                    "GITHUB_SERVER_URL": "https://github.com",
                    "GITHUB_RUN_ID": "38107696052",
                },
                clear=True,
            ),
            patch.object(
                check_updates, "github", side_effect=["", "created"]
            ) as github,
            patch.object(maintain, "update_info", side_effect=[before, after]),
            patch.object(maintain, "update", return_value=True),
            patch.object(maintain, "version", return_value="2026.10.11-8411.a7d4000"),
            patch.object(maintain, "run"),
        ):
            self.assertEqual(
                check_updates.open_pr(
                    maintain.ROOT,
                    "rsshub",
                    "2026.10.10-8410.c3dfdf4",
                    "2026.10.11-8411.a7d4000",
                    False,
                ),
                "created",
            )
        arguments = cast(list[str], github.call_args.args[1])
        body = arguments[arguments.index("--body") + 1]
        self.assertIn(
            "/compare/v2026.10.10-8410.c3dfdf4...v2026.10.11-8411.a7d4000", body
        )
        self.assertIn("- [x] `just check rsshub` passed on `x86_64-linux`.", body)
        self.assertIn("/actions/runs/38107696052", body)
        self.assertNotIn("Not tested", body)
        self.assertNotIn("{", body)

    def test_snapshot_template_without_ci_and_repository_change(self) -> None:
        before: dict[str, object] = {
            "upstream": "https://github.com/example/project",
            "sourceRef": "a" * 40,
            "system": "aarch64-darwin",
        }
        after = before | {"sourceRef": "b" * 40}
        with patch.dict(os.environ, {}, clear=True):
            body = check_updates.pr_body(
                maintain.ROOT, "example", "a" * 40, "b" * 40, before, after
            )
        self.assertIn("/compare/" + "a" * 40 + "..." + "b" * 40, body)
        self.assertIn("aarch64-darwin", body)
        self.assertNotIn("CI logs", body)
        with self.assertRaisesRegex(ValueError, "repository changed"):
            _ = check_updates.pr_body(
                maintain.ROOT,
                "example",
                "1",
                "2",
                before,
                after | {"upstream": "different"},
            )

    def test_workflow_keeps_daily_and_manual_checks(self) -> None:
        workflow = (maintain.ROOT / ".github/workflows/updates.yml").read_text()
        self.assertIn("cron: '0 0 * * *'", workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn("just check-updates --pr", workflow)
        self.assertIn(
            "GITHUB_TOKEN: ${{ secrets.UPDATE_TOKEN || github.token }}", workflow
        )


if __name__ == "__main__":
    _ = unittest.main()
