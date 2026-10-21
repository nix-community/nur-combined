import argparse
import json
import socketserver
import threading
import time
import uuid

PROTOCOLS = (
    "c:ping",
    "c:protocols",
    "c:server_port",
    "c:player_ping",
    "c:player_profiles_list",
)


def read_exact(sock, size):
    data = bytearray()
    while len(data) < size:
        chunk = sock.recv(size - len(data))
        if not chunk:
            raise EOFError()
        data.extend(chunk)
    return bytes(data)


class Handler(socketserver.BaseRequestHandler):
    def handle(self):
        self.request.settimeout(64)
        try:
            while True:
                size = read_exact(self.request, 1)[0]
                if size > 128:
                    return
                kind = read_exact(self.request, size).decode("ascii")
                length = int.from_bytes(read_exact(self.request, 4), "big")
                if length > 65536:
                    return
                payload = read_exact(self.request, length)
                status, response = self.dispatch(kind, payload)
                self.request.sendall(
                    bytes([status]) + len(response).to_bytes(4, "big") + response
                )
        except (OSError, EOFError, ValueError, UnicodeError):
            return

    def dispatch(self, kind, payload):
        server = self.server
        if kind == "c:ping":
            return 0, payload
        if kind == "c:protocols":
            return 0, "\0".join(PROTOCOLS).encode("ascii")
        if kind == "c:server_port":
            return 0, server.minecraft_port.to_bytes(2, "big")
        if kind == "c:player_ping":
            try:
                profile = json.loads(payload)
                machine_id = profile["machine_id"]
                name = profile["name"]
                vendor = profile["vendor"]
                if not all(
                    isinstance(value, str) and 0 < len(value) <= 256
                    for value in (machine_id, name, vendor)
                ):
                    raise ValueError("Invalid profile")
                with server.lock:
                    if machine_id != server.host["machine_id"]:
                        server.guests[machine_id] = (
                            time.monotonic(),
                            dict(
                                machine_id=machine_id,
                                name=name,
                                vendor=vendor,
                                kind="GUEST",
                            ),
                        )
                return 0, b""
            except (ValueError, KeyError, TypeError):
                return 255, b"Invalid profile"
        if kind == "c:player_profiles_list":
            with server.lock:
                now = time.monotonic()
                server.guests = {
                    key: value
                    for key, value in server.guests.items()
                    if now - value[0] < 15
                }
                profiles = [server.host] + [value[1] for value in server.guests.values()]
            return 0, json.dumps(profiles, separators=(",", ":")).encode("utf-8")
        return 255, b"Requested protocol hasn't been implemented."


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True
    request_queue_size = 128

    def __init__(self, port, minecraft_port):
        super().__init__(("0.0.0.0", port), Handler)
        self.minecraft_port = minecraft_port
        self.lock = threading.Lock()
        self.guests = {}
        self.host = dict(
            machine_id=uuid.uuid4().hex,
            name="Dedicated Minecraft Server",
            vendor="Terracotta headless / NixOS",
            kind="HOST",
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Terracotta headless scaffolding server")
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--minecraft-port", type=int, required=True)
    args = parser.parse_args()
    with Server(args.port, args.minecraft_port) as server:
        server.serve_forever(poll_interval=0.25)
