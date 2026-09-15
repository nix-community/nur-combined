"""Print why a running QEMU shut down, as reported over QMP.

QEMU exits with status 0 whether the guest rebooted or powered off, so the exit
status cannot tell the two apart. The QMP SHUTDOWN event can — but only while
QEMU is still alive, so this is meant to be run alongside it (see
modules/qemu-vm.nix).

Prints the event's `reason` ("guest-reset" for a reboot, "guest-shutdown" for a
poweroff, "host-signal" when QEMU was killed, ...). Prints nothing if QEMU went
away without reporting one, or was already gone.
"""

from scriptipy import *

from qemu.qmp import QMPError
from qemu.qmp.legacy import QEMUMonitorProtocol

# QEMU creates its QMP socket asynchronously; how long to wait for it to show up.
CONNECT_TIMEOUT = 30.0
# While waiting for the shutdown event, how often to check QEMU is still there
# at all: one that is killed outright never sends an event, and the QMP library
# would otherwise wait on its queue forever.
POLL_INTERVAL = 1.0


def alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    return True


def connect(path: str, pid: int | None) -> QEMUMonitorProtocol | None:
    """Wait for the QMP socket to appear, then connect and negotiate."""
    deadline = time.monotonic() + CONNECT_TIMEOUT
    while True:
        qmp = QEMUMonitorProtocol(path)
        try:
            qmp.connect()
            return qmp
        except (QMPError, OSError):
            if pid is not None and not alive(pid):
                return None
            if time.monotonic() >= deadline:
                return None
            time.sleep(0.1)


def shutdown_reason(qmp: QEMUMonitorProtocol, pid: int | None) -> str | None:
    while True:
        try:
            event = qmp.pull_event(wait=POLL_INTERVAL)
        except TimeoutError:
            event = None
        if event is not None and event["event"] == "SHUTDOWN":
            return event.get("data", {}).get("reason", "")
        if pid is not None and not alive(pid):
            # Gone without a word: killed, or it crashed.
            return None


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("socket", help="path to QEMU's QMP unix socket")
parser.add_argument(
    "pid",
    type=int,
    nargs="?",
    help="QEMU's pid, to give up early on a QEMU that is already gone",
)
args = parser.parse_args()

qmp = connect(args.socket, args.pid)
if qmp is not None:
    try:
        reason = shutdown_reason(qmp, args.pid)
        if reason is not None:
            print(reason)
    finally:
        try:
            qmp.close()
        except Exception:
            # QEMU drops the connection the moment it goes down, and closing
            # re-raises whatever the reader hit (EOFError, typically). We
            # already have our answer; this is just teardown.
            pass
