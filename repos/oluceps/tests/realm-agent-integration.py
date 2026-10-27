#!/usr/bin/env python3
"""Run on an authorized remote test host, never on the developer's network.

The runner creates transient PrivateNetwork systemd units and attaches BPF
only after the fixture's readiness gate. Pass the static agent binary as argv[1].
"""
import argparse
import concurrent.futures
import json
import os
import signal
from pathlib import Path
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import time
import urllib.request
from realm_agent_controller import TestController


def question(name, ident=123):
    return struct.pack("!6H", ident, 0x100, 1, 0, 0, 0) + b"".join(
        bytes([len(label)]) + label.encode() for label in name.split(".")
    ) + b"\0\0\1\0\1"


def exact(sock, count):
    out = b""
    while len(out) < count:
        part = sock.recv(count - len(out))
        if not part:
            raise AssertionError("unexpected EOF")
        out += part
    return out


def fixture(control, internet, lifecycle=None):
    with socket.socket(socket.AF_UNIX) as gate:
        gate.settimeout(25)
        gate.connect(control)
        reply = gate.recv(4096)
        assert reply == b"READY\n", reply
    results = []
    for family, server in [(socket.AF_INET, "1.1.1.1"),
                           (socket.AF_INET6, "2001:4860:4860::8888")]:
        with socket.socket(family, socket.SOCK_DGRAM) as dns:
            dns.settimeout(5)
            dns.sendto(question("s3.nyaw.xyz"), (server, 53))
            reply, source = dns.recvfrom(4096)
            assert source[:2] == (server, 53), source
            assert reply[-4:] == socket.inet_aton("127.0.0.1"), reply.hex()
            dns.connect((server, 53))
            assert dns.getpeername()[:2] == (server, 53), dns.getpeername()
            dns.send(question("s3.nyaw.xyz", 124))
            assert dns.recv(4096)[-4:] == socket.inet_aton("127.0.0.1")
        results.append(f"DNS {family}: connected and unconnected UDP, peer restored")

    # Reuse one UDP socket concurrently across all eight supported resolver
    # peers. The returned source must match each transaction's original server.
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as dns:
        dns.settimeout(5)
        servers = [f"192.0.2.{n}" for n in range(1, 9)]
        for ident, server in enumerate(servers):
            dns.sendto(question("s3.nyaw.xyz", ident), (server, 53))
        seen = set()
        for _ in servers:
            reply, source = dns.recvfrom(4096)
            ident = struct.unpack("!H", reply[:2])[0]
            assert source == (servers[ident], 53), (ident, source)
            seen.add(ident)
        assert len(seen) == 8
        try:
            dns.sendto(question("s3.nyaw.xyz"), ("192.0.2.99", 53))
        except PermissionError:
            pass
        else:
            raise AssertionError("ninth DNS peer was not rejected")
    results.append("concurrent DNS peers: correct sources, bounded state rejects overflow")

    for family, server in [(socket.AF_INET, "1.1.1.1"),
                           (socket.AF_INET6, "2001:4860:4860::8888")]:
        with socket.socket(family) as dns:
            dns.settimeout(5)
            dns.connect((server, 53))
            assert dns.getpeername()[:2] == (server, 53)
            raw = question("s3.nyaw.xyz")
            dns.sendall(struct.pack("!H", len(raw)) + raw)
            count = struct.unpack("!H", exact(dns, 2))[0]
            assert exact(dns, count)[-4:] == socket.inet_aton("127.0.0.1")
    results.append("TCP DNS IPv4/IPv6: original destination recovered")

    def echo(index):
        family, server = (socket.AF_INET, "203.0.113.7") if index % 2 == 0 else (
            socket.AF_INET6, "2001:db8::7")
        with socket.socket(family) as client:
            client.settimeout(5)
            client.connect((server, 4443))
            assert client.getpeername()[:2] == (server, 4443)
            payload = f"unique-payload-{index}".encode()
            client.sendall(payload)
            client.shutdown(socket.SHUT_WR)
            assert exact(client, len(payload)) == payload
            assert client.recv(1) == b""
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
        list(pool.map(echo, range(128)))
    results.append("128 concurrent TCP forwards: original targets and half-close")

    with socket.socket() as denied:
        denied.settimeout(3)
        denied.connect(("169.254.169.254", 80))
        try:
            denied.sendall(b"GET / HTTP/1.0\r\n\r\n")
            assert denied.recv(1) == b""
        except ConnectionResetError:
            pass
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as denied:
        try:
            denied.sendto(b"unsupported UDP", ("1.1.1.1", 443))
        except PermissionError:
            pass
        else:
            raise AssertionError("external UDP was not rejected")
    results.append("undeclared private TCP and unsupported UDP rejected")

    if internet:
        for key in list(os.environ):
            if key.lower().endswith("proxy"):
                os.environ.pop(key)
        with urllib.request.urlopen("https://example.com/", timeout=20) as response:
            assert response.status == 200
        results.append("HTTPS + DNS over existing SPIFFE egress, no proxy environment")
    print(json.dumps(results, ensure_ascii=False), flush=True)
    if lifecycle:
        with socket.socket(socket.AF_UNIX) as channel:
            channel.connect(lifecycle)
            channel.sendall(b"READY\n")
            commands = channel.makefile("rb")
            for command in commands:
                if command == b"STOP\n":
                    break
                if command == b"PROBE\n":
                    try:
                        echo(1000)
                        channel.sendall(b"OK\n")
                    except OSError:
                        channel.sendall(b"UNAVAILABLE\n")
                elif command == b"DENIED\n":
                    with socket.socket() as probe:
                        probe.settimeout(2)
                        try:
                            probe.connect(("203.0.113.7", 4443))
                        except OSError:
                            channel.sendall(b"DENIED\n")
                        else:
                            channel.sendall(b"ESCAPED\n")


