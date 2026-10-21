import json
import os
import socket
import subprocess
import sys
import tempfile
import time
import urllib.request
from pathlib import Path

with socket.socket() as listener:
    listener.bind(("127.0.0.1", 0))
    port = listener.getsockname()[1]

base_url = f"http://127.0.0.1:{port}"
with tempfile.NamedTemporaryFile(mode="w") as log:
    log_path = Path(log.name)
    server = subprocess.Popen(
        [
            sys.argv[1],
            "serve",
            "--host",
            "127.0.0.1",
            "--port",
            str(port),
            "--base-dir",
            os.environ["T3CODE_HOME"],
        ],
        stdin=subprocess.DEVNULL,
        stdout=log,
        stderr=subprocess.STDOUT,
    )

    try:
        deadline = time.monotonic() + 60
        while "T3 Code server is ready." not in log_path.read_text().splitlines():
            assert server.poll() is None, f"Server exited with code {server.returncode}"
            if time.monotonic() >= deadline:
                raise TimeoutError("Server did not become ready within 60 seconds")
            time.sleep(0.1)

        with urllib.request.urlopen(
            f"{base_url}/.well-known/t3/environment", timeout=5
        ) as response:
            assert response.status == 200
            descriptor = json.load(response)
        assert descriptor["environmentId"], descriptor
        with urllib.request.urlopen(base_url, timeout=5) as response:
            assert response.status == 200
            assert response.headers.get_content_type() == "text/html"
            assert response.read().strip(), "Web entry point is empty"
    finally:
        server.terminate()
        try:
            server.wait(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait()
        print(log_path.read_text(), end="", flush=True)
