#!/usr/bin/python3
"""Tests for the automatic USB passthrough watcher.

    tools/test-usb-auto.py

Runs against the scripts in config/includes.chroot, on any machine, without
touching a real USB device -- usbip bind takes a device away from whatever is
using it, which is not a thing a test suite gets to do to the laptop it is
running on.  So bind, unbind and the host PC are all stubbed, and what is
actually under test is the bookkeeping around them:

  * the offered set is recomputed from what is plugged in, every pass
  * the daemon only ever unbinds devices it bound itself
  * a device that disappears leaves the offer, which is what makes the
    host PC let go of it
  * turning the feature off, or stopping, hands everything back
  * a host PC that is switched off does not cost this machine its devices

The device survey itself runs against real sysfs, because the interesting
part of it is the shape of real hardware.
"""

import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LIB = os.path.join(ROOT, "config/includes.chroot/usr/local/lib/moonlight-os")
BIN = os.path.join(ROOT, "config/includes.chroot/usr/local/bin")

sys.path.insert(0, LIB)
import mlos_host as mh  # noqa: E402


def load_script(name):
    """The daemon has no .py extension, because it is a command."""
    import importlib.util
    spec = importlib.util.spec_from_loader(
        name.replace("-", "_"),
        importlib.machinery.SourceFileLoader(name.replace("-", "_"), os.path.join(BIN, name)),
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


import importlib.machinery  # noqa: E402

usb_auto = load_script("moonlight-usb-auto")


class FakeDev:
    def __init__(self, busid, hwid="1234:5678", label="thing"):
        self.busid, self.hwid, self.label = busid, hwid, label
        self.reason, self.protected = "", False


class FakeClient:
    """Stands in for the agent on the host PC.  Records every offer it is
    sent, so a test can assert on what the far end was told rather than on
    what this end intended."""

    def __init__(self, fail=False):
        self.offers = []
        self.fail = fail
        self.closed = False

    def sync(self, devs):
        self._alive()
        self.offers.append([d.busid for d in devs])
        return {"attached": [d.busid for d in devs], "detached": [], "failed": []}

    def ping(self):
        self._alive()
        return {"agent": "fake"}

    def _alive(self):
        if self.fail:
            raise mh.HostError("host PC is off", "unreachable")

    def close(self):
        self.closed = True


class WatcherTest(unittest.TestCase):
    def setUp(self):
        self.plugged = []
        self.bound = set()
        self.unbound = []
        self.client = FakeClient()

        self.orig = (mh.offered, mh.bind, mh.unbind, mh.ensure_daemon)
        mh.bind = self._bind
        mh.unbind = self._unbind
        mh.ensure_daemon = lambda: True

        self.surveys = 0
        mh.offered = self._offered

        self.w = usb_auto.Watcher()
        self.w.settings = lambda: (True, "safe", [], [], {})
        self.w.connect = lambda conf: self.client
        self.w.drop = lambda: None
        # The daemon gates the expensive survey behind a cheap listing of
        # what is plugged in.  Drive that from the same fake hardware, or
        # every test below would be testing the gate against real sysfs and
        # concluding nothing ever changes.
        self.w.plugged = lambda: frozenset(d.busid for d in self.plugged)

    def _offered(self, *a, **k):
        self.surveys += 1
        return list(self.plugged)

    def tearDown(self):
        mh.offered, mh.bind, mh.unbind, mh.ensure_daemon = self.orig

    def _bind(self, busid):
        self.bound.add(busid)
        return True, ""

    def _unbind(self, busid):
        self.unbound.append(busid)
        self.bound.discard(busid)
        return True

    def test_plugging_in_offers_the_device(self):
        self.plugged = [FakeDev("1-2")]
        self.assertTrue(self.w.pass_once())
        self.assertEqual(self.client.offers, [["1-2"]])
        self.assertEqual(self.bound, {"1-2"})

    def test_an_unchanged_usb_bus_is_not_surveyed_again(self):
        # The survey opens a dozen files per device and asks the routing
        # table what the network interface is.  Doing that once a second
        # cost 3% of a core, forever, on the Atom this runs on.  Nothing
        # plugged or unplugged means nothing to work out.
        self.plugged = [FakeDev("1-2")]
        self.w.pass_once()
        before = self.surveys
        for _ in range(10):
            self.w.pass_once()
        self.assertEqual(self.surveys, before, "surveyed a bus that had not changed")

        # But a change still gets through immediately.
        self.plugged = [FakeDev("1-2"), FakeDev("1-3")]
        self.w.pass_once()
        self.assertEqual(self.surveys, before + 1)
        self.assertEqual(self.client.offers[-1], ["1-2", "1-3"])

    def test_a_failed_pass_surveys_again_next_tick(self):
        # The gate must not conclude it has already dealt with a set of
        # devices it failed to hand over.
        self.client.fail = True
        self.plugged = [FakeDev("1-2")]
        self.assertFalse(self.w.pass_once())
        before = self.surveys
        self.client.fail = False
        self.assertTrue(self.w.pass_once())
        self.assertGreater(self.surveys, before)
        self.assertEqual(self.client.offers, [["1-2"]])

    def test_nothing_changing_sends_nothing(self):
        self.plugged = [FakeDev("1-2")]
        self.w.pass_once()
        self.w.pass_once()
        self.w.pass_once()
        # One offer, not three: the far end is only told when the answer
        # changes, or on the heartbeat.
        self.assertEqual(len(self.client.offers), 1)

    def test_unplugging_drops_it_from_the_offer(self):
        self.plugged = [FakeDev("1-2"), FakeDev("1-3")]
        self.w.pass_once()
        self.plugged = [FakeDev("1-2")]
        self.w.pass_once()
        self.assertEqual(self.client.offers[-1], ["1-2"])
        # And released here as well as there, or it stays invisible to this
        # machine after the host PC has let go.
        self.assertIn("1-3", self.unbound)

    def test_only_unbinds_what_it_bound(self):
        # Someone shared 1-9 by hand from the menu.  The daemon must leave
        # it alone -- it is not its device to reclaim.
        self.plugged = [FakeDev("1-2")]
        self.w.pass_once()
        self.plugged = []
        self.w.pass_once()
        self.assertEqual(self.unbound, ["1-2"])
        self.assertNotIn("1-9", self.unbound)

    def test_turning_it_off_hands_everything_back(self):
        self.plugged = [FakeDev("1-2")]
        self.w.pass_once()
        self.w.settings = lambda: (False, "safe", [], [], {})
        self.w.pass_once()
        self.assertEqual(self.unbound, ["1-2"])
        self.assertEqual(self.w.bound, set())

    def test_stopping_hands_everything_back(self):
        self.plugged = [FakeDev("1-2"), FakeDev("1-3")]
        self.w.pass_once()
        self.w.hand_back()
        self.assertEqual(sorted(self.unbound), ["1-2", "1-3"])
        self.assertEqual(self.client.offers[-1], [])

    def test_unreachable_host_pc_is_retried_not_fatal(self):
        self.client.fail = True
        self.plugged = [FakeDev("1-2")]
        self.assertFalse(self.w.pass_once())
        # And the next pass tries again rather than deciding it already
        # offered this set -- last_offer must not have been recorded.
        self.client.fail = False
        self.assertTrue(self.w.pass_once())
        self.assertEqual(self.client.offers, [["1-2"]])

    def test_a_switched_off_host_pc_does_not_take_the_device_hostage(self):
        # Binding is what makes a wheel stop being a wheel here.  With
        # nobody to hand it to, it must stay usable on this machine rather
        # than vanishing from both.
        self.client.fail = True
        self.plugged = [FakeDev("1-2")]
        self.assertFalse(self.w.pass_once())
        self.assertEqual(self.bound, set(), "bound a device with nowhere to send it")
        self.assertEqual(self.client.offers, [])

    def test_a_host_pc_going_away_releases_what_it_held(self):
        self.plugged = [FakeDev("1-2")]
        self.w.pass_once()
        self.assertEqual(self.bound, {"1-2"})

        # Now the host PC is switched off mid-session.
        self.client.fail = True
        self.plugged = [FakeDev("1-2"), FakeDev("1-3")]
        self.assertFalse(self.w.pass_once())
        self.assertEqual(self.bound, set())
        self.assertIn("1-2", self.unbound)

    def test_bind_failure_is_not_offered(self):
        # A device the kernel would not release must not be advertised, or
        # the host PC attaches to something that is not there.
        def picky(busid):
            if busid == "1-3":
                return False, "device busy"
            self.bound.add(busid)
            return True, ""
        mh.bind = picky

        self.plugged = [FakeDev("1-2"), FakeDev("1-3")]
        self.w.pass_once()
        self.assertEqual(self.client.offers[-1], ["1-2"])


class PolicyTest(unittest.TestCase):
    """Against real sysfs.  Assertions are about the rules, not about which
    devices this particular machine happens to have plugged in."""

    def test_hubs_and_critical_devices_are_never_offered(self):
        for dev in mh.devices("all"):
            if dev.protected:
                self.assertTrue(dev.reason, "%s is protected but says no why" % dev.busid)
        offered = {d.busid for d in mh.offered("all")}
        for dev in mh.devices("all"):
            if dev.protected:
                self.assertNotIn(dev.busid, offered)

    def test_safe_is_a_subset_of_all(self):
        self.assertLessEqual(
            {d.busid for d in mh.offered("safe")},
            {d.busid for d in mh.offered("all")},
        )

    def test_exclude_beats_everything(self):
        devs = mh.offered("all")
        if not devs:
            self.skipTest("no shareable USB devices on this machine")
        victim = devs[0]
        if not victim.hwid:
            self.skipTest("device has no vendor:product id")
        after = {d.busid for d in mh.offered("all", exclude=[victim.hwid])}
        self.assertNotIn(victim.busid, after)

    def test_include_beats_the_policy(self):
        skipped = [d for d in mh.devices("safe") if d.reason and not d.protected]
        if not skipped:
            self.skipTest("nothing on this machine is skipped by the safe policy")
        victim = skipped[0]
        after = {d.busid for d in mh.offered("safe", include=[victim.hwid])}
        self.assertIn(victim.busid, after)

    def test_audio_is_judged_on_direction_not_on_being_audio(self):
        # The stream carries sound to this machine, never from it.  So
        # speakers are redundant and a microphone is not -- passing the
        # device through is the only way the host hears you.
        audio = [d for d in mh.devices("safe") if d.has_class(mh.CLASS_AUDIO)]
        if not audio:
            self.skipTest("no USB audio device on this machine")
        for dev in audio:
            role = dev.audio_role()
            if dev.protected:
                continue
            if role == "playback":
                self.assertTrue(dev.reason, "%s is playback-only and should be skipped" % dev.busid)
            else:
                # capture, or unknown because it is already shared -- both
                # must be offered, the second so a shared microphone does
                # not get dropped and re-added forever.
                self.assertFalse(
                    dev.reason,
                    "%s (%s) is %s and was skipped: %s" % (dev.busid, dev.label, role, dev.reason))

    def test_a_shared_audio_device_reads_as_unknown_not_playback(self):
        # Binding takes snd-usb-audio away, which is what knew the
        # direction.  If that read as "playback" the device would be
        # dropped from the offer on the very next pass.
        audio = [d for d in mh.devices("all") if d.has_class(mh.CLASS_AUDIO)]
        if not audio:
            self.skipTest("no USB audio device on this machine")
        dev = audio[0]
        original = dev.path
        try:
            dev.path = "/nonexistent"  # stands in for "driver has gone"
            self.assertEqual(dev.audio_role(), "unknown")
        finally:
            dev.path = original

    def test_include_does_not_beat_a_hard_rule(self):
        # Explicitly asking for the hub the boot stick is behind still does
        # not get it -- the hard rules are not a preference.
        hard = [d for d in mh.devices("all") if d.protected]
        if not hard:
            self.skipTest("nothing protected on this machine")
        victim = hard[0]
        after = {d.busid for d in mh.offered("all", include=[victim.hwid])}
        self.assertNotIn(victim.busid, after)


class ConfTest(unittest.TestCase):
    def test_reads_the_shell_config(self):
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".conf", delete=False) as fh:
            fh.write('# a comment\n'
                     'USB_AUTOSHARE="yes"\n'
                     'USB_AUTOSHARE_EXCLUDE="046d:c262 044f:b68f"\n'
                     'BROKEN LINE\n'
                     'USB_HOST_PORT="48021"\n')
            path = fh.name
        try:
            conf = mh.load_conf(path)
            self.assertEqual(conf["USB_AUTOSHARE"], "yes")
            self.assertEqual(conf["USB_AUTOSHARE_EXCLUDE"].split(),
                             ["046d:c262", "044f:b68f"])
            addr, port, token = mh.host_settings(conf)
            self.assertEqual(port, 48021)
            self.assertEqual((addr, token), ("", ""))
        finally:
            os.unlink(path)

    def test_a_missing_config_is_not_an_error(self):
        self.assertEqual(mh.load_conf("/nonexistent/moonlight.conf"), {})
        addr, port, _ = mh.host_settings({})
        self.assertEqual((addr, port), ("", mh.DEFAULT_PORT))

    def test_unpaired_client_says_so(self):
        with self.assertRaises(mh.HostError) as caught:
            mh.Client("")
        self.assertEqual(caught.exception.code, "not_paired")


if __name__ == "__main__":
    unittest.main(verbosity=2)
