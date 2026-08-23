#!/usr/bin/env python3
"""Regression tests for moonlight-helper's native Selene USB lease."""

import importlib.machinery
import importlib.util
import json
import os
import re
import socket
import tempfile
import threading
import unittest


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HELPER = os.path.join(
    ROOT, "config/includes.chroot/usr/local/bin/moonlight-helper")


def load_helper():
    loader = importlib.machinery.SourceFileLoader("moonlight_helper", HELPER)
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


helper = load_helper()


class Device:
    def __init__(self, busid, label=None, reason="", protected=False):
        self.busid = busid
        self.hwid = "1234:5678"
        self.label = label or busid
        self.reason = reason
        self.protected = protected


class FakeUsb:
    BUSID_RE = re.compile(r"^\d+-\d+(\.\d+)*$")

    def __init__(self, devices, bound=(), enabled=True):
        self.all_devices = list(devices)
        self.bound = set(bound)
        self.enabled = enabled
        self.bind_calls = []
        self.unbind_calls = []

    def load_conf(self):
        return {
            "USB_AUTOSHARE": "yes" if self.enabled else "no",
            "USB_AUTOSHARE_POLICY": "safe",
        }

    def offered(self, policy="safe", include=(), exclude=()):
        del policy, include, exclude
        return [device for device in self.all_devices if not device.reason]

    def devices(self, policy="safe", include=(), exclude=()):
        del policy, include, exclude
        return list(self.all_devices)

    def ensure_daemon(self):
        return True

    def bound_busids(self):
        return set(self.bound)

    def bind(self, busid):
        self.bind_calls.append(busid)
        self.bound.add(busid)
        return True, ""

    def unbind(self, busid):
        self.unbind_calls.append(busid)
        self.bound.discard(busid)
        return True

    def host_settings(self):
        return "", 48020, ""


class UsbSessionLeaseTest(unittest.TestCase):
    def setUp(self):
        helper.USB_SESSION_REFS.clear()
        self.old_usb_module = helper.usb_module
        self.old_conf_values = helper.conf_values
        self.old_session_state = helper.USB_SESSION_STATE
        self.temporary = tempfile.TemporaryDirectory()
        helper.USB_SESSION_STATE = os.path.join(self.temporary.name, "owned")
        helper.conf_values = lambda: {
            "USB_AUTOSHARE": "yes",
            "USB_AUTOSHARE_POLICY": "safe",
        }

    def tearDown(self):
        helper.usb_module = self.old_usb_module
        helper.conf_values = self.old_conf_values
        helper.USB_SESSION_STATE = self.old_session_state
        helper.USB_SESSION_REFS.clear()
        self.temporary.cleanup()

    def use(self, fake):
        helper.usb_module = lambda: fake

    def test_acquires_and_releases_only_the_session_device(self):
        fake = FakeUsb([Device("1-2", "Wheel")])
        self.use(fake)
        owned = set()

        result = helper.op_usb_session_sync({}, lambda message: None, owned)
        self.assertEqual(owned, {"1-2"})
        self.assertEqual(fake.bind_calls, ["1-2"])
        self.assertTrue(result["devices"][0]["shared"])

        helper.usb_session_release(owned)
        self.assertEqual(fake.unbind_calls, ["1-2"])
        self.assertFalse(fake.bound)

    def test_preexisting_manual_share_survives_disconnect(self):
        fake = FakeUsb([Device("1-2", "Wheel")], bound={"1-2"})
        self.use(fake)
        owned = set()

        helper.op_usb_session_sync({}, lambda message: None, owned)
        self.assertFalse(owned)
        helper.usb_session_release(owned)
        self.assertEqual(fake.bound, {"1-2"})
        self.assertFalse(fake.unbind_calls)

    def test_overlapping_sessions_release_after_last_owner(self):
        fake = FakeUsb([Device("2-4", "HOTAS")])
        self.use(fake)
        first, second = set(), set()

        helper.op_usb_session_sync({}, lambda message: None, first)
        helper.op_usb_session_sync({}, lambda message: None, second)
        self.assertEqual(helper.USB_SESSION_REFS, {"2-4": 2})

        helper.usb_session_release(first)
        self.assertEqual(fake.bound, {"2-4"})
        helper.usb_session_release(second)
        self.assertFalse(fake.bound)
        self.assertEqual(fake.unbind_calls, ["2-4"])

    def test_disabled_auto_share_does_not_claim_manual_device(self):
        fake = FakeUsb([Device("3-1", "Pedals")], bound={"3-1"}, enabled=False)
        self.use(fake)
        owned = set()

        result = helper.op_usb_session_sync({}, lambda message: None, owned)
        self.assertFalse(owned)
        self.assertFalse(fake.bind_calls)
        self.assertTrue(result["devices"][0]["shared"])

    def test_closing_helper_connection_releases_lease(self):
        fake = FakeUsb([Device("4-2", "Wheel")])
        self.use(fake)
        client, server = socket.socketpair()
        thread = threading.Thread(target=helper.handle_client, args=(server,))
        thread.start()

        stream = client.makefile("rwb")
        stream.write(json.dumps({"id": 7, "op": "usb.session.sync"}).encode() + b"\n")
        stream.flush()
        reply = json.loads(stream.readline())
        self.assertTrue(reply["ok"])
        self.assertEqual(fake.bound, {"4-2"})

        stream.close()
        client.close()
        thread.join(timeout=2)
        self.assertFalse(thread.is_alive())
        self.assertFalse(fake.bound)
        self.assertEqual(fake.unbind_calls, ["4-2"])

    def test_restart_journal_recovers_only_session_owned_device(self):
        fake = FakeUsb([Device("5-3", "Pedals")])
        self.use(fake)
        owned = set()

        helper.op_usb_session_sync({}, lambda message: None, owned)
        self.assertTrue(os.path.exists(helper.USB_SESSION_STATE))
        helper.recover_usb_sessions()

        self.assertFalse(fake.bound)
        self.assertEqual(fake.unbind_calls, ["5-3"])
        self.assertFalse(helper.USB_SESSION_REFS)
        self.assertFalse(os.path.exists(helper.USB_SESSION_STATE))

    def test_missing_optional_usb_module_does_not_break_helper_startup(self):
        with open(helper.USB_SESSION_STATE, "w", encoding="utf-8") as stream:
            stream.write("5-3\n")

        def unavailable():
            raise helper.Error(helper.E_UNAVAILABLE, "USB support is absent")

        helper.usb_module = unavailable
        helper.recover_usb_sessions()
        self.assertTrue(os.path.exists(helper.USB_SESSION_STATE))


if __name__ == "__main__":
    unittest.main(verbosity=2)
