"""Talking to mlos-host-utils on the host PC, and deciding which
of the USB devices plugged in here are safe to hand over.

Everything else in Moonlight OS is POSIX sh, and this is not, for one reason:
the wire format is line-delimited JSON over TCP.  Doing that in sh means nc
plus a JSON parser written in sed, and the failure mode of that is a wheel
that silently stops working.  Python 3 is already in the image, this uses
nothing outside its standard library, and the shell scripts drive it through
moonlight-hostagent.

Two independent halves live here:

  * the protocol client -- Client, and the config it reads
  * the local device survey -- devices(), and the policy that decides which
    of them get offered

The host PC's operating system appears nowhere in either.  That is the
whole point: Moonlight OS says what is plugged in, the agent at the other end
knows what to do about it.
"""

import json
import os
import re
import socket
import subprocess

# Same name the shell half uses, and overridable for the same reason: so a
# test can point at a config that is not the running machine's.
CONF = os.environ.get("MLOS_CONF", "/etc/moonlight-os/moonlight-os.conf")
DEFAULT_PORT = 48020

# ---------------------------------------------------------------- config


def load_conf(path=CONF):
    """Read the shell config as a dict.  Not a shell parser -- the file is
    written by mlos_set, which emits exactly KEY="value" and nothing else."""
    conf = {}
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, _, val = line.partition("=")
                key = key.strip()
                if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", key):
                    continue
                val = val.strip()
                if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'":
                    val = val[1:-1]
                conf[key] = val
    except OSError:
        pass
    return conf


def host_settings(conf=None):
    conf = load_conf() if conf is None else conf
    port = conf.get("USB_HOST_PORT", "").strip()
    try:
        port = int(port) if port else DEFAULT_PORT
    except ValueError:
        port = DEFAULT_PORT
    return conf.get("USB_HOST_ADDR", "").strip(), port, conf.get("USB_HOST_TOKEN", "").strip()


# ---------------------------------------------------------------- protocol


class HostError(Exception):
    """A refusal from the agent, carrying the machine-readable code so the
    menus can offer the matching fix rather than printing a sentence."""

    def __init__(self, message, code=""):
        super().__init__(message)
        self.code = code


class Client:
    """One connection, reused for as many requests as the caller makes.

    The daemon holds one open across hotplug events; the CLI opens one per
    invocation.  Both work, because the agent keeps no per-connection state
    -- it identifies the peer by address, not by session.
    """

    def __init__(self, addr, port=DEFAULT_PORT, token="", timeout=15.0):
        if not addr:
            raise HostError("no host PC paired yet", "not_paired")
        self.addr, self.port, self.token, self.timeout = addr, port, token, timeout
        self._sock = None
        self._fh = None
        self._n = 0

    def close(self):
        for obj in (self._fh, self._sock):
            try:
                if obj is not None:
                    obj.close()
            except OSError:
                pass
        self._fh = self._sock = None

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    def _connect(self):
        if self._fh is not None:
            return
        try:
            self._sock = socket.create_connection((self.addr, self.port), self.timeout)
        except OSError as exc:
            raise HostError(
                "cannot reach %s on port %d (%s)" % (self.addr, self.port, exc.strerror or exc),
                "unreachable",
            ) from exc
        self._sock.settimeout(self.timeout)
        self._fh = self._sock.makefile("rwb")

    def call(self, op, args=None):
        # One retry, reconnecting: the agent restarts when the host PC
        # reboots, and a daemon that held the old socket would otherwise
        # need restarting too.
        for attempt in (0, 1):
            try:
                self._connect()
                self._n += 1
                req = {
                    "v": 1,
                    "id": str(self._n),
                    "token": self.token,
                    "op": op,
                    "args": args or {},
                }
                self._fh.write((json.dumps(req) + "\n").encode("utf-8"))
                self._fh.flush()
                line = self._fh.readline()
                if not line:
                    raise OSError("the agent closed the connection")
                break
            except (OSError, socket.timeout) as exc:
                self.close()
                if attempt:
                    raise HostError(
                        "lost contact with %s (%s)" % (self.addr, exc), "unreachable"
                    ) from exc

        try:
            resp = json.loads(line.decode("utf-8"))
        except ValueError as exc:
            raise HostError("the agent sent something that is not JSON", "bad_response") from exc

        if not resp.get("ok"):
            raise HostError(resp.get("error") or "the agent refused", resp.get("code", ""))
        return resp.get("data") or {}

    # Convenience wrappers, one per op.
    def ping(self):
        return self.call("ping")

    def install(self):
        return self.call("install")

    def sync(self, devs):
        return self.call(
            "sync",
            {"devices": [{"busid": d.busid, "hwid": d.hwid, "label": d.label} for d in devs]},
        )

    def detach_all(self):
        return self.call("detach", {"all": True})

    def list(self):
        return self.call("list")


