import base64
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock
import urllib.error
from email.message import Message


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "update-source.py"
spec = importlib.util.spec_from_file_location("update_source", SCRIPT)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


def sri(body):
    return "sha256-" + base64.b64encode(hashlib.sha256(body).digest()).decode()


class Response(io.BytesIO):
    def __init__(self, body, **headers):
        super().__init__(body)
        self.headers = Message()
        for key, value in headers.items():
            self.headers[key.replace("_", "-")] = str(value)
        self.status = 200

    def getcode(self):
        return self.status


class UpdateSourceTests(unittest.TestCase):
    NOW = 2_000_000_000.0
    WEEK = 7 * 24 * 60 * 60
    URL = "https://example.invalid/app.zip"
    BODY = b"PK\x03\x04archive data"

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.package = self.root / "default.nix"
        self.package.write_text('{\n  version = "1.0";\n  hash = "sha256-old";\n}\n')
        self.cache = self.root / "cache"
        self.entry = self.cache / (hashlib.sha256(self.URL.encode()).hexdigest() + ".json")

    def seed(self, **changes):
        data = dict(url=self.URL, hash=sri(self.BODY), etag='"release-1"',
                    last_modified="", verified_at=self.NOW - 60)
        data.update(changes)
        self.cache.mkdir(exist_ok=True)
        self.entry.write_text(json.dumps(data))
        return data

    def update(self, result, *, version="1.0", force=False, now=None):
        with mock.patch.object(updater.urllib.request, "urlopen", side_effect=[result]) as opened:
            updater.update_source(self.package, version, self.URL, self.cache,
                                  force=force, now=self.NOW if now is None else now)
        return {k.lower(): v for k, v in opened.call_args.args[0].header_items()}

    def not_modified(self):
        return urllib.error.HTTPError(self.URL, 304, "Not Modified", Message(), None)

    def assert_hash(self, body):
        self.assertIn('hash = "' + sri(body) + '";', self.package.read_text())

    def test_initial_download_hashes_bytes_and_saves_validators(self):
        headers = self.update(Response(self.BODY, ETag='"new"', Content_Length=len(self.BODY)))
        self.assertNotIn("if-none-match", headers)
        self.assert_hash(self.BODY)
        data = json.loads(self.entry.read_text())
        self.assertEqual(data["hash"], sri(self.BODY))
        self.assertEqual(data["etag"], '"new"')
        self.assertEqual(data["verified_at"], self.NOW)

    def test_304_reapplies_cached_hash_without_extending_deadline(self):
        cached = self.seed()
        headers = self.update(self.not_modified())
        self.assertEqual(headers.get("if-none-match"), cached["etag"])
        self.assert_hash(self.BODY)
        self.assertEqual(json.loads(self.entry.read_text())["verified_at"], cached["verified_at"])

    def test_changed_body_for_same_version_replaces_hash(self):
        self.seed()
        changed = b"PK\x03\x04new release bytes"
        self.update(Response(changed, ETag='"release-2"'))
        self.assert_hash(changed)

    def test_seven_day_download_deadline_survives_intervening_304(self):
        verified = self.NOW - self.WEEK + 30
        self.seed(verified_at=verified)
        self.update(self.not_modified())
        headers = self.update(Response(self.BODY), now=verified + self.WEEK)
        self.assertNotIn("if-none-match", headers)
        self.assertNotIn("if-modified-since", headers)

    def test_force_bypasses_validators(self):
        self.seed()
        headers = self.update(Response(self.BODY), force=True)
        self.assertNotIn("if-none-match", headers)
        self.assertNotIn("if-modified-since", headers)

    def test_version_upgrade_bypasses_validators_and_updates_version(self):
        self.seed()
        headers = self.update(Response(self.BODY), version="1.1")
        self.assertNotIn("if-none-match", headers)
        self.assertIn('version = "1.1";', self.package.read_text())

    def test_last_modified_fallback_for_weak_etag(self):
        stamp = "Wed, 21 Oct 2015 07:28:00 GMT"
        self.seed(etag='W/"weak"', last_modified=stamp)
        headers = self.update(self.not_modified())
        self.assertNotIn("if-none-match", headers)
        self.assertEqual(headers.get("if-modified-since"), stamp)

    def test_weak_only_etag_requires_full_download(self):
        self.seed(etag='W/"weak"')
        headers = self.update(Response(self.BODY))
        self.assertNotIn("if-none-match", headers)
        self.assertNotIn("if-modified-since", headers)

    def test_malformed_cache_is_a_miss(self):
        for invalid in ("{broken", "[]", '{"url": "wrong"}'):
            with self.subTest(cache=invalid):
                self.cache.mkdir(exist_ok=True)
                self.entry.write_text(invalid)
                headers = self.update(Response(self.BODY))
                self.assertNotIn("if-none-match", headers)
                self.assert_hash(self.BODY)

    def test_failed_downloads_preserve_package_and_cache(self):
        failures = [
            urllib.error.URLError("offline"),
            urllib.error.HTTPError(self.URL, 500, "Server Error", Message(), None),
            Response(self.BODY, Content_Length=len(self.BODY) + 1),
            Response(b"<html>not an archive</html>"),
        ]
        for failure in failures:
            with self.subTest(failure=repr(failure)):
                self.seed()
                before_package = self.package.read_bytes()
                before_cache = self.entry.read_bytes()
                with self.assertRaises(Exception):
                    self.update(failure, version="1.1")
                self.assertEqual(self.package.read_bytes(), before_package)
                self.assertEqual(self.entry.read_bytes(), before_cache)

    def test_downgrade_refused_before_http(self):
        with mock.patch.object(updater.urllib.request, "urlopen") as opened:
            with self.assertRaises(Exception):
                updater.update_source(self.package, "0.9", self.URL, self.cache, now=self.NOW)
            opened.assert_not_called()

    def test_deb_magic_is_checked_for_debian_downloads(self):
        self.URL = "https://example.invalid/app.deb"
        self.entry = self.cache / (hashlib.sha256(self.URL.encode()).hexdigest() + ".json")
        deb = b"!<arch>\npackage contents"
        self.update(Response(deb))
        self.assert_hash(deb)
        before_package = self.package.read_bytes()
        before_cache = self.entry.read_bytes()
        with self.assertRaises(Exception):
            self.update(Response(self.BODY), force=True)
        self.assertEqual(self.package.read_bytes(), before_package)
        self.assertEqual(self.entry.read_bytes(), before_cache)

    def test_wrappers_update_working_checkout_from_separate_source(self):
        commands = self.root / "bin"
        commands.mkdir()
        for name, contents in {
            "curl": "printf '%s\\n' lceda-pro-linux-x64-1.0.zip\n",
            "jq": "cat >/dev/null\nprintf '%s\\n' 1.0\n",
            "python3": 'printf "%s\\n" "$@" > "$RECORD_FILE"\n',
        }.items():
            executable = commands / name
            executable.write_text("#!/bin/sh\n" + contents)
            executable.chmod(0o755)
        environment = {
            key: value for key, value in os.environ.items()
            if not key.startswith("UPDATE_")
        }
        environment["PATH"] = str(commands) + os.pathsep + os.environ["PATH"]
        checkout = self.root / "checkout"
        checkout.mkdir()
        urls = {
            "lceda-pro": "https://image.lceda.cn/files/lceda-pro-linux-x64-1.0.zip",
            "baidunetdisk": "http://wppkg.baidupcs.com/issue/netdisk/Linuxguanjia/1.0/baidunetdisk_1.0_amd64.deb",
        }
        for package, url in urls.items():
            with self.subTest(package=package):
                wrapper = self.root / "source" / "pkgs" / package / "update.sh"
                wrapper.parent.mkdir(parents=True)
                shutil.copyfile(SCRIPT.parents[1] / "pkgs" / package / "update.sh", wrapper)
                package_file = checkout / "pkgs" / package / "default.nix"
                package_file.parent.mkdir(parents=True)
                package_file.write_text(self.package.read_text())
                record = self.root / (package + "-arguments")
                environment["RECORD_FILE"] = str(record)
                completed = subprocess.run(
                    ["bash", str(wrapper)], cwd=checkout, env=environment,
                    capture_output=True, text=True,
                )
                self.assertEqual(completed.returncode, 0, completed.stderr)
                args = record.read_text().splitlines()
                self.assertEqual(len(args), 4)
                self.assertEqual((checkout / args[1]).resolve(), package_file.resolve())
                self.assertEqual(args[2:], ["1.0", url])


if __name__ == "__main__":
    unittest.main()
