#!/usr/bin/env python3
"""Focused tests for M4 network and installer helper contracts."""

import importlib.machinery
import importlib.util
import json
import os
import socket
import sys
import unittest
from unittest import mock


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HELPER = os.path.join(ROOT, "config/includes.chroot/usr/local/bin/moonlight-helper")
LIB = os.path.join(ROOT, "config/includes.chroot/usr/local/lib/moonlight-os")
sys.path.insert(0, LIB)


def load_helper():
    loader = importlib.machinery.SourceFileLoader("moonlight_helper_m4", HELPER)
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


helper = load_helper()


class UsbSharedStateTest(unittest.TestCase):
    def test_attached_export_remains_shared_after_usbipd_hides_it(self):
        mh = helper.usb_module()
        response = mock.Mock(stdout="usbip: info: no exportable devices found\n")

        def isdir(path):
            return path == os.path.join(mh.USBIP_HOST_DRIVER, "1-2.1")

        with mock.patch.object(mh, "_usbip", return_value=response), \
             mock.patch.object(mh.os, "listdir", return_value=["bind", "1-2.1"]), \
             mock.patch.object(mh.os.path, "isdir", side_effect=isdir):
            self.assertEqual(mh.bound_busids(), {"1-2.1"})

    def test_daemon_and_driver_shared_states_are_merged(self):
        mh = helper.usb_module()
        response = mock.Mock(stdout="busid=2-4#usbid=1234:5678#\n")

        with mock.patch.object(mh, "_usbip", return_value=response), \
             mock.patch.object(mh.os, "listdir", return_value=["3-1"]), \
             mock.patch.object(mh.os.path, "isdir", return_value=True):
            self.assertEqual(mh.bound_busids(), {"2-4", "3-1"})


class HiddenWifiTest(unittest.TestCase):
    def test_hidden_network_uses_fixed_nmcli_arguments(self):
        calls = []

        def fake_run(argv, timeout=30, input_text=None):
            del timeout
            calls.append((argv, input_text))
            if argv[:5] == ["nmcli", "--ask", "device", "wifi", "connect"]:
                return "connected", None
            if argv[0] == "hostname":
                return "moonlight-os\n", None
            if argv[:4] == ["ip", "-4", "-o", "addr"]:
                return "", None
            if argv[0] == "nmcli":
                return "", None
            raise AssertionError("unexpected command: %r" % argv)

        with mock.patch.object(helper, "run", fake_run):
            result = helper.op_wifi_connect(
                {"ssid": "Quiet Network", "psk": "correct horse", "hidden": True},
                lambda message: None,
            )

        self.assertEqual(result["hostname"], "moonlight-os")
        self.assertEqual(
            calls[0],
            (["nmcli", "--ask", "device", "wifi", "connect", "Quiet Network",
              "hidden", "yes"], "correct horse\n"),
        )

    def test_hidden_flag_must_be_boolean(self):
        with self.assertRaises(helper.Error) as raised:
            helper.op_wifi_connect(
                {"ssid": "network", "psk": "abcdefgh", "hidden": "yes"},
                lambda message: None,
            )
        self.assertEqual(raised.exception.code, helper.E_BAD_REQUEST)

    def test_saved_networks_are_named_and_filtered(self):
        saved = (
            "11111111-2222-3333-4444-555555555555:Cafe\\: upstairs:802-11-wireless\n"
            "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee:Wired:802-3-ethernet\n"
        )
        with mock.patch.object(helper, "run", return_value=(saved, None)):
            result = helper.op_wifi_saved({}, lambda message: None)
        self.assertEqual(result["connections"], [{
            "uuid": "11111111-2222-3333-4444-555555555555",
            "name": "Cafe: upstairs",
        }])

    def test_forget_uses_uuid_not_connection_name(self):
        uuid = "11111111-2222-3333-4444-555555555555"
        calls = []

        def fake_run(argv, timeout=30, input_text=None):
            del timeout, input_text
            calls.append(argv)
            if argv[:3] == ["nmcli", "connection", "delete"]:
                return "deleted", None
            return "", None

        with mock.patch.object(helper, "run", fake_run):
            helper.op_wifi_forget({"uuid": uuid}, lambda message: None)
        self.assertEqual(calls[0], ["nmcli", "connection", "delete", "uuid", uuid])