def client_from_conf(conf=None, timeout=15.0):
    addr, port, token = host_settings(conf)
    return Client(addr, port, token, timeout)


# ---------------------------------------------------------------- devices

SYS_USB = "/sys/bus/usb/devices"
BUSID_RE = re.compile(r"^\d+-\d+(\.\d+)*$")

# Interface classes, from the USB spec.  Only the ones policy cares about.
CLASS_AUDIO = 0x01
CLASS_HID = 0x03
CLASS_STORAGE = 0x08
CLASS_HUB = 0x09
CLASS_VIDEO = 0x0E
CLASS_WIRELESS = 0xE0  # Bluetooth adapters live here


class Dev:
    def __init__(self, busid):
        self.busid = busid
        self.path = os.path.join(SYS_USB, busid)
        self.vendor = _read(self.path, "idVendor")
        self.product_id = _read(self.path, "idProduct")
        self.manufacturer = _read(self.path, "manufacturer")
        self.product = _read(self.path, "product")
        self.serial = _read(self.path, "serial")
        self.dev_class = _read_int(self.path, "bDeviceClass")
        self.interfaces = _interfaces(self.path, busid)
        self.reason = ""       # why it is not offered, when it is not
        self.protected = False  # hard rule: never offered, whatever the policy

    @property
    def hwid(self):
        return "%s:%s" % (self.vendor, self.product_id) if self.vendor else ""

    @property
    def label(self):
        name = " ".join(x for x in (self.manufacturer, self.product) if x).strip()
        return name or self.hwid or self.busid

    def has_class(self, cls):
        return self.dev_class == cls or any(i[0] == cls for i in self.interfaces)

    def is_boot_hid(self):
        """A keyboard or mouse as the BIOS understands one: HID, boot
        subclass, protocol 1 or 2.  A wheel is also HID, and is not this."""
        return any(c == CLASS_HID and sub == 1 and proto in (1, 2)
                   for c, sub, proto in self.interfaces)

    def audio_role(self):
        """"capture", "playback", or "unknown" for an audio device.

        The distinction decides whether the stream is a substitute for the
        device.  For speakers it is: the stream already carries sound to
        this machine.  For a microphone it is not -- Sunshine sends audio
        one way, host to client, and nothing carries a mic back the other
        way.  A microphone is therefore one of the better reasons to pass a
        device through, and the first version of this skipped every audio
        device on the grounds that "the stream already carries sound",
        which was true of half of them.

        The descriptors cannot answer this: an AudioStreaming interface
        parks on altsetting 0, which has no endpoints, so sysfs shows
        nothing to read the direction from.  ALSA has already worked it out
        though -- pcmNc is a capture device, pcmNp a playback one.

        "unknown" when there is no ALSA card, which is the case for a
        device already bound to usbip -- the driver that would have told us
        is exactly the one binding took away.  Callers must treat that as
        "offer it", or a shared microphone would look playback-only on the
        next pass, get dropped, come back, and flap forever.
        """
        kinds = set()
        found = False
        try:
            for entry in os.listdir(self.path):
                if not entry.startswith(self.busid + ":"):
                    continue
                snd = os.path.join(self.path, entry, "sound")
                if not os.path.isdir(snd):
                    continue
                for card in os.listdir(snd):
                    found = True
                    try:
                        for pcm in os.listdir(os.path.join("/proc/asound", card)):
                            if pcm.startswith("pcm") and pcm[-1] in ("c", "p"):
                                kinds.add(pcm[-1])
                    except OSError:
                        pass
        except OSError:
            pass

        if not found:
            return "unknown"
        if "c" in kinds:
            return "capture"
        if "p" in kinds:
            return "playback"
        return "unknown"

    def __repr__(self):
        return "<Dev %s %s %s>" % (self.busid, self.hwid, self.label)


