import http.client
import json
import os
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import cast


def request(socket_path: str, path: str) -> tuple[int, bytes]:
    connection = http.client.HTTPConnection("localhost", timeout=30)
    connection.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    _ = connection.sock.settimeout(30)
    try:
        _ = connection.sock.connect(socket_path)
        connection.request("GET", path)
        response = connection.getresponse()
        return response.status, response.read()
    finally:
        connection.close()


def main() -> None:
    package = Path(sys.argv[1])
    with tempfile.TemporaryDirectory(prefix="rsshub-test-") as temporary:
        directory = Path(temporary)
        socket_path = str(directory / "rsshub.sock")
        _ = (directory / ".env").write_text("ACCESS_KEY=packaging-test\n")
        env = {
            "PATH": os.environ["PATH"],
            "HOME": temporary,
            "SOCKET": socket_path,
            "LISTEN_INADDR_ANY": "0",
            "CACHE_TYPE": "memory",
            "ENABLE_CLUSTER": "false",
        }
        with tempfile.TemporaryFile(mode="w+") as logs:
            process = subprocess.Popen(
                [str(package / "bin/rsshub")],
                cwd=directory,
                env=env,
                stdout=logs,
                stderr=subprocess.STDOUT,
            )
            try:
                deadline = time.monotonic() + 120
                while True:
                    if process.poll() is not None:
                        raise RuntimeError("RSSHub exited during startup")
                    try:
                        status, body = request(socket_path, "/healthz?key=packaging-test")
                        if status == 200 and body.strip() == b"ok":
                            break
                    except (OSError, http.client.HTTPException):
                        pass
                    if time.monotonic() >= deadline:
                        raise TimeoutError("RSSHub did not become healthy")
                    time.sleep(0.2)
                assert request(socket_path, "/")[0] == 200
                assert request(socket_path, "/favicon.ico")[0] == 200
                assert request(socket_path, "/api/namespace")[0] == 403
                assert request(socket_path, "/api/namespace?key=wrong")[0] == 403
                status, body = request(socket_path, "/api/namespace?key=packaging-test")
                assert status == 200
                namespaces = cast(dict[str, dict[str, object]], json.loads(body))
                assert len(namespaces) > 1000
                assert "rsshub" in namespaces
                assert "github" in namespaces
                routes = cast(dict[str, object], namespaces["rsshub"]["routes"])
                assert "/routes/:lang?" in routes
                assert not list(directory.glob("*.log"))
                print("RSSHub: health, assets, route registry and access control passed")
            except BaseException:
                _ = logs.seek(0)
                print(logs.read(), file=sys.stderr)
                raise
            finally:
                process.terminate()
                try:
                    _ = process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    _ = process.wait()


if __name__ == "__main__":
    main()
