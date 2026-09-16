"""A minimal HTTP remote storage server for the ccache storage helper.

Implements just enough of what the helper speaks -- GET, PUT, HEAD and DELETE of
opaque blobs under an arbitrary path -- and records every request, so the test
can assert that traffic really reached it and that it was authenticated.

Usage: storage-server.py ROOT LOG PORT USER PASSWORD

HTTP Basic authentication is mandatory, which is what makes the netrc part of
the test meaningful: if the helper failed to pick up the credentials, every
request would be rejected rather than silently succeeding.
"""

import base64
import http.server
import os
import pathlib
import sys
import threading

ROOT = pathlib.Path(sys.argv[1])
LOG = pathlib.Path(sys.argv[2])
PORT = int(sys.argv[3])
CREDENTIALS = (sys.argv[4], sys.argv[5])

LOCK = threading.Lock()


def record(method: str, path: str, status: int, user: str) -> None:
    with LOCK:
        with LOG.open("a") as f:
            f.write(f"{method} {path} {status} user={user}\n")


class Handler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def authenticated_user(self) -> str | None:
        header = self.headers.get("Authorization", "")
        scheme, _, payload = header.partition(" ")
        if scheme.lower() != "basic":
            return None
        try:
            user, _, password = base64.b64decode(payload).decode().partition(":")
        except Exception:
            return None
        if (user, password) != CREDENTIALS:
            return None
        return user

    def target(self) -> pathlib.Path | None:
        # Refuse to escape the storage root.
        rel = os.path.normpath(self.path.lstrip("/"))
        if rel.startswith(".."):
            return None
        return ROOT / rel

    def respond(
        self,
        status: int,
        body: bytes = b"",
        user: str = "-",
        length: int | None = None,
    ) -> None:
        record(self.command, self.path, status, user)
        self.send_response(status)
        if status == 401:
            self.send_header("WWW-Authenticate", 'Basic realm="ccache"')
        self.send_header("Content-Length", str(len(body) if length is None else length))
        self.end_headers()
        if body:
            self.wfile.write(body)

    def handle_request(self) -> None:
        user = self.authenticated_user()
        if user is None:
            self.respond(401)
            return

        target = self.target()
        if target is None:
            self.respond(403, user=user)
            return

        if self.command in ("GET", "HEAD"):
            if not target.is_file():
                self.respond(404, user=user)
                return
            # A HEAD still has to report the blob's real size, which `respond`
            # cannot derive from the empty body it sends.
            body = target.read_bytes() if self.command == "GET" else b""
            self.respond(200, body, user=user, length=target.stat().st_size)
        elif self.command == "PUT":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(body)
            self.respond(201, user=user)
        elif self.command == "DELETE":
            if not target.is_file():
                self.respond(404, user=user)
                return
            target.unlink()
            self.respond(204, user=user)
        else:
            self.respond(405, user=user)

    do_GET = do_HEAD = do_PUT = do_DELETE = handle_request

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("storage-server: " + (fmt % args) + "\n")


ROOT.mkdir(parents=True, exist_ok=True)
LOG.touch()
# Binds all interfaces: the client node reaches this over the test network.
http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