def _read(path, name):
    try:
        with open(os.path.join(path, name), "r", encoding="utf-8", errors="replace") as fh:
            return fh.read().strip()
    except OSError:
        return ""


def _read_int(path, name):
    val = _read(path, name)
    try:
        return int(val, 16)
    except ValueError:
        return -1


def _interfaces(path, busid):
    out = []
    try:
        for entry in sorted(os.listdir(path)):
            if not entry.startswith(busid + ":"):
                continue
            sub = os.path.join(path, entry)
            out.append((
                _read_int(sub, "bInterfaceClass"),
                _read_int(sub, "bInterfaceSubClass"),
                _read_int(sub, "bInterfaceProtocol"),
            ))
    except OSError:
        pass
    return out


def _realpath(p):
    try:
        return os.path.realpath(p)
    except OSError:
        return ""


def _critical_paths():
    """sysfs paths this machine cannot survive losing.

    Two of them, and both are easy to hand over by accident:

    the boot medium -- Moonlight OS usually runs from the USB stick it
    booted off, and passing that to the host PC takes the running system
    with it;

    the network interface carrying the connection -- on a USB Ethernet or
    Wi-Fi dongle, handing it over kills the link, which kills the USB/IP
    session, which strands the device on the other side with no way to ask
    for it back.
    """
    paths = []

    sources = set()
    try:
        with open("/proc/mounts", "r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                parts = line.split()
                if len(parts) < 2 or not parts[0].startswith("/dev/"):
                    continue
                mount = parts[1]
                # The live medium, the root filesystem, and anything the
                # installer might be writing to.
                if mount in ("/", "/run/live/medium", "/usr/lib/live/mount/medium",
                             "/boot", "/boot/efi", "/lib/live/mount/medium"):
                    sources.add(os.path.basename(parts[0]))
    except OSError:
        pass

    for name in sources:
        # sdb1 -> sdb: the USB device owns the whole disk, not the partition.
        disk = re.sub(r"(p?\d+)$", "", name)
        for candidate in (name, disk):
            p = _realpath("/sys/class/block/" + candidate)
            if p:
                paths.append(p)

    for iface in _routed_interfaces():
        p = _realpath("/sys/class/net/" + iface)
        if p:
            paths.append(p)

    return paths


def _routed_interfaces():
    """Interfaces with a default route.  /proc/net/route is IPv4 only, so
    ip(8) covers the rest; either one on its own misses real setups."""
    names = set()
    try:
        with open("/proc/net/route", "r", encoding="utf-8", errors="replace") as fh:
            next(fh, None)
            for line in fh:
                parts = line.split()
                if len(parts) > 1 and parts[1] == "00000000":
                    names.add(parts[0])
    except (OSError, StopIteration):
        pass
    try:
        out = subprocess.run(["ip", "-o", "route", "show", "default"],
                             capture_output=True, text=True, timeout=5)
        for line in out.stdout.splitlines():
            parts = line.split()
            if "dev" in parts:
                names.add(parts[parts.index("dev") + 1])
    except (OSError, subprocess.SubprocessError):
        pass
    return names


def devices(policy="safe", include=(), exclude=()):
    """Every USB device on this machine, each annotated with whether it is
    offered to the host PC and, when it is not, why.

    Nothing is filtered out of the list -- the menu shows all of it, with the
    reasons, because "why is my wheel not being shared" needs an answer on
    screen rather than in a log.

    policy:
      "safe" -- wheels, HOTAS, pedals, dongles, printers, MIDI.  Skips what
                Moonlight already forwards better (keyboards, mice, audio)
                and what USB/IP handles badly (webcams, storage).
      "all"  -- everything except the hard rules below.

    Hard rules, in force under every policy: hubs, the boot medium, and the
    network interface this machine is talking to the host PC over.
    """
    include = {s.lower() for s in include}
    exclude = {s.lower() for s in exclude}
    critical = _critical_paths()

    out = []
    try:
        names = sorted(os.listdir(SYS_USB))
    except OSError:
        return out

    for name in names:
        if not BUSID_RE.match(name):
            continue  # usb1, usb2: root hubs, and the :1.0 interface nodes
        dev = Dev(name)

        real = _realpath(dev.path)
        if real and any(c == real or c.startswith(real + "/") for c in critical):
            dev.protected = True
            dev.reason = "this machine is running from it"
            out.append(dev)
            continue

        if dev.dev_class == CLASS_HUB or dev.has_class(CLASS_HUB):
            dev.protected = True
            dev.reason = "USB hub -- the devices behind it are shared individually"
            out.append(dev)
            continue

        hwid = dev.hwid.lower()
        if hwid and hwid in exclude:
            dev.reason = "on the never-share list"
            out.append(dev)
            continue
        if hwid and hwid in include:
            out.append(dev)  # offered: an explicit include beats the policy
            continue

        if policy != "all":
            if dev.is_boot_hid():
                dev.reason = "keyboard or mouse -- Moonlight forwards it already"
            elif dev.has_class(CLASS_WIRELESS):
                dev.reason = "Bluetooth adapter -- pair it here instead"
            elif dev.has_class(CLASS_AUDIO) and dev.audio_role() == "playback":
                # Only speakers and headphones.  Anything that can record
                # is offered: the stream carries sound to this machine, not
                # from it, so a microphone here is unreachable to the host
                # unless the device itself goes over.
                dev.reason = "speakers or headphones -- the stream already carries sound"
            elif dev.has_class(CLASS_VIDEO):
                dev.reason = "webcam -- USB/IP cannot keep up with video"
            elif dev.has_class(CLASS_STORAGE):
                dev.reason = "storage -- share files over the network instead"

        out.append(dev)

    return out


def offered(policy="safe", include=(), exclude=()):
    """Just the devices to hand over."""
    return [d for d in devices(policy, include, exclude) if not d.reason]


# ---------------------------------------------------------------- usbip


def root_cmd(args):
    """The daemon runs as root; the menus run as the moonlight user, which
    has passwordless sudo.  Both call this."""
    if os.geteuid() != 0:
        return ["sudo", "-n"] + args
    return args


def _usbip(args, timeout=20):
    return subprocess.run(root_cmd(["usbip"] + args),
                          capture_output=True, text=True, timeout=timeout)


def bound_busids():
    """What usbipd is currently exporting.  Asked of the daemon over the
    loopback rather than read out of sysfs, so it is the same answer the
    host PC would get."""
    res = _usbip(["list", "-p", "-r", "127.0.0.1"])
    found = set()
    for line in res.stdout.splitlines():
        m = re.match(r"^\s*([0-9]+-[0-9.]+)\s*:", line)
        if m:
            found.add(m.group(1))
            continue
        m = re.search(r"busid=([0-9]+-[0-9.]+)", line)
        if m:
            found.add(m.group(1))
    return found


def bind(busid):
    res = _usbip(["bind", "-b", busid])
    if res.returncode == 0 or "already bound" in (res.stdout + res.stderr):
        return True, ""
    return False, (res.stderr or res.stdout).strip().splitlines()[0] if (res.stderr or res.stdout) else "usbip bind failed"


def unbind(busid):
    res = _usbip(["unbind", "-b", busid])
    return res.returncode == 0


def ensure_daemon():
    """usbipd exports the devices; without it there is nothing for the
    host PC to attach to."""
    for mod in ("usbip-host", "usbip_host"):
        subprocess.run(root_cmd(["modprobe", mod]),
                       capture_output=True, text=True, check=False)
    res = subprocess.run(["pgrep", "-x", "usbipd"], capture_output=True, text=True)
    if res.returncode == 0:
        return True
    subprocess.run(root_cmd(["systemctl", "start", "usbipd"]),
                   capture_output=True, text=True, check=False)
    res = subprocess.run(["pgrep", "-x", "usbipd"], capture_output=True, text=True)
    return res.returncode == 0
