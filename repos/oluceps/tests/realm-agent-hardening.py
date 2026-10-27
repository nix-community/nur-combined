#!/usr/bin/env python3
"""Bounded synthetic tests on an authorized test host; no production restarts.

Two private-netns dummy workloads test shared-daemon recovery isolation, worker
mounts and resource limits. OOM is deliberately induced only in a dummy worker's
32 MiB leaf cgroup, never against production agents or applications.
"""
import argparse
import json
import os
from pathlib import Path
import signal
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import time


def check(command):
    return subprocess.check_output(command, text=True).strip()


def wait(checker, timeout=25):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            value = checker()
            if value:
                return value
        except (OSError, ValueError, AssertionError):
            pass
        time.sleep(.15)
    raise AssertionError("condition did not become ready")


def dummy(control, channel):
    with socket.socket(socket.AF_UNIX) as gate:
        gate.connect(control)
        assert gate.recv(4096) == b"READY\n"
    occupied = None
    with socket.socket(socket.AF_UNIX) as conn:
        conn.connect(channel)
        conn.sendall(b"READY\n")
        for command in conn.makefile("rb"):
            if command == b"PROBE\n":
                try:
                    with socket.create_connection(("203.0.113.7", 4443), timeout=2) as out:
                        out.settimeout(2)
                        out.sendall(b"dummy-data")
                        assert out.recv(10) == b"dummy-data"
                    conn.sendall(b"OK\n")
                except (OSError, AssertionError):
                    conn.sendall(b"UNAVAILABLE\n")
            elif command == b"OCCUPY\n":
                occupied = socket.socket()
                occupied.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                occupied.bind(("127.0.0.1", 15001))
                occupied.listen(1)
                conn.sendall(b"OCCUPIED\n")
            elif command == b"RELEASE\n":
                occupied.close()
                occupied = None
                conn.sendall(b"RELEASED\n")
            elif command == b"STOP\n":
                return


