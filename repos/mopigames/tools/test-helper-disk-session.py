#!/usr/bin/env python3
"""Synthetic regression tests for M9's read-only system-disk lease."""

import importlib.machinery
import importlib.util
import json
import os
import socket
import stat
import tempfile
import threading
import unittest
from unittest import mock


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HELPER = os.path.join(ROOT, "config/includes.chroot/usr/local/bin/moonlight-helper")


def load_helper():
    loader = importlib.machinery.SourceFileLoader("moonlight_helper_disk", HELPER)
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


helper = load_helper()


class DiskSessionLeaseTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.old_state = helper.DISK_SESSION_STATE
        helper.DISK_SESSION_STATE = os.path.join(self.temporary.name, "disk-owned")
        helper.DISK_SESSION_REFS = 0
        helper.DISK_SESSION_INFO = None

    def tearDown(self):
        helper.DISK_SESSION_STATE = self.old_state
        helper.DISK_SESSION_REFS = 0
        helper.DISK_SESSION_INFO = None
        self.temporary.cleanup()

    def info(self):
        return {"device": "/dev/loop-test", "size": 64 * 1024 * 1024,
                "sector_size": 512}

    def test_discovers_parent_disk_and_geometry_without_caller_path(self):
        answers = {
            "findmnt": ("/dev/mmcblk1p3\n", None),
            "lsblk": ("mmcblk1\n", None),
            "blockdev-size": ("62537072640\n", None),
            "blockdev-sector": ("512\n", None),
        }

        def fake_run(argv, timeout=30, input_text=None):
            del timeout, input_text
            if argv[0] == "findmnt": return answers["findmnt"]
            if argv[0] == "lsblk": return answers["lsblk"]
            if argv[:2] == ["blockdev", "--getsize64"]: return answers["blockdev-size"]
            if argv[:2] == ["blockdev", "--getss"]: return answers["blockdev-sector"]
            raise AssertionError(argv)

        block = mock.Mock(st_mode=stat.S_IFBLK)
        with mock.patch.object(helper, "run", side_effect=fake_run), \
             mock.patch.object(helper.os, "stat", return_value=block):
            info = helper.disk_backing_info()
        self.assertEqual(info["device"], "/dev/mmcblk1")
        self.assertEqual(info["size"], 62537072640)
        self.assertEqual(info["sector_size"], 512)

    def test_lease_is_shared_and_last_disconnect_removes_exact_target(self):
        created = []
        removed = []
        first, second = [False], [False]
        def remove():
            removed.append(True)
            return True

        with mock.patch.object(helper, "disk_backing_info", side_effect=self.info), \
             mock.patch.object(helper, "disk_target_create", side_effect=lambda info: created.append(info)), \
             mock.patch.object(helper, "disk_target_remove", side_effect=remove):
            one = helper.op_disk_session_acquire({}, lambda message: None, first)
            two = helper.op_disk_session_acquire({}, lambda message: None, second)
            self.assertTrue(one["readonly"])
            self.assertEqual(one, two)
            self.assertEqual(len(created), 1)
            self.assertEqual(helper.DISK_SESSION_REFS, 2)
            helper.disk_session_release(first)
            self.assertFalse(removed)
            helper.disk_session_release(second)
            self.assertEqual(removed, [True])
            self.assertEqual(helper.DISK_SESSION_REFS, 0)

    def test_helper_connection_owns_and_releases_disk(self):
        created = []
        removed = []
        client, server = socket.socketpair()
        def remove():
            removed.append(True)
            return True

        with mock.patch.object(helper, "disk_backing_info", side_effect=self.info), \
             mock.patch.object(helper, "disk_target_create", side_effect=lambda info: created.append(info)), \
             mock.patch.object(helper, "disk_target_remove", side_effect=remove):
            thread = threading.Thread(target=helper.handle_client, args=(server,))
            thread.start()
            stream = client.makefile("rwb")
            stream.write(json.dumps({"id": 1, "op": "disk.session.acquire"}).encode() + b"\n")
            stream.flush()
            reply = json.loads(stream.readline())
            self.assertTrue(reply["ok"])
            self.assertEqual(reply["result"]["iqn"], helper.DISK_TARGET_IQN)
            stream.close()
            client.close()
            thread.join(timeout=2)
            self.assertFalse(thread.is_alive())
            self.assertEqual(len(created), 1)
            self.assertEqual(removed, [True])

    def test_failed_create_clears_journal_and_does_not_take_lease(self):
        owned = [False]
        with mock.patch.object(helper, "disk_backing_info", side_effect=self.info), \
             mock.patch.object(helper, "disk_target_create", side_effect=helper.Error(helper.E_FAILED, "nope")), \
             mock.patch.object(helper, "disk_target_remove", return_value=True):
            with self.assertRaises(helper.Error):
                helper.op_disk_session_acquire({}, lambda message: None, owned)
        self.assertFalse(owned[0])
        self.assertEqual(helper.DISK_SESSION_REFS, 0)
        self.assertFalse(os.path.exists(helper.DISK_SESSION_STATE))

    def test_restart_recovery_is_scoped_to_its_journal(self):
        removed = []
        helper.persist_disk_session(True)
        def remove():
            removed.append(True)
            return True

        with mock.patch.object(helper, "disk_target_remove", side_effect=remove):
            helper.recover_disk_session()
        self.assertEqual(removed, [True])
        self.assertFalse(os.path.exists(helper.DISK_SESSION_STATE))

    def test_failed_release_keeps_recovery_journal(self):
        helper.persist_disk_session(True)
        helper.DISK_SESSION_REFS = 1
        helper.DISK_SESSION_INFO = self.info()
        owned = [True]
        with mock.patch.object(helper, "disk_target_remove", return_value=False):
            helper.disk_session_release(owned)
        self.assertFalse(owned[0])
        self.assertTrue(os.path.exists(helper.DISK_SESSION_STATE))


if __name__ == "__main__":
    unittest.main()
