#!/usr/bin/env python3
"""用本包 Python 测试压缩响应；不联网、不读取账户或个人词库。"""

import argparse
import importlib
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest


def test_protocol(package):
    sys.path.insert(0, str(package / "share/vtype-linux/cloud"))
    protocol = importlib.import_module("官方同步探针")
    import snappy

    class Response:
        def __init__(self, data, compression):
            self.data = data
            self.headers = {"Kb-CompressionType": compression}

        def __enter__(self):
            return self

        def __exit__(self, *_):
            pass

        def read(self, limit):
            return self.data[:limit]

    class Transport:
        def __init__(self, response):
            self.response = response

        def open(self, *_args, **_kwargs):
            return self.response

    def request(data, compression="2", encrypted=False):
        # 不调用 Probe 构造器：密钥、HTTP 响应均来自测试数据。
        probe = protocol.Probe.__new__(protocol.Probe)
        probe.key = b"0123456789ABCDEF0123456789ABCDEF"
        probe.offset = 0
        probe.task = 1
        payload = protocol.aes(data, probe.key, True) if encrypted else data
        probe.http = Transport(Response(payload, compression))
        return probe.request("/api_v2" if encrypted else "/timestamp", b"")

    class CloudRuntimeTests(unittest.TestCase):
        def test_compressed_response(self):
            for plain in [b"", b"hello", "微信双拼".encode(), bytes(range(256)) * 8]:
                for encrypted in [False, True]:
                    with self.subTest(size=len(plain), encrypted=encrypted):
                        self.assertEqual(request(snappy.compress(plain), encrypted=encrypted), plain)

        def test_invalid_compression(self):
            with self.assertRaises(ValueError):
                request(b"invalid snappy payload")

        def test_decompressed_size_limit(self):
            with self.assertRaises(ValueError):
                request(snappy.compress(b"x" * (2 * 1024 * 1024 + 1)))

        def test_plain_and_unknown_compression(self):
            self.assertEqual(request(b"test", "1"), b"test")
            with self.assertRaises(ValueError):
                request(b"test", "3")

        def test_openssl_available(self):
            subprocess.run(["openssl", "version"], stdout=subprocess.DEVNULL, check=True)

    result = unittest.TextTestRunner(verbosity=2).run(
        unittest.defaultTestLoader.loadTestsFromTestCase(CloudRuntimeTests))
    return 0 if result.wasSuccessful() else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--runtime", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()
    package = args.package.resolve()
    if args.runtime:
        return test_protocol(package)
    wrapper = (package / "bin/wetype-cloud").read_text()
    launcher = re.search(r"^exec (\S+)", wrapper, re.MULTILINE).group(1)
    with tempfile.TemporaryDirectory(prefix="vtype-cloud-test.") as root:
        env = dict(os.environ, WETYPE_STATE_DIR=root, PATH="/nonexistent")
        return subprocess.run(
            [launcher, str(Path(__file__).resolve()), "--package", str(package), "--runtime"],
            env=env).returncode


if __name__ == "__main__":
    sys.exit(main())