class InstallInventoryTest(unittest.TestCase):
    def inventory(self):
        return json.dumps({"blockdevices": [
            {"name": "/dev/sdb", "path": "/dev/sdb", "size": 32_000_000_000,
             "type": "disk", "model": "Live USB", "children": []},
            {"name": "/dev/loop0", "path": "/dev/loop0", "size": 8_000_000_000,
             "type": "disk", "model": "Loop", "children": []},
            {"name": "/dev/sdc", "path": "/dev/sdc", "size": 4_000_000_000,
             "type": "disk", "model": "Too small", "children": []},
            {"name": "/dev/nvme0n1", "path": "/dev/nvme0n1", "size": 500_000_000_000,
             "type": "disk", "model": "Fast Disk", "children": [
                 {"name": "/dev/nvme0n1p3", "path": "/dev/nvme0n1p3",
                  "type": "part", "fstype": "ext4", "label": "Moonlight OS",
                  "mountpoints": [None]},
             ]},
        ]})

    def test_excludes_live_loop_and_small_disks(self):
        with mock.patch.object(helper.os.path, "isdir", return_value=True), \
             mock.patch.object(helper.os.path, "isfile", return_value=True), \
             mock.patch.object(helper, "install_live_disk", return_value="/dev/sdb"), \
             mock.patch.object(helper, "backup_archives", return_value=[]), \
             mock.patch.object(helper, "run", return_value=(self.inventory(), None)):
            result = helper.op_install_status({}, lambda message: None)

        self.assertTrue(result["available"])
        self.assertEqual([item["device"] for item in result["targets"]], ["/dev/nvme0n1"])
        self.assertEqual(result["targets"][0]["contents"], ["Moonlight OS"])
        self.assertEqual(result["settings_sources"], [{
            "kind": "installation",
            "path": "/dev/nvme0n1p3",
            "disk": "/dev/nvme0n1",
            "label": "Moonlight OS",
        }])

    def test_lists_only_valid_backup_sources(self):
        archives = [
            {"path": "/media/key/moonlight-os-settings-good.tar.gz",
             "name": "moonlight-os-settings-good.tar.gz", "summary": ["Wi-Fi"],
             "valid": True},
            {"path": "/media/key/moonlight-os-settings-bad.tar.gz",
             "name": "moonlight-os-settings-bad.tar.gz", "summary": [],
             "valid": False},
        ]
        with mock.patch.object(helper.os.path, "isdir", return_value=True), \
             mock.patch.object(helper.os.path, "isfile", return_value=True), \
             mock.patch.object(helper, "install_live_disk", return_value="/dev/sdb"), \
             mock.patch.object(helper, "backup_archives", return_value=archives), \
             mock.patch.object(helper, "run", return_value=(self.inventory(), None)):
            result = helper.op_install_status({}, lambda message: None)

        self.assertEqual(result["settings_sources"][-1], {
            "kind": "archive",
            "path": "/media/key/moonlight-os-settings-good.tar.gz",
            "label": "moonlight-os-settings-good.tar.gz",
            "summary": ["Wi-Fi"],
        })

    def test_fails_closed_when_live_disk_is_unknown(self):
        with mock.patch.object(helper.os.path, "isdir", return_value=True), \
             mock.patch.object(helper.os.path, "isfile", return_value=True), \
             mock.patch.object(helper, "install_live_disk", return_value=""):
            result = helper.op_install_status({}, lambda message: None)

        self.assertFalse(result["available"])
        self.assertFalse(result["targets"])
        self.assertIn("could not be identified", result["reason"])

    def test_install_launch_passes_only_a_revalidated_target(self):
        context = {"terminal_available": True, "install_available": True,
                   "persistence_available": False, "persistence": False}
        inventory = {"targets": [{"device": "/dev/nvme0n1"}]}
        with mock.patch.object(helper, "op_system_context", return_value=context), \
             mock.patch.object(helper, "op_install_status", return_value=inventory), \
             mock.patch.object(helper, "launch_system_workflow") as launch:
            result = helper.op_system_launch(
                {"workflow": "install", "device": "/dev/nvme0n1"},
                lambda message: None,
            )

        self.assertEqual(result["device"], "/dev/nvme0n1")
        launch.assert_called_once_with(
            "install", {"MLOS_INSTALL_DEVICE": "/dev/nvme0n1"})

    def test_workflow_escapes_helper_no_new_privileges_as_unprivileged_unit(self):
        with mock.patch.object(helper.glob, "glob", return_value=["/run/user/1000/sway.sock"]), \
             mock.patch.object(helper, "run", return_value=("", None)) as run:
            helper.launch_system_workflow(
                "install", {"MLOS_INSTALL_DEVICE": "/dev/nvme0n1"})

        argv = run.call_args.args[0]
        self.assertEqual(argv[0], "systemd-run")
        self.assertIn("--service-type=exec", argv)
        self.assertIn("--uid=moonlight", argv)
        self.assertIn("--setenv=MLOS_PANEL_COMMAND=install", argv)
        self.assertIn("--setenv=MLOS_INSTALL_DEVICE=/dev/nvme0n1", argv)
        self.assertIn("--setenv=SWAYSOCK=/run/user/1000/sway.sock", argv)
        self.assertEqual(argv[-1], "/usr/local/bin/moonlight-panel")
        self.assertNotIn("runuser", argv)

    def test_install_launch_rejects_a_stale_target(self):
        context = {"terminal_available": True, "install_available": True,
                   "persistence_available": False, "persistence": False}
        with mock.patch.object(helper, "op_system_context", return_value=context), \
             mock.patch.object(helper, "op_install_status", return_value={"targets": []}):
            with self.assertRaises(helper.Error) as raised:
                helper.op_system_launch(
                    {"workflow": "install", "device": "/dev/nvme0n1"},
                    lambda message: None,
                )
        self.assertEqual(raised.exception.code, helper.E_BAD_REQUEST)

    def test_update_launch_is_allowlisted_for_installed_systems(self):
        context = {"terminal_available": True, "install_available": False,
                   "persistence_available": False, "persistence": False,
                   "update_available": True}
        with mock.patch.object(helper, "op_system_context", return_value=context), \
             mock.patch.object(helper, "launch_system_workflow") as launch:
            result = helper.op_system_launch(
                {"workflow": "update"}, lambda message: None,
            )

        self.assertEqual(result, {"launched": "update"})
        launch.assert_called_once_with("update", {})


