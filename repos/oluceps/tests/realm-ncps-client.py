"""Exercise the generated production config against a local Unix HTTP backend."""

import argparse
import http.client
import json
import os
import socket
import socketserver
import subprocess
import tempfile
import threading
import time
from http.server import BaseHTTPRequestHandler
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument("--caddy", default="caddy")
    parser.add_argument("--unset-environment", type=Path, required=True)
    args = parser.parse_args()
    seen = []
    payload = b"fixture nar content\n" * 16384

    class Backend(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def handle_request(self):
            seen.append((self.command, self.path))
            self.send_response(200)
            self.send_header("Content-Length", str(len(payload)))
            self.send_header("X-Ncps-Fixture", "unix-backend")
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(payload)

        do_GET = do_HEAD = do_POST = do_PUT = do_PATCH = handle_request
        do_DELETE = do_OPTIONS = do_TRACE = do_CONNECT = handle_request

        def log_message(self, *_args):
            pass

    with tempfile.TemporaryDirectory(prefix="ncps-fixture-") as temporary:
        directory = Path(temporary)
        backend = socketserver.ThreadingUnixStreamServer(
            str(directory / "ncps.sock"), Backend
        )
        backend.daemon_threads = True
        thread = threading.Thread(target=backend.serve_forever, daemon=True)
        thread.start()
        # Replace only the listener address and socket path for an unprivileged,
        # parallel-safe fixture; all production routing and transport stay intact.
        with socket.socket() as reservation:
            reservation.bind(("127.0.0.1", 0))
            port = reservation.getsockname()[1]
        config = json.loads(args.config.read_text())
        server = config["apps"]["http"]["servers"]["ncps"]
        server["listen"] = [f"127.0.0.1:{port}"]
        server["routes"][1]["handle"][0]["upstreams"][0]["dial"] = (
            f"unix/{directory}/ncps.sock"
        )
        config_path = directory / "config.json"
        config_path.write_text(json.dumps(config))
        env = dict(
            os.environ,
            HOME=temporary,
            XDG_DATA_HOME=temporary,
            XDG_CONFIG_HOME=temporary,
        )
        # Model systemd's UnsetEnvironment using the evaluated production unit.
        # Without this removal, Caddy's ProxyFromEnvironment changes the Unix
        # upstream request to absolute-form, which the exact-path checks catch.
        proxy_variables = (
            "HTTP_PROXY",
            "HTTPS_PROXY",
            "ALL_PROXY",
            "NO_PROXY",
            "http_proxy",
            "https_proxy",
            "all_proxy",
            "no_proxy",
        )
        for variable in proxy_variables:
            env[variable] = (
                "" if variable.lower() == "no_proxy" else "http://127.0.0.1:9"
            )
        unset_environment = json.loads(args.unset_environment.read_text())
        for variable in unset_environment:
            env.pop(variable, None)
        assert not (set(proxy_variables) & env.keys()), "unit retains proxy environment"
        subprocess.run(
            [args.caddy, "validate", "--config", str(config_path)], check=True, env=env
        )
        with (directory / "caddy.log").open("w+") as log:
            process = subprocess.Popen(
                [args.caddy, "run", "--config", str(config_path)],
                stdout=log,
                stderr=log,
                env=env,
            )
            try:
                deadline = time.monotonic() + 10
                while True:
                    if process.poll() is not None or time.monotonic() >= deadline:
                        raise AssertionError("Caddy failed to start")
                    try:
                        with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                            break
                    except OSError:
                        time.sleep(0.05)

                def request(method, path):
                    connection = http.client.HTTPConnection(
                        "127.0.0.1", port, timeout=5
                    )
                    try:
                        connection.request(method, path)
                        response = connection.getresponse()
                        return (
                            response.status,
                            response.read(),
                            dict(response.getheaders()),
                        )
                    finally:
                        connection.close()

                allowed = [
                    "/",
                    "/nix-cache-info",
                    "/0123456789abc.narinfo",
                    "/nar/0123456789abc.nar.xz",
                    "/nar/metrics.xz",
                    "/nix-cache-info?source=%2Fmetrics&next=%252e%252e",
                ]
                for method in ["GET", "HEAD"]:
                    for path in allowed:
                        previous = len(seen)
                        status, body, headers = request(method, path)
                        assert status == 200, (method, path, status)
                        assert body == (payload if method == "GET" else b""), (
                            method,
                            path,
                        )
                        assert headers.get("X-Ncps-Fixture") == "unix-backend", headers
                        assert headers.get("Content-Length") == str(len(payload)), (
                            headers
                        )
                        assert seen[previous:] == [(method, path)], seen[previous:]

                denied_paths = [
                    "/metrics",
                    "/metrics/",
                    "/metrics-extra",
                    "/metricsfoo?x=1",
                    "/debug",
                    "/debug/pprof",
                    "/debugging",
                    "/debug?x=1",
                    "/%6detrics",
                    "/m%65trics",
                    "/%64ebug/pprof",
                    "/%256detrics",
                    "/%252564ebug",
                    "/%2fmetrics",
                    "/%2Fdebug",
                    "/metrics%2f",
                    "/debug%5c",
                    "/%5Cmetrics",
                    "/%255cdebug",
                    "/%2e/metrics",
                    "/%2e%2e/debug",
                    "/x/%2E%2E/metrics",
                    "/x/%252e%252e/debug",
                    "/%00metrics",
                    "/metrics%3fignored",
                    "/%EF%BC%8Fmetrics",
                    "/%c0%afdebug",
                    "/%zz/metrics",
                    "//metrics",
                    "///debug",
                    "/./metrics",
                    "/x/../metrics",
                    "/x/../../debug",
                    "/safe//object",
                    "/safe/./object",
                    "/safe/../object",
                    "/safe/.",
                    "/safe/..",
                    "/safe/..?x=1",
                    "/safe/./?x=1",
                    "/\\metrics",
                    "/safe\\..\\debug",
                    "/nar/hash%2enar.xz",
                ]
                for method in ["GET", "HEAD"]:
                    for path in denied_paths:
                        previous = len(seen)
                        status, _, _ = request(method, path)
                        assert status in (400, 403), (method, path, status)
                        assert len(seen) == previous, (
                            "blocked path reached backend",
                            method,
                            path,
                        )

                denied_methods = [
                    "POST",
                    "PUT",
                    "PATCH",
                    "DELETE",
                    "OPTIONS",
                    "TRACE",
                    "get",
                    "PROPFIND",
                ]
                for method in denied_methods:
                    for path in [
                        "/nix-cache-info",
                        "/nar/hash.nar.xz",
                        "/metrics",
                        "/debug",
                    ]:
                        previous = len(seen)
                        status, _, _ = request(method, path)
                        assert status == 403, (method, path, status)
                        assert len(seen) == previous, (
                            "write reached backend",
                            method,
                            path,
                        )
                previous = len(seen)
                status, _, _ = request("CONNECT", "example.invalid:443")
                assert status == 403, ("CONNECT", status)
                assert len(seen) == previous, "CONNECT reached backend"
                print(
                    json.dumps(
                        {
                            "allowed_GET_HEAD": 2 * len(allowed),
                            "denied_path_requests": 2 * len(denied_paths),
                            "denied_method_requests": 4 * len(denied_methods) + 1,
                            "upstream_requests": len(seen),
                            "proxy_variables_removed": len(proxy_variables),
                        },
                        sort_keys=True,
                    )
                )
            except Exception:
                log.flush()
                log.seek(0)
                print(log.read())
                raise
            finally:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
                backend.shutdown()
                backend.server_close()


if __name__ == "__main__":
    main()
