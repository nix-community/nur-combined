#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import urllib.error

SCRIPTS = Path(__file__).resolve().parents[2] / "scripts"
sys.path.insert(0, str(SCRIPTS))
import cache_metadata


def load_script(name):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


planner = load_script("ci-plan")
updater = load_script("update-package")
OUT = "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-example"
DEV = "/nix/store/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-example-dev"


class CachePlanTests(unittest.TestCase):
    def test_upstream_hit_still_needs_private_upload(self):
        result = planner.make_plan([{"attr": "example", "outputs": {"out": OUT}, "cacheStatus": "cached"}], lambda _: None)
        self.assertEqual(result["matrix"]["include"][0]["attr"], "example")

    def test_every_output_must_be_in_private_cache(self):
        row = {"attr": "example", "outputs": {"out": OUT, "dev": DEV}}
        result = planner.make_plan([row], lambda path: {} if path == OUT else None)
        self.assertFalse(result["matrix"]["include"][0]["skip"])
        self.assertEqual(set(result["paths"]), {OUT, DEV})

    def test_cache_hits_produce_valid_empty_matrix(self):
        result = planner.make_plan([{"attr": "example", "outputs": {"out": OUT}}], lambda _: {})
        self.assertEqual(result["cached"], ["example"])
        self.assertTrue(result["matrix"]["include"][0]["skip"])

    def test_one_evaluation_error_preserves_other_jobs(self):
        result = planner.make_plan([{"attr": "broken", "error": "IFD failed"}, {"attr": "working", "outputs": {"out": OUT}}])
        self.assertEqual(result["matrix"]["include"][0]["attr"], "working")
        self.assertEqual(result["errors"][0]["attr"], "broken")

    def test_unknown_output_is_an_error_not_a_cache_hit(self):
        result = planner.make_plan([{"attr": "dynamic", "outputs": {"out": None, "dev": DEV}}])
        self.assertEqual(result["errors"][0]["attr"], "dynamic")
        self.assertEqual(result["paths"], [])


class MetadataTests(unittest.TestCase):
    def setUp(self):
        self.local = {"narHash": "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", "narSize": 32, "references": [OUT, DEV]}
        self.remote = {"StorePath": OUT, "NarHash": "sha256:" + "00" * 32, "NarSize": "32", "References": f"{Path(DEV).name} {Path(OUT).name}"}

    def test_different_hash_formats_and_reference_order_are_accepted(self):
        cache_metadata.validate_metadata(OUT, self.local, self.remote)

    def test_missing_output_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Missing"):
            cache_metadata.validate_metadata(OUT, self.local, None)

    def test_changed_content_and_missing_dependency_are_rejected(self):
        for key, value in [("NarHash", "sha256:" + "ff" * 32), ("NarSize", "64"), ("References", Path(OUT).name)]:
            with self.subTest(key=key), self.assertRaisesRegex(ValueError, "differs"):
                cache_metadata.validate_metadata(OUT, self.local, {**self.remote, key: value})

    def test_authentication_failure_is_not_treated_as_a_miss(self):
        error = urllib.error.HTTPError("https://cache.invalid", 401, "Unauthorized", {}, None)
        with patch("urllib.request.urlopen", side_effect=error), self.assertRaises(urllib.error.HTTPError):
            cache_metadata.fetch_metadata(OUT, "test-only-token")

    def test_404_is_a_cache_miss(self):
        error = urllib.error.HTTPError("https://cache.invalid", 404, "Not Found", {}, None)
        with patch("urllib.request.urlopen", side_effect=error):
            self.assertIsNone(cache_metadata.fetch_metadata(OUT, "test-only-token"))