class ClientProtocolTest(unittest.TestCase):
    def test_oversized_request_is_rejected_and_connection_closed(self):
        server, client = socket.socketpair()
        self.addCleanup(client.close)
        client.sendall(b"{" + b"x" * helper.MAX_REQUEST_BYTES + b"}\n")
        client.shutdown(socket.SHUT_WR)

        with mock.patch.object(helper, "usb_session_release"), \
             mock.patch.object(helper, "disk_session_release"):
            helper.handle_client(server)

        reply = json.loads(client.makefile("rb").readline())
        self.assertFalse(reply["ok"])
        self.assertEqual(reply["error"]["code"], helper.E_BAD_REQUEST)
        self.assertIn("exceeds", reply["error"]["message"])


class FirstRunStateTest(unittest.TestCase):
    def test_setup_completion_requires_exact_boolean(self):
        with self.assertRaises(helper.Error) as raised:
            helper.op_setup_complete({"completed": "true"}, lambda message: None)
        self.assertEqual(raised.exception.code, helper.E_BAD_REQUEST)

    def test_setup_completion_writes_only_the_fixed_flag(self):
        opened = mock.mock_open()
        with mock.patch.object(helper.os, "makedirs") as makedirs, \
             mock.patch.object(helper, "open", opened), \
             mock.patch.object(helper.os, "chmod") as chmod, \
             mock.patch.object(helper.os.path, "exists", return_value=True), \
             mock.patch.object(helper.os.path, "isdir", return_value=False):
            result = helper.op_setup_complete({"completed": True}, lambda message: None)

        makedirs.assert_called_once_with("/etc/moonlight-os", mode=0o755, exist_ok=True)
        opened.assert_called_once_with(helper.FIRST_RUN_FLAG, "a", encoding="utf-8")
        chmod.assert_called_once_with(helper.FIRST_RUN_FLAG, 0o644)
        self.assertTrue(result["configured"])

    def test_live_setup_completion_also_retires_welcome_for_this_boot(self):
        opened = mock.mock_open()

        def isdir(path):
            return path == "/run/live/medium"

        with mock.patch.object(helper.os, "makedirs") as makedirs, \
             mock.patch.object(helper, "open", opened), \
             mock.patch.object(helper.os, "chmod"), \
             mock.patch.object(helper.os.path, "exists", return_value=True), \
             mock.patch.object(helper.os.path, "isdir", side_effect=isdir):
            result = helper.op_setup_complete({"completed": True}, lambda message: None)

        self.assertIn(
            mock.call("/run/moonlight-os", mode=0o755, exist_ok=True),
            makedirs.call_args_list,
        )
        self.assertIn(
            mock.call(helper.WELCOME_FLAG, "a", encoding="utf-8"),
            opened.call_args_list,
        )
        self.assertTrue(result["welcome_done"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
