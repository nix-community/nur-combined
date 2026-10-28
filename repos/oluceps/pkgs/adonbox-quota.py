"""Enforce the adonbox monthly transfer quota with systemd IP accounting."""

import datetime
import json
import os
from pathlib import Path
import socket
import subprocess
import time

UNIT = "podman-adonbox.service"
LIMIT = 100_000_000_000
INTERVAL = 5
UNAVAILABLE = (1 << 64) - 1


def systemctl(*args):
    return subprocess.check_output(["systemctl", *args], text=True).strip()


def parse_counter(raw_value):
    if raw_value in ("", "[no data]"):
        return 0
    value = int(raw_value)
    if value < 0 or value >= UNAVAILABLE:
        raise RuntimeError(f"Invalid IP counter value: {raw_value}")
    return value


def snapshot():
    raw = systemctl(
        "show", UNIT,
        "--property=InvocationID,IPIngressBytes,IPEgressBytes,ActiveState",
    )
    values = dict(line.split("=", 1) for line in raw.splitlines())
    return {
        "invocation": values.get("InvocationID", ""),
        "ingress": parse_counter(values.get("IPIngressBytes", "")),
        "egress": parse_counter(values.get("IPEgressBytes", "")),
        "active": values.get("ActiveState", "inactive"),
    }


def account(previous, current, month):
    """Count each snapshot once, including counters from a new invocation."""
    used = previous["used_bytes"] if previous and previous["month"] == month else 0
    same = previous and previous["invocation"] == current["invocation"]
    for direction in ("ingress", "egress"):
        value = current[direction]
        old = previous[direction] if same else 0
        # Counters can reset when systemd recreates its accounting programs.
        used += value - old if value >= old else value
    return {
        "month": month,
        "used_bytes": used,
        "invocation": current["invocation"],
        "ingress": current["ingress"],
        "egress": current["egress"],
    }


def load(path):
    if not path.exists():
        return None
    value = json.loads(path.read_text())
    datetime.datetime.strptime(value["month"], "%Y-%m")
    if not isinstance(value["invocation"], str):
        raise ValueError("Invalid quota invocation")
    for key in ("used_bytes", "ingress", "egress"):
        if type(value[key]) is not int or value[key] < 0:
            raise ValueError("Invalid quota byte count")
    return value


def save(path, state):
    temporary = path.with_suffix(".tmp")
    with temporary.open("w") as handle:
        json.dump(state, handle)
        handle.write("\n")
        handle.flush()
        os.fsync(handle.fileno())
    temporary.replace(path)
    descriptor = os.open(path.parent, os.O_DIRECTORY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def ready():
    address = os.environ["NOTIFY_SOCKET"]
    if address.startswith("@"):
        address = "\0" + address[1:]
    with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as channel:
        channel.connect(address)
        channel.sendall(b"READY=1")


def main():
    directory = Path(os.environ["STATE_DIRECTORY"])
    path = directory / "usage.json"
    blocked = directory / "exhausted"
    announced = False
    try:
        state = load(path)
        while True:
            was_blocked = blocked.exists()
            current = snapshot()
            month = datetime.datetime.now().strftime("%Y-%m")
            state = account(state, current, month)
            save(path, state)
            exhausted = state["used_bytes"] >= LIMIT
            if exhausted:
                blocked.touch(exist_ok=True)
                if current["active"] not in ("inactive", "failed"):
                    print(f"adonbox quota exhausted: {state['used_bytes']} bytes", flush=True)
                    # Do not wait for the unit that is waiting for our readiness.
                    systemctl("stop", "--no-block", UNIT)
            else:
                blocked.unlink(missing_ok=True)
            if not announced:
                ready()
            if not exhausted and (was_blocked or not announced):
                systemctl("start", "--no-block", UNIT)
            announced = True
            time.sleep(INTERVAL)
    except Exception:
        # A broken state file or unavailable accounting must not open the quota.
        blocked.touch(exist_ok=True)
        systemctl("stop", "--no-block", UNIT)
        raise


if __name__ == "__main__":
    main()
