#!/usr/bin/env python3
"""Offline tests for independent CachyOS metadata discovery and transactions."""
import base64
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("cachyos_updater", ROOT / "scripts/update-cachyos.py")
UPDATER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(UPDATER)
H1 = "sha256-" + base64.b64encode(b"a" * 32).decode()
H2 = "sha256-" + base64.b64encode(b"b" * 32).decode()
KERNEL_REV = "f" * 40
PATCH_REV = "e" * 40
CURRENT = {"version": "7.2.11", "url": "https://github.com/CachyOS/linux/releases/download/cachyos-7.2.11-1/cachyos-7.2.11-1.tar.gz", "hash": H1,
           "configUrl": f"{UPDATER.KERNEL_RAW}/{'a' * 40}/linux-cachyos/config", "configHash": H1,
           "patchRev": "6" * 40, "patchVersion": "7.2", "patchHash": H1}
# Captured from the current CachyOS PKGBUILD syntax (not executed by updater).
REALISTIC_PKGBUILD = '''pkgbase="linux-cachyos"
_major=7.3
_minor=0
_tagrel=2
pkgver=${_major}.${_minor}
_srcname=cachyos-${_major}.${_minor}-${_tagrel}
'''


class UpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.pkg = Path(self.temp.name) / "linux-cachyos-latest-x86_64-v3"
        self.pkg.mkdir()
        self.source = self.pkg / "source.json"
        self.source.write_text(json.dumps(CURRENT))
        self.other = Path(self.temp.name) / "linux-cachyos-bore-x86_64-v3" / "source.json"
        self.other.parent.mkdir()
        self.other.write_text(json.dumps({**CURRENT, "version": "7.2.10"}))

    def test_numeric_versions_are_strict_and_ignore_trailing_zeroes(self):
        self.assertGreater(UPDATER.version_key("7.10.1"), UPDATER.version_key("7.9.99"))
        self.assertEqual(UPDATER.version_key("7.2.0"), UPDATER.version_key("7.2"))
        self.assertEqual(UPDATER.version_key("7.2.11"), UPDATER.version_key("7.2.11"))
        self.assertLess(UPDATER.version_key("7.2.9"), UPDATER.version_key("7.2.11"))

    def test_safe_pkgbuild_parser_supports_real_literal_substitution(self):
        self.assertEqual(UPDATER.parse_pkgbuild(REALISTIC_PKGBUILD), ("7.3.0", "cachyos-7.3.0-2"))
        self.assertEqual(UPDATER.parse_pkgbuild(REALISTIC_PKGBUILD.replace("_srcname=cachyos-${_major}.${_minor}-${_tagrel}", "_srcname=cachyos-7.3.0-2"))[1], "cachyos-7.3.0-2")

    def test_unsupported_or_ambiguous_pkgbuild_syntax_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "_srcname"):
            UPDATER.parse_pkgbuild(REALISTIC_PKGBUILD.replace("cachyos-${_major}.${_minor}-${_tagrel}", "$(touch /tmp/nope)"))
        with self.assertRaisesRegex(ValueError, "one literal"):
            UPDATER.parse_pkgbuild(REALISTIC_PKGBUILD.replace("_minor=0", "_minor=${SOME_VALUE}"))

    def test_live_metadata_uses_matching_immutable_git_refs(self):
        def head(repo): return KERNEL_REV if "linux-cachyos" in repo else PATCH_REV
        def raw(url):
            if url.endswith("/PKGBUILD"): return REALISTIC_PKGBUILD.encode()
            if url.endswith("/config"): return b"config-data"
            if "/sched/0001-bore-cachy.patch" in url: return b"patch-data"
            raise AssertionError(url)
        with patch.object(UPDATER, "git_head", side_effect=head) as heads, \
             patch.object(UPDATER, "curl_bytes", side_effect=raw), \
             patch.object(UPDATER, "assert_url") as available:
            data = UPDATER.resolve_metadata("bore")
        self.assertEqual(heads.call_count, 2)
        self.assertEqual(data["configRev"], KERNEL_REV)
        self.assertEqual(data["patchRev"], PATCH_REV)
        self.assertEqual(data["configUrl"], f"{UPDATER.KERNEL_RAW}/{KERNEL_REV}/linux-cachyos-bore/config")
        self.assertEqual(data["url"], "https://github.com/CachyOS/linux/releases/download/cachyos-7.3.0-2/cachyos-7.3.0-2.tar.gz")
        available.assert_called_once_with(data["url"])

    def test_hash_prefetch_uses_exact_source_and_nix_prefetch_git_root_dir(self):
        meta = {"version": "7.3.0", "url": CURRENT["url"], "configUrl": CURRENT["configUrl"],
                "configData": b"cfg", "patchRev": PATCH_REV, "patchVersion": "7.3"}
        calls = []
        def fake_run(*args):
            calls.append(args)
            if args[0] == "nix-prefetch-git": return json.dumps({"hash": "base32hash"})
            if args[:3] == ("nix", "hash", "to-sri"): return H2
            return json.dumps({"hash": H2})
        with patch.object(UPDATER, "run", side_effect=fake_run), patch.object(UPDATER, "curl_bytes", return_value=b"cfg"):
            candidate = UPDATER.candidate_hashes(meta)
        prefetch_git = next(c for c in calls if c[0] == "nix-prefetch-git")
        self.assertIn("--root-dir", prefetch_git)
        self.assertIn("7.3/", prefetch_git)
        self.assertEqual(candidate["patchHash"], H2)
        self.assertEqual(set(candidate), set(UPDATER.FIELDS))

    def test_hash_and_schema_validation_rejects_bad_values_and_domains(self):
        with self.assertRaises(ValueError): UPDATER.valid_hash("sha256-not-valid")
        with self.assertRaisesRegex(ValueError, "source archive URL"):
            UPDATER.check_schema({**CURRENT, "url": "https://evil.example/kernel.tar.gz"})
        with self.assertRaisesRegex(ValueError, "config URL"):
            UPDATER.check_schema({**CURRENT, "configUrl": "https://evil.example/config"})

    def test_same_or_older_version_does_not_prefetch_or_write(self):
        original = self.source.read_bytes()
        old_argv = sys.argv
        sys.argv = ["updater", str(self.pkg), "latest"]
        try:
            for version in ("7.2.11", "7.2.9"):
                metadata = {"version": version, "configRev": KERNEL_REV, "patchRev": PATCH_REV}
                with patch.object(UPDATER, "resolve_metadata", return_value=metadata), \
                     patch.object(UPDATER, "candidate_hashes", side_effect=AssertionError("unexpected prefetch")):
                    self.assertEqual(UPDATER.main(), 0)
                self.assertEqual(self.source.read_bytes(), original)
        finally:
            sys.argv = old_argv

    def test_check_mode_reports_new_ref_without_prefetch_or_write(self):
        before = self.source.read_bytes()
        old_argv = sys.argv
        sys.argv = ["updater", str(self.pkg), "latest", "--check"]
        try:
            with patch.object(UPDATER, "resolve_metadata", return_value={"version": "7.3.0", "configRev": KERNEL_REV, "patchRev": PATCH_REV}), \
                 patch.object(UPDATER, "candidate_hashes", side_effect=AssertionError("check mode prefetched")):
                self.assertEqual(UPDATER.main(), 0)
        finally:
            sys.argv = old_argv
        self.assertEqual(self.source.read_bytes(), before)

    def test_evaluation_mismatch_rolls_back_target_and_preserves_peer(self):
        original, peer = self.source.read_bytes(), self.other.read_bytes()
        metadata = {"version": "7.3.0", "configRev": KERNEL_REV, "patchRev": PATCH_REV,
                    "url": "https://github.com/CachyOS/linux/releases/download/cachyos-7.3.0-2/cachyos-7.3.0-2.tar.gz",
                    "configUrl": f"{UPDATER.KERNEL_RAW}/{KERNEL_REV}/linux-cachyos/config", "patchVersion": "7.3"}
        candidate = {"version": "7.3.0", "url": "https://github.com/CachyOS/linux/releases/download/cachyos-7.3.0-2/cachyos-7.3.0-2.tar.gz", "hash": H2,
                     "configUrl": f"{UPDATER.KERNEL_RAW}/{KERNEL_REV}/linux-cachyos/config", "configHash": H2,
                     "patchRev": PATCH_REV, "patchVersion": "7.3", "patchHash": H2}
        old_argv = sys.argv
        sys.argv = ["updater", str(self.pkg), "latest"]
        try:
            with patch.object(UPDATER, "resolve_metadata", return_value=metadata), \
                 patch.object(UPDATER, "candidate_hashes", return_value=candidate), \
                 patch.object(UPDATER, "run", return_value="7.2.11"):
                with self.assertRaisesRegex(ValueError, "evaluated version"):
                    UPDATER.main()
        finally:
            sys.argv = old_argv
        self.assertEqual(self.source.read_bytes(), original)
        self.assertEqual(self.other.read_bytes(), peer)

    def test_hash_failure_leaves_both_sources_untouched(self):
        original, peer = self.source.read_bytes(), self.other.read_bytes()
        old_argv = sys.argv
        sys.argv = ["updater", str(self.pkg), "latest"]
        try:
            with patch.object(UPDATER, "resolve_metadata", return_value={"version": "7.3.0", "configRev": KERNEL_REV, "patchRev": PATCH_REV}), \
                 patch.object(UPDATER, "candidate_hashes", side_effect=RuntimeError("prefetch failed")):
                with self.assertRaisesRegex(RuntimeError, "prefetch failed"): UPDATER.main()
        finally:
            sys.argv = old_argv
        self.assertEqual(self.source.read_bytes(), original)
        self.assertEqual(self.other.read_bytes(), peer)


    def test_success_updates_only_target_for_both_variants(self):
        for variant, name, config_name in (
            ("latest", "linux-cachyos-latest-x86_64-v3", "linux-cachyos"),
            ("bore", "linux-cachyos-bore-x86_64-v3", "linux-cachyos-bore"),
        ):
            with self.subTest(variant=variant), tempfile.TemporaryDirectory() as directory:
                package = Path(directory) / name
                package.mkdir()
                source = package / "source.json"
                source.write_text(json.dumps({**CURRENT, "configUrl": f"{UPDATER.KERNEL_RAW}/{'a' * 40}/{config_name}/config"}))
                source.chmod(0o640)
                peer = Path(directory) / "peer-source.json"
                peer.write_bytes(b"must-not-change")
                candidate = {**CURRENT, "version": "7.3.0", "hash": H2,
                    "url": "https://github.com/CachyOS/linux/releases/download/cachyos-7.3.0-2/cachyos-7.3.0-2.tar.gz",
                    "configUrl": f"{UPDATER.KERNEL_RAW}/{KERNEL_REV}/{config_name}/config",
                    "configHash": H2, "patchRev": PATCH_REV, "patchVersion": "7.3", "patchHash": H2}
                metadata = {**candidate, "configRev": KERNEL_REV}
                with patch.object(sys, "argv", ["updater", str(package), variant]), \
                     patch.object(UPDATER, "resolve_metadata", return_value=metadata), \
                     patch.object(UPDATER, "candidate_hashes", return_value=candidate), \
                     patch.object(UPDATER, "run", return_value="7.3.0"):
                    self.assertEqual(UPDATER.main(), 0)
                self.assertEqual(json.loads(source.read_text()), candidate)
                self.assertEqual(source.stat().st_mode & 0o777, 0o640)
                self.assertEqual(peer.read_bytes(), b"must-not-change")
                self.assertEqual(list(package.iterdir()), [source])

    def test_interrupt_rolls_back_and_cleans_temporary_file(self):
        original = self.source.read_bytes()
        candidate = {**CURRENT, "version": "7.3.0", "patchVersion": "7.3", "patchRev": PATCH_REV,
            "url": "https://github.com/CachyOS/linux/releases/download/cachyos-7.3.0-2/cachyos-7.3.0-2.tar.gz"}
        with patch.object(sys, "argv", ["updater", str(self.pkg), "latest"]), \
             patch.object(UPDATER, "resolve_metadata", return_value={**candidate, "configRev": KERNEL_REV}), \
             patch.object(UPDATER, "candidate_hashes", return_value=candidate), \
             patch.object(UPDATER, "run", side_effect=KeyboardInterrupt):
            with self.assertRaises(KeyboardInterrupt):
                UPDATER.main()
        self.assertEqual(self.source.read_bytes(), original)
        self.assertEqual(list(self.pkg.iterdir()), [self.source])

    def test_missing_release_asset_and_config_fail_before_writes(self):
        original = self.source.read_bytes()
        with patch.object(sys, "argv", ["updater", str(self.pkg), "latest"]), \
             patch.object(UPDATER, "git_head", return_value=KERNEL_REV), \
             patch.object(UPDATER, "curl_bytes", return_value=REALISTIC_PKGBUILD.encode()), \
             patch.object(UPDATER, "assert_url", side_effect=RuntimeError("missing asset")):
            with self.assertRaisesRegex(RuntimeError, "missing asset"):
                UPDATER.main()
        self.assertEqual(self.source.read_bytes(), original)
        with patch.object(sys, "argv", ["updater", str(self.pkg), "latest"]), \
             patch.object(UPDATER, "git_head", return_value=KERNEL_REV), \
             patch.object(UPDATER, "curl_bytes", side_effect=[REALISTIC_PKGBUILD.encode(), RuntimeError("missing config")]), \
             patch.object(UPDATER, "assert_url"):
            with self.assertRaisesRegex(RuntimeError, "missing config"):
                UPDATER.main()
        self.assertEqual(self.source.read_bytes(), original)


if __name__ == "__main__": unittest.main(verbosity=2)
