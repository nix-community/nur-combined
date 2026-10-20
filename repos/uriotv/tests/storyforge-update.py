#!/usr/bin/env python3
"""Offline updater tests. Network, prefetch, tool generation and Nix are mocked."""
import importlib.util
import json
from pathlib import Path
import re
import shutil
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("storyforge_update", ROOT / "pkgs/storyforge/update.py")
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)
SRI = "sha256-" + "A" * 43 + "="
PIN = json.loads((ROOT / "pkgs/storyforge/bun2nix-pin.json").read_text())
OLD = {"version": "2.0.8", "rev": "a" * 40, "hash": SRI, "mode": "snapshot", "releaseTag": None}
NEW = {"version": "2.0.9", "rev": "b" * 40, "mode": "release", "releaseTag": "storyforge-v2.0.9"}


def release(tag, draft=False, prerelease=False):
    return {"tag_name": tag, "draft": draft, "prerelease": prerelease}


class SelectionTests(unittest.TestCase):
    def test_numeric_order_and_tag_filter(self):
        data = [release("storyforge-v2.9.0"), release("storyforge-v2.10.0"),
                release("storyforge-v99.0.0-rc1"), release("v99.0.0"),
                release("storyforge-v30.0.0", draft=True),
                release("storyforge-v40.0.0", prerelease=True)]
        with patch.object(updater, "github_json", return_value=data):
            self.assertEqual(updater.stable_releases(),
                             [((2, 10, 0), "storyforge-v2.10.0"), ((2, 9, 0), "storyforge-v2.9.0")])

    def test_paginated_releases(self):
        pages = [[release(f"storyforge-v{i}.0.0") for i in range(100)],
                 [release("storyforge-v110.0.0")]]
        with patch.object(updater, "github_json", side_effect=pages) as api:
            self.assertEqual(updater.stable_releases()[0], ((110, 0, 0), "storyforge-v110.0.0"))
            self.assertEqual(api.call_count, 2)

    def test_malformed_and_empty_release_data_fail(self):
        for data in ({}, [], [{"tag_name": "storyforge-v2.0.9"}]):
            with self.subTest(data=data), patch.object(updater, "github_json", return_value=data):
                with self.assertRaises(updater.UpdateError):
                    updater.stable_releases()

    def test_snapshot_does_not_downgrade_or_resolve_same_version(self):
        with patch.object(updater, "stable_releases", return_value=[((2, 0, 8), "storyforge-v2.0.8")]), \
             patch.object(updater, "resolve_tag") as resolve:
            self.assertIsNone(updater.select_candidate(OLD))
            resolve.assert_not_called()

    def test_new_candidate_requires_strict_descendant(self):
        with patch.object(updater, "stable_releases", return_value=[((2, 0, 9), NEW["releaseTag"])]), \
             patch.object(updater, "resolve_tag", return_value=NEW["rev"]), \
             patch.object(updater, "is_ancestor", return_value=False):
            with self.assertRaisesRegex(updater.UpdateError, "descendant"):
                updater.select_candidate(OLD)

    def test_release_retag_fails_even_if_there_is_no_new_version(self):
        meta = {**OLD, "mode": "release", "releaseTag": "storyforge-v2.0.8"}
        with patch.object(updater, "stable_releases", return_value=[]), \
             patch.object(updater, "resolve_tag", return_value=NEW["rev"]):
            with self.assertRaisesRegex(updater.UpdateError, "retagged"):
                updater.select_candidate(meta)

    def test_unknown_ancestry_and_invalid_sha_are_errors(self):
        with patch.object(updater, "github_json", return_value={"status": "unknown"}):
            with self.assertRaises(updater.UpdateError):
                updater.is_ancestor(OLD["rev"], NEW["rev"])
        with patch.object(updater, "github_json", return_value={"sha": "branch-name"}):
            with self.assertRaises(updater.UpdateError):
                updater.resolve_tag(NEW["releaseTag"])


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.package = self.root / "package"
        self.package.mkdir()
        self.source = self.root / "snapshot"
        (self.source / "src-tauri").mkdir(parents=True)
        (self.package / "source.json").write_text(json.dumps(OLD))
        (self.package / "bun2nix-pin.json").write_text(json.dumps(PIN))
        for name in ("Cargo.lock", "bun.nix", "compatibility.json", "default.nix"):
            (self.package / name).write_text("original " + name)
        self.source_files()
        self.patch_package = patch.object(updater, "PACKAGE", self.package)
        self.patch_package.start()
        self.addCleanup(self.patch_package.stop)
        self.calls = []
        self.failure = None

    def source_files(self, version="2.0.9", git=False):
        (self.source / "package.json").write_text(json.dumps({"version": version, "dependencies": {"better-auth": "^1.7.7"}}))
        (self.source / "src-tauri/Cargo.toml").write_text(f'[package]\nname="StoryForge"\nversion="{version}"\n')
        (self.source / "src-tauri/tauri.conf.json").write_text(json.dumps({"version": version}))
        deps = '\n[[package]]\nname="dep"\nversion="1"\nsource="git+https://example.org/repo"\n' if git else ''
        (self.source / "src-tauri/Cargo.lock").write_text(f'version=4\n[[package]]\nname="StoryForge"\nversion="{version}"\n{deps}')
        (self.source / "bun.lock").write_text(json.dumps({
            "lockfileVersion": 2, "configVersion": 1,
            "workspaces": {"": {"dependencies": {"better-auth": "^1.7.6"}}},
            "packages": {"dep": ["dep@1.0.0", "", {}, "sha512-test"]},
        }))

    def snapshot(self):
        return {p.name: p.read_bytes() for p in self.package.iterdir() if p.is_file()}

    def mock_run(self, command, **kwargs):
        self.calls.append(command)
        if command[1:3] == ["flake", "metadata"]:
            return json.dumps({"locked": {"narHash": PIN["hash"]}})
        if command[1] == "run":
            if self.failure == "generator":
                raise updater.UpdateError("generator failed")
            Path(command[-1]).write_text("{ ... }: { }")
            return ""
        expression = command[command.index("--expr") + 1]
        if "builtins.attrNames" in expression:
            return json.dumps([] if self.failure == "coverage" else ["dep@1.0.0"])
        if self.failure == "evaluation":
            raise updater.UpdateError("evaluation failed")
        stage_path = Path(json.loads(re.search(r"builtins.toPath (\"[^\"]+\")", expression).group(1)))
        # Critical regression: evaluate NEW source metadata, not the old pin.
        self.assertEqual(json.loads((stage_path / "source.json").read_text())["version"], NEW["version"])
        self.assertIn(str(updater.REPOSITORY), expression)
        return json.dumps({"version": NEW["version"], "drvPath": "/nix/store/" + "d" * 32 + "-storyforge.drv"})

    def run_update(self, check=False):
        with patch.object(updater, "select_candidate", return_value=NEW), \
             patch.object(updater, "prefetch", return_value=(self.source, SRI)), \
             patch.object(updater, "run", side_effect=self.mock_run):
            return updater.update(check=check)

    def test_complete_pipeline_updates_only_declared_files(self):
        original = self.snapshot()
        result = self.run_update()
        self.assertEqual(result["status"], "updated")
        after = self.snapshot()
        self.assertEqual(after["Cargo.lock"], (self.source / "src-tauri/Cargo.lock").read_bytes())
        self.assertEqual(json.loads(after["source.json"]), {**NEW, "hash": SRI})
        self.assertEqual(json.loads(after["compatibility.json"]), updater.compatibility.make_plan(self.source))
        for name in set(original) - set(updater.PUBLISH):
            self.assertEqual(original[name], after[name])
        generator = next(c for c in self.calls if c[1] == "run")
        self.assertEqual(generator[-3:-1], [str(self.source / "bun.lock"), "-o"])
        # Second run sees the accepted release and does not regenerate.
        with patch.object(updater, "select_candidate", return_value=None), \
             patch.object(updater, "run") as run:
            self.assertEqual(updater.update()["status"], "up-to-date")
            run.assert_not_called()
        self.assertEqual(after, self.snapshot())

    def test_check_mode_does_not_download_generate_or_write(self):
        before = self.snapshot()
        with patch.object(updater, "prefetch") as prefetch:
            result = self.run_update(check=True)
            self.assertEqual(result["status"], "update-available")
            prefetch.assert_not_called()
        self.assertEqual(before, self.snapshot())

    def test_noop_never_downloads_or_builds_generator(self):
        with patch.object(updater, "select_candidate", return_value=None), \
             patch.object(updater, "prefetch") as prefetch, patch.object(updater, "run") as run:
            self.assertEqual(updater.update()["status"], "up-to-date")
            prefetch.assert_not_called()
            run.assert_not_called()

    def test_tool_coverage_and_evaluation_failures_leave_original_directory(self):
        for failure in ("generator", "coverage", "evaluation"):
            with self.subTest(failure=failure):
                self.failure = failure
                before = self.snapshot()
                with self.assertRaises(updater.UpdateError):
                    self.run_update()
                self.assertEqual(before, self.snapshot())

    def test_invalid_versions_missing_files_git_and_unknown_compatibility_fail_before_tool(self):
        for failure in ("version", "missing", "git", "compatibility"):
            with self.subTest(failure=failure):
                self.source_files()
                if failure == "version":
                    (self.source / "package.json").write_text('{"version":"9.0.0"}')
                elif failure == "missing":
                    (self.source / "src-tauri/Cargo.lock").unlink()
                elif failure == "git":
                    self.source_files(git=True)
                else:
                    (self.source / "bun.lock").write_text('{"lockfileVersion":99}')
                before = self.snapshot()
                with self.assertRaises((updater.UpdateError, ValueError)):
                    self.run_update()
                self.assertFalse(self.calls)
                self.assertEqual(before, self.snapshot())

    def test_escaped_snapshot_symlink_is_not_read(self):
        target = self.source / "src-tauri/Cargo.lock"
        outside = self.root / "outside"
        shutil.move(target, outside)
        target.symlink_to(outside)
        with self.assertRaisesRegex(updater.UpdateError, "escapes"):
            updater.validate_source(self.source, NEW["version"])

    def test_publish_rolls_back_partial_replacement_including_modes(self):
        stage = self.root / "stage"
        stage.mkdir()
        for name in updater.PUBLISH:
            (stage / name).write_text("new")
        (self.package / "Cargo.lock").chmod(0o640)
        before = self.snapshot()
        atomic = updater._atomic_write
        calls = 0

        def fail_once(*args):
            nonlocal calls
            calls += 1
            if calls == 2:
                raise updater.UpdateError("injected replacement failure")
            return atomic(*args)

        with patch.object(updater, "_atomic_write", side_effect=fail_once):
            with self.assertRaises(updater.UpdateError):
                updater.publish(stage, {**NEW, "hash": SRI})
        self.assertEqual(before, self.snapshot())
        self.assertEqual((self.package / "Cargo.lock").stat().st_mode & 0o777, 0o640)
        self.assertFalse(list(self.package.glob(".*")))

    def test_signal_error_during_publication_also_rolls_back(self):
        stage = self.root / "signal-stage"
        stage.mkdir()
        for name in updater.PUBLISH:
            (stage / name).write_text("new")
        before = self.snapshot()
        original = updater._atomic_write
        calls = 0

        def interrupted(*args):
            nonlocal calls
            calls += 1
            if calls == 2:
                updater._interrupted(15, None)
            return original(*args)

        with patch.object(updater, "_atomic_write", side_effect=interrupted):
            with self.assertRaisesRegex(updater.UpdateError, "signal"):
                updater.publish(stage, {**NEW, "hash": SRI})
        self.assertEqual(before, self.snapshot())

    def test_verify_current_exercises_generation_without_writing_package(self):
        self.source_files(version=OLD["version"])
        (self.package / "Cargo.lock").write_bytes((self.source / "src-tauri/Cargo.lock").read_bytes())
        (self.package / "compatibility.json").write_text(json.dumps(updater.compatibility.make_plan(self.source)))
        (self.package / "bun.nix").write_text("{ ... }: { }")
        before = self.snapshot()
        with patch.object(updater, "prefetch", return_value=(self.source, SRI)), \
             patch.object(updater, "run", side_effect=self.mock_run), \
             patch.object(updater, "validate_evaluation") as evaluate:
            result = updater.verify_current()
            self.assertEqual(result["status"], "verified")
            evaluate.assert_called_once()
        self.assertEqual(before, self.snapshot())

    def test_verify_current_rejects_source_hash_change(self):
        with patch.object(updater, "prefetch", return_value=(self.source, "sha256-" + "B" * 43 + "=")):
            with self.assertRaisesRegex(updater.UpdateError, "hash changed"):
                updater.verify_current()

    def test_metadata_rejects_bad_hash_and_inconsistent_release_tag(self):
        for data in ({**OLD, "hash": "sha256-bad"},
                     {**OLD, "mode": "release", "releaseTag": "storyforge-v2.1.0"}):
            (self.package / "source.json").write_text(json.dumps(data))
            with self.assertRaises(updater.UpdateError):
                updater.load_metadata()

    def test_prefetch_accepts_actual_storepath_field_and_rejects_bad_sri(self):
        with patch.object(updater, "run", return_value=json.dumps({"storePath": "/nix/store/test", "hash": SRI})), \
             patch.object(Path, "is_dir", return_value=True):
            self.assertEqual(updater.prefetch(NEW["rev"]), (Path("/nix/store/test"), SRI))
        with patch.object(updater, "run", return_value=json.dumps({"storePath": "/nix/store/test", "hash": "invalid"})):
            with self.assertRaises(updater.UpdateError):
                updater.prefetch(NEW["rev"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
