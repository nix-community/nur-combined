#!/usr/bin/env python3
"""Offline tests for official ArtCraft binary release updates."""
import base64
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("artcraft_update", ROOT / "scripts/update-artcraft.py")
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)
H1 = "sha256-" + base64.b64encode(b"a" * 32).decode()
H2 = "sha256-" + base64.b64encode(b"b" * 32).decode()
URL = "https://github.com/storytold/filmcraft/releases/download/v1.2.4/filmcraft-1.2.4-linux-x86_64.tar.gz"


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.source = self.root / "pkgs/filmcraft/source.json"
        self.source.parent.mkdir(parents=True)
        self.original = (json.dumps({"version": "1.2.3", "hash": H1}) + "\n").encode()
        self.source.write_bytes(self.original)

    def test_new_release_pins_version_and_matching_digest(self):
        def run(args, **kwargs):
            if args[1:3] == ["store", "prefetch-file"]:
                return subprocess.CompletedProcess(args, 0, json.dumps({"hash": H2}), "")
            return subprocess.CompletedProcess(args, 0, "1.2.4", "")
        with patch.object(updater, "ROOT", self.root), patch.object(updater, "latest", return_value=("1.2.4", URL, H2)), patch.object(updater.subprocess, "run", side_effect=run):
            updater.update("filmcraft")
        self.assertEqual(json.loads(self.source.read_text()), {"version": "1.2.4", "hash": H2})

    def test_mismatched_download_digest_fails_before_write(self):
        result = subprocess.CompletedProcess([], 0, json.dumps({"hash": H1}), "")
        with patch.object(updater, "ROOT", self.root), patch.object(updater, "latest", return_value=("1.2.4", URL, H2)), patch.object(updater.subprocess, "run", return_value=result):
            with self.assertRaisesRegex(ValueError, "download hash"):
                updater.update("filmcraft")
        self.assertEqual(self.source.read_bytes(), self.original)

    def test_eval_failure_rolls_back(self):
        result = subprocess.CompletedProcess([], 0, json.dumps({"hash": H2}), "")
        with patch.object(updater, "ROOT", self.root), patch.object(updater, "latest", return_value=("1.2.4", URL, H2)), patch.object(updater.subprocess, "run", side_effect=[result, RuntimeError("evaluation failed")]):
            with self.assertRaisesRegex(RuntimeError, "evaluation failed"):
                updater.update("filmcraft")
        self.assertEqual(self.source.read_bytes(), self.original)
        self.assertEqual(list(self.source.parent.iterdir()), [self.source])

    def test_equal_changed_digest_fails_and_older_does_not_downgrade(self):
        with patch.object(updater, "ROOT", self.root), patch.object(updater, "latest", return_value=("1.2.3", URL, H2)):
            with self.assertRaisesRegex(ValueError, "digest changed"):
                updater.update("filmcraft")
        with patch.object(updater, "ROOT", self.root), patch.object(updater, "latest", return_value=("1.2.2", URL, H2)), patch.object(updater.subprocess, "run", side_effect=AssertionError("unexpected fetch")):
            updater.update("filmcraft")
        self.assertEqual(self.source.read_bytes(), self.original)

    def test_latest_validates_identity_and_digest(self):
        class Response:
            def __init__(self, release): self.release = release
            def __enter__(self): return self
            def __exit__(self, *args): pass
            def read(self, *args): return json.dumps(self.release).encode()
        class Opener:
            def __init__(self, release): self.release = release
            def open(self, *args, **kwargs): return Response(self.release)
        release = {"tag_name": "v1.2.4", "draft": False, "prerelease": False, "assets": [{"name": "filmcraft-1.2.4-linux-x86_64.tar.gz", "browser_download_url": URL, "digest": "sha256:" + (b"b" * 32).hex()}]}
        with patch.object(updater.urllib.request, "build_opener", return_value=Opener(release)):
            self.assertEqual(updater.latest("filmcraft"), ("1.2.4", URL, H2))
        for changed in ({**release, "prerelease": True}, {**release, "assets": []}, {**release, "assets": [{**release["assets"][0], "browser_download_url": "https://example.org/a"}]}):
            with self.subTest(changed=changed), patch.object(updater.urllib.request, "build_opener", return_value=Opener(changed)):
                with self.assertRaises(ValueError): updater.latest("filmcraft")


if __name__ == "__main__":
    unittest.main(verbosity=2)
