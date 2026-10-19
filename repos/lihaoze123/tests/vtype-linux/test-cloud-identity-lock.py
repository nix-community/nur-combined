#!/usr/bin/env python3
"""离线验证云候选与后台同步竞争身份锁；不读取用户账户、不联网。"""

import argparse
import ast
import fcntl
import json
from pathlib import Path
import tempfile
import threading
import time
from types import SimpleNamespace
import unittest


class CloudIdentityLockTests(unittest.TestCase):
    source = None

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="vtype-identity-lock-")
        self.addCleanup(self.directory.cleanup)
        self.state = Path(self.directory.name)
        (self.state / "identity.json").write_text("{}")
        self.requests = []
        requests = self.requests

        class Probe:
            def __init__(self, identity):
                pass

            def request(self, *args, **kwargs):
                requests.append((args, kwargs))
                return b"synthetic-response"

        tree = ast.parse((self.source / "cloud/实时云桥接.py").read_text())
        main = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "main")
        query = next(n for n in main.body if isinstance(n, ast.FunctionDef) and n.name == "query_cloud")
        namespace = dict(
            p=SimpleNamespace(STATE=self.state, Probe=Probe),
            fcntl=fcntl, json=json, time=time, candidates=lambda response: [], config={},
        )
        exec(compile(ast.Module(body=[query], type_ignores=[]), str(self.source), "exec"), namespace)
        self.query = namespace["query_cloud"]

    def hold_lock(self):
        lock = (self.state / "identity.lock").open("a+")
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        self.addCleanup(lock.close)
        return lock

    def test_uncontended_query(self):
        self.assertEqual(self.query(1, b"query"), b"synthetic-response")
        self.assertEqual(len(self.requests), 1)

    def test_brief_sync_contention_keeps_cloud_query(self):
        lock = self.hold_lock()
        release = threading.Timer(.05, lambda: fcntl.flock(lock, fcntl.LOCK_UN))
        release.start()
        try:
            self.assertEqual(self.query(1, b"query"), b"synthetic-response")
            self.assertEqual(len(self.requests), 1)
        finally:
            release.join()

    def test_long_sync_contention_is_bounded(self):
        self.hold_lock()
        started = time.monotonic()
        with self.assertRaises(BlockingIOError):
            self.query(1, b"query")
        self.assertLess(time.monotonic() - started, 1.3)
        self.assertEqual(self.requests, [])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    args, remaining = parser.parse_known_args()
    CloudIdentityLockTests.source = args.source
    unittest.main(argv=[__file__, *remaining])