class UpdateTests(unittest.TestCase):
    def test_pinned_github_source_updates_revision_hash_and_version_together(self):
        with tempfile.TemporaryDirectory() as directory:
            recipe = Path(directory) / "default.nix"
            recipe.write_text('''{ }: let
  version = "2.4.1";
  src = fetchFromGitHub {
    owner = "example";
    repo = "input";
    rev = "old-commit";
    hash = "old-hash";
  };
in src
''')
            with patch.object(updater, "source_revision", return_value=("release-commit", {"tag_name": "v2.4.2"}, "2026-10-14")), patch.object(updater, "run", return_value='{"hash":"release-hash"}'), patch.object(updater, "Path", return_value=recipe):
                updater.update_github({"repo": "example/input", "attr": "input"})
            result = recipe.read_text()
            self.assertIn('version = "2.4.2";', result)
            self.assertIn('rev = "release-commit";', result)
            self.assertIn('hash = "release-hash";', result)

    def test_upstream_owner_changes_with_the_source_revision(self):
        with tempfile.TemporaryDirectory() as directory:
            recipe = Path(directory) / "default.nix"
            recipe.write_text('''let
  upstreamSrc = fetchFromGitHub {
    owner = "old-owner";
    repo = "old-repo";
    rev = "old-revision";
    hash = "old-hash";
  };
  version = "0-unstable-2026-10-13";
in upstreamSrc
''')
            with patch.object(updater, "source_revision", return_value=("new-revision", None, "2026-10-17")), patch.object(updater, "run", return_value='{"hash":"new-hash"}'), patch.object(updater, "Path", return_value=recipe):
                updater.update_vtype({"repo": "new-owner/new-repo"})
            result = recipe.read_text()
            self.assertIn('owner = "new-owner";', result)
            self.assertIn('repo = "new-repo";', result)
            self.assertIn('rev = "new-revision";', result)

    def test_new_unpinned_and_existing_pinned_inputs_can_both_update(self):
        for url in ["github:example/suite", "github:example/suite/old", "github:example/suite?ref=main&dir=nix"]:
            with self.subTest(url=url):
                updated = updater.pin_flake_url(f'url = "{url}";', "example/suite", "new")
                suffix = "?dir=nix" if "dir=" in url else ""
                self.assertEqual(updated, f'url = "github:example/suite/new{suffix}";')

    def test_new_package_is_discovered_without_a_central_list(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "flake.lock").write_text(json.dumps({"root": "root", "nodes": {"root": {"inputs": {}}}}))
            recipe = root / "pkgs/new-package/default.nix"
            recipe.parent.mkdir(parents=True)
            recipe.write_text("{ }: {}")
            ignored = root / "pkgs/tests"
            ignored.mkdir()
            targets = updater.discover_targets(root)
            self.assertEqual(targets, {"new-package": {"kind": "package", "attr": "new-package"}})

    def test_variants_share_one_update_job(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "flake.lock").write_text(json.dumps({"root": "root", "nodes": {"root": {"inputs": {}}}}))
            for name in ["plugin", "plugin-upstream"]:
                recipe = root / "pkgs" / name / "default.nix"
                recipe.parent.mkdir(parents=True)
                recipe.write_text("{ }: {}")
            (root / "pkgs/plugin-upstream/update.json").write_text('{"group":"plugin"}')
            self.assertEqual(list(updater.discover_targets(root)), ["plugin"])

    def test_new_flake_input_is_discovered_as_one_coupled_group(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lock = {"root": "root", "nodes": {"root": {"inputs": {"suite": "suite"}}, "suite": {"original": {"type": "github", "owner": "example", "repo": "suite"}}}}
            (root / "flake.lock").write_text(json.dumps(lock))
            self.assertEqual(updater.discover_targets(root)["suite"], {"kind": "flake", "input": "suite", "repo": "example/suite"})

    def test_standard_package_can_share_its_upstream_input_name(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lock = {"root": "root", "nodes": {"root": {"inputs": {"suite": "suite"}}, "suite": {"original": {"type": "github", "owner": "example", "repo": "suite"}}}}
            (root / "flake.lock").write_text(json.dumps(lock))
            for name in ["suite", "suite-helper"]:
                recipe = root / "pkgs" / name / "default.nix"
                recipe.parent.mkdir(parents=True)
                recipe.write_text("{ }: {}")
                recipe.with_name("update.json").write_text('{"group":"suite"}')
            self.assertEqual(list(updater.discover_targets(root)), ["suite"])

    def test_flake_update_synchronizes_standard_recipes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "flake.nix"
            path.write_text('inputs.suite.url = "github:example/suite/old";')
            with patch.object(updater, "source_revision", return_value=("new", None, "2026-10-20")), patch.object(updater, "run"), patch.object(updater, "Path", return_value=path), patch.object(updater.subprocess, "run") as sync:
                updater.update_flake({"input": "suite", "repo": "example/suite"})
            self.assertEqual(sync.call_args.args[0][1:], ["scripts/sync-project-inputs.py", "--if-supported", "suite"])

    def test_stable_npm_version_is_preferred(self):
        metadata = {"versions": {"1.2.0": {}, "1.10.0": {}, "2.0.0-beta.1": {}}, "dist-tags": {"latest": "2.0.0-beta.1"}}
        self.assertEqual(updater.npm_version(metadata), "1.10.0")

    def test_binary_channel_without_stable_release_uses_latest(self):
        metadata = {"versions": {"1.0.0-beta.17": {}}, "dist-tags": {"latest": "1.0.0-beta.17"}}
        self.assertEqual(updater.npm_version(metadata), "1.0.0-beta.17")

    def test_newer_npm_prerelease_is_not_downgraded_to_old_stable(self):
        metadata = {"versions": {"0.15.0": {}, "1.0.0-beta.18": {}}, "dist-tags": {"latest": "1.0.0-beta.18"}}
        self.assertEqual(updater.npm_version(metadata, "1.0.0-beta.17"), "1.0.0-beta.18")

    def test_npm_dist_tag_rollback_keeps_the_installed_version(self):
        metadata = {"versions": {"0.15.0": {}}, "dist-tags": {"latest": "1.0.0-beta.17"}}
        self.assertEqual(updater.npm_version(metadata, "1.0.0-beta.18"), "1.0.0-beta.18")

    def test_newer_stable_release_replaces_npm_prerelease(self):
        metadata = {"versions": {"1.0.0": {}}, "dist-tags": {"latest": "1.1.0-beta.1"}}
        self.assertEqual(updater.npm_version(metadata, "1.0.0-beta.18"), "1.0.0")

    def test_semver_prerelease_numbers_use_numeric_order(self):
        self.assertGreater(updater.semver_key("1.0.0-beta.10"), updater.semver_key("1.0.0-beta.9"))
        self.assertGreater(updater.semver_key("1.0.0"), updater.semver_key("1.0.0-beta.10"))

    def test_source_update_does_not_change_other_dependency_hashes(self):
        text = 'src = fetchurl { hash = "old"; }; npmDepsHash = "keep";'
        updated = updater.replace_once(text, r'(src = fetchurl \{ hash = ")[^"]+(";)', r'\g<1>new\2')
        self.assertEqual(updated, 'src = fetchurl { hash = "new"; }; npmDepsHash = "keep";')

    def test_changed_recipe_structure_requires_updater_attention(self):
        with self.assertRaises(ValueError):
            updater.replace_once("unexpected structure", r'rev = "[^"]+"', 'rev = "new"')


if __name__ == "__main__":
    unittest.main()