def runner(agent, user, worker):
    assert os.geteuid() == 0
    prefix = "realm-hardening-test"
    controller = prefix + "-controller.service"
    app_units = [prefix + "-a.service", prefix + "-b.service"]
    units = [controller, *app_units]
    channels = []
    with tempfile.TemporaryDirectory(prefix=prefix + "-") as temp:
        root = Path(temp)
        root.chmod(0o755)
        egress = root / "egress"
        egress.mkdir(mode=0o755)
        echo = socket.socket(socket.AF_UNIX)
        echo.bind(str(egress / "echo.sock"))
        (egress / "echo.sock").chmod(0o666)
        echo.listen(64)
        def accept():
            while True:
                try:
                    conn, _ = echo.accept()
                except OSError:
                    return
                def handle(conn):
                    with conn:
                        while data := conn.recv(1024):
                            conn.sendall(data)
                threading.Thread(target=handle, args=(conn,), daemon=True).start()
        threading.Thread(target=accept, daemon=True).start()
        workloads = []
        listeners = []
        for i, unit in enumerate(app_units):
            directory = root / str(i)
            directory.mkdir(mode=0o755)
            channel = socket.socket(socket.AF_UNIX)
            channel.bind(str(directory / "channel.sock"))
            (directory / "channel.sock").chmod(0o666)
            channel.listen(1)
            channel.settimeout(30)
            listeners.append(channel)
            workloads.append({"name": "dummy-" + str(i), "unit": unit, "user": user,
                              "group": user, "workerUser": worker,
                              "socket": str(directory / "control.sock"),
                              "workerMemoryMiB": 32,
                              "routes": [{"prefix": "203.0.113.7/32", "port": 4443,
                                          "socket": str(egress / "echo.sock")}]})
        config = root / "config.json"
        config.write_text(json.dumps({"workloads": workloads}))
        # A world-readable host sentinel outside the declared egress directory.
        (root / "host-sentinel").write_text("dummy-public-data")
        def start_controller():
            subprocess.run(["systemd-run", "--quiet", "--collect", "--unit=" + controller,
                            "-p", "Type=notify", "-p", "NotifyAccess=main",
                            "-p", "Delegate=cpu memory pids", "-p", "DelegateSubgroup=supervisor",
                            "-p", "OOMPolicy=continue", "-p", "RuntimeMaxSec=240",
                            "-p", "MemoryMax=384M", "-p", "TasksMax=256",
                            "-p", "ProtectSystem=strict", "-p", "ProtectHome=yes",
                            "-p", "ProtectControlGroups=yes", "-p", "ProtectKernelTunables=yes",
                            "-p", "ProtectKernelModules=yes", "-p", "ProtectKernelLogs=yes",
                            "-p", "NoNewPrivileges=yes", "-p", "RestrictNamespaces=net mnt",
                            "-p", "UMask=0077",
                            "-p", "PrivateTmp=yes", "-p", "BindPaths=" + str(root),
                            "-p", "ReadWritePaths=" + str(root) + " /sys/fs/cgroup/system.slice/" + controller,
                            "-p", "CapabilityBoundingSet=CAP_BPF CAP_NET_ADMIN CAP_SYS_ADMIN CAP_SYS_PTRACE CAP_SETUID CAP_SETGID CAP_CHOWN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_FOWNER",
                            agent, "serve", "--config", str(config)], check=True)
            return int(check(["systemctl", "show", controller, "-p", "MainPID", "--value"]))
        def worker_info(i):
            cg = Path("/sys/fs/cgroup" + check(["systemctl", "show", controller, "-p", "ControlGroup", "--value"])) / ("worker-dummy-" + str(i))
            pids = (cg / "cgroup.procs").read_text().split()
            assert len(pids) == 1, pids
            return cg, int(pids[0])
        def command(i, value):
            conn, stream = channels[i]
            conn.sendall(value + b"\n")
            return stream.readline()
        try:
            start_controller()
            for i, unit in enumerate(app_units):
                subprocess.run(["systemd-run", "--quiet", "--collect", "--unit=" + unit,
                                "-p", "PrivateNetwork=yes", "-p", "NoNewPrivileges=yes",
                                "-p", "CapabilityBoundingSet=", "-p", "RestrictNamespaces=yes",
                                "-p", "RuntimeMaxSec=240", "-p", "MemoryMax=64M",
                                "--uid=" + user, "--gid=" + user, sys.executable,
                                str(Path(__file__).resolve()), "dummy", workloads[i]["socket"],
                                str(root / str(i) / "channel.sock")], check=True)
                conn, _ = listeners[i].accept()
                conn.settimeout(5)
                stream = conn.makefile("rb")
                assert stream.readline() == b"READY\n"
                channels.append((conn, stream))
                assert command(i, b"PROBE") == b"OK\n"
            cg_a, pid_a = worker_info(0)
            _, pid_b = worker_info(1)
            mount_root = Path(f"/proc/{pid_a}/root")
            assert (mount_root / "nix/store").is_dir()
            assert (mount_root / "etc/ssl/certs/ca-certificates.crt").is_file()
            assert (mount_root / str(egress).lstrip("/") / "echo.sock").is_socket()
            for hidden in ["proc", "sys", "run/spire", "run/dbus", str(root / "host-sentinel").lstrip("/")]:
                assert not (mount_root / hidden).exists(), hidden
            status = dict(line.split(":", 1) for line in Path(f"/proc/{pid_a}/status").read_text().splitlines() if ":" in line)
            assert int(status["CapEff"], 16) == 0
            assert status["NoNewPrivs"].strip() == "1"
            assert status["Groups"].strip() == ""
            assert (cg_a / "memory.max").read_text().strip() == str(32 * 1024 * 1024)
            assert (cg_a / "memory.swap.max").read_text().strip() == "0"
            assert (cg_a / "pids.max").read_text().strip() == "64"
            assert (cg_a / "cpu.max").read_text().strip() == "100000 100000"
            print("worker mounts, credentials and independent memory/pids/CPU budgets: passed", flush=True)
            subprocess.run(["systemctl", "stop", controller], check=True)
            assert command(0, b"OCCUPY") == b"OCCUPIED\n"
            parent = start_controller()
            wait(lambda: command(1, b"PROBE") == b"OK\n")
            time.sleep(2.5)
            assert int(check(["systemctl", "show", controller, "-p", "MainPID", "--value"])) == parent
            assert command(0, b"PROBE") == b"UNAVAILABLE\n"
            assert command(0, b"RELEASE") == b"RELEASED\n"
            wait(lambda: command(0, b"PROBE") == b"OK\n")
            print("occupied listener on restart: other workload remains usable; release recovers without app restart", flush=True)
            cg_a, pid_a = worker_info(0)
            _, pid_b = worker_info(1)
            # The allocator first joins only this synthetic worker's bounded
            # cgroup. memory.oom.group=1 kills its worker and allocator together.
            killer = subprocess.Popen([sys.executable, str(Path(__file__).resolve()), "allocate", str(cg_a)])
            try:
                assert killer.wait(timeout=10) == -signal.SIGKILL
            finally:
                if killer.poll() is None:
                    killer.kill()
                    killer.wait()
            wait(lambda: command(0, b"PROBE") == b"OK\n")
            assert worker_info(0)[1] != pid_a
            assert worker_info(1)[1] == pid_b
            assert int(check(["systemctl", "show", controller, "-p", "MainPID", "--value"])) == parent
            assert command(1, b"PROBE") == b"OK\n"
            assert int(dict(line.split() for line in (cg_a / "memory.events").read_text().splitlines())["oom_kill"]) >= 1
            print("dummy worker OOM: controller and other worker survive; affected worker recovers", flush=True)
        finally:
            subprocess.run(["systemctl", "stop", *units], check=False)
            for conn, stream in channels:
                stream.close()
                conn.close()
            for listener in listeners:
                listener.close()
            echo.close()


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "dummy":
        dummy(*sys.argv[2:])
    elif len(sys.argv) > 1 and sys.argv[1] == "allocate":
        cg = Path(sys.argv[2])
        assert cg.name == "worker-dummy-0" and cg.parent.name == "realm-hardening-test-controller.service"
        (cg / "cgroup.procs").write_text(str(os.getpid()))
        data = bytearray(48 * 1024 * 1024)
        time.sleep(3)
        raise AssertionError("dummy allocation should exceed its 32 MiB cgroup budget")
    else:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("agent")
        parser.add_argument("--user", default="misskey")
        parser.add_argument("--worker-user", default="nobody")
        args = parser.parse_args()
        runner(str(Path(args.agent).resolve()), args.user, args.worker_user)