def run_fixture(agent, directory, internet, lifecycle, user, group):
    unit = "realm-agent-integration-fixture"
    script = str(Path(__file__).resolve())
    return subprocess.Popen([
        "systemd-run", "--quiet", "--wait", "--pipe", "--collect",
        f"--unit={unit}", "--property=PrivateNetwork=yes",
        "--property=NoNewPrivileges=yes", "--property=CapabilityBoundingSet=",
        "--property=RuntimeMaxSec=90", f"--uid={user}", f"--gid={group}",
        sys.executable, script, "fixture", str(directory / "control.sock"), str(int(internet)),
        lifecycle,
    ])


def runner(agent, internet, user, group, worker_user, internet_socket):
    if os.geteuid() != 0:
        raise SystemExit("remote integration runner requires root")
    with tempfile.TemporaryDirectory(prefix="realm-agent-test-") as temp:
        directory = Path(temp)
        os.chmod(directory, 0o755)
        echo = socket.socket(socket.AF_UNIX)
        echo.bind(str(directory / "echo.sock"))
        os.chmod(directory / "echo.sock", 0o666)
        echo.listen(128)

        def accept():
            while True:
                try:
                    client, _ = echo.accept()
                except OSError:
                    return
                def serve(client):
                    with client:
                        while chunk := client.recv(4096):
                            client.sendall(chunk)
                        client.shutdown(socket.SHUT_WR)
                threading.Thread(target=serve, args=(client,), daemon=True).start()
        threading.Thread(target=accept, daemon=True).start()
        config = {"workloads": [{
            "name": "fixture", "user": user, "group": group, "workerUser": worker_user,
            "unit": "realm-agent-integration-fixture.service",
            "socket": str(directory / "control.sock"),
            "dnsHosts": {"s3.nyaw.xyz": ["127.0.0.1"]},
            "routes": [{"prefix": prefix, "port": 4443, "socket": str(directory / "echo.sock")}
                       for prefix in ["203.0.113.7/32", "2001:db8::7/128"]],
            "internetSocket": internet_socket if internet else "",
            "internetPorts": [443] if internet else [],
        }]}
        path = directory / "config.json"
        path.write_text(json.dumps(config))
        controller = TestController(agent, path)
        child = None
        lifecycle = socket.socket(socket.AF_UNIX)
        lifecycle.bind(str(directory / "lifecycle.sock"))
        os.chmod(directory / "lifecycle.sock", 0o666)
        lifecycle.listen(1)
        lifecycle.settimeout(.2)
        try:
            for _ in range(100):
                if (directory / "control.sock").exists():
                    break
                if controller.poll() is not None:
                    raise RuntimeError("agent exited before readiness")
                time.sleep(.05)
            refused = subprocess.run([
                "systemd-run", "--quiet", "--wait", "--pipe", "--collect",
                "--unit=realm-agent-integration-impostor", "--property=PrivateNetwork=yes",
                "--property=NoNewPrivileges=yes", "--property=CapabilityBoundingSet=",
                f"--uid={user}", f"--gid={group}", agent, "gate",
                "--socket", str(directory / "control.sock"),
            ], capture_output=True, text=True, timeout=30)
            assert refused.returncode != 0 and "does not belong to system unit" in refused.stderr, refused
            print("same UID, different unit: gate refused", flush=True)
            child = run_fixture(agent, directory, internet, str(directory / "lifecycle.sock"), user, group)
            deadline = time.monotonic() + 90
            while True:
                try:
                    channel, _ = lifecycle.accept()
                    break
                except socket.timeout:
                    if child.poll() is not None:
                        raise RuntimeError(f"fixture exited before readiness: {child.returncode}")
                    if time.monotonic() >= deadline:
                        raise TimeoutError("fixture readiness timed out")
            channel.settimeout(10)
            replies = channel.makefile("rb")
            assert replies.readline() == b"READY\n"

            def command(value):
                channel.sendall(value + b"\n")
                return replies.readline()

            def wait_for_recovery():
                for _ in range(50):
                    if command(b"PROBE") == b"OK\n":
                        return
                    time.sleep(.1)
                raise AssertionError("worker did not recover")

            worker_pids = subprocess.check_output(
                ["ps", "--ppid", str(controller.pid), "-o", "pid="], text=True
            ).split()
            assert len(worker_pids) == 1, worker_pids
            os.kill(int(worker_pids[0]), signal.SIGKILL)
            wait_for_recovery()
            print("worker crash: recovered without another application gate", flush=True)

            controller.terminate()
            controller.wait(timeout=10)
            assert command(b"DENIED") == b"DENIED\n", "direct route escaped after controller exit"
            controller = TestController(agent, path)
            wait_for_recovery()
            print("agent restart: recovered existing cgroup; no direct route while stopped", flush=True)
            channel.sendall(b"STOP\n")
            channel.close()
            assert child.wait(timeout=10) == 0
        finally:
            controller.terminate()
            try:
                controller.wait(timeout=10)
            except subprocess.TimeoutExpired:
                controller.kill()
                controller.wait()
            echo.close()
            lifecycle.close()
            if child is not None and child.poll() is None:
                subprocess.run(["systemctl", "stop", "realm-agent-integration-fixture.service"], check=False)
                child.wait(timeout=10)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "fixture":
        fixture(sys.argv[2], bool(int(sys.argv[3])), sys.argv[4] if len(sys.argv) > 4 else None)
    else:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("agent")
        parser.add_argument("--internet", action="store_true")
        parser.add_argument("--user", default="misskey")
        parser.add_argument("--group")
        parser.add_argument("--worker-user", default="nobody")
        parser.add_argument("--internet-socket")
        args = parser.parse_args()
        runner(str(Path(args.agent).resolve()), args.internet, args.user,
               args.group or args.user, args.worker_user,
               args.internet_socket or f"/run/realm/{args.user}/egress/internet.sock")
