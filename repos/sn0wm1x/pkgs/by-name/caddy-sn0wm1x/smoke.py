"""Exercise the combined build locally without Docker or DNS credentials."""

import base64
import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import socket
import ssl
import subprocess
import sys
import tempfile
import threading
import time


def free_port():
    with socket.socket() as connection:
        connection.bind(("127.0.0.1", 0))
        return connection.getsockname()[1]


class Upstream(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"upstream"
        self.send_response(200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


def request(port, method, path, body=None):
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
    try:
        connection.request(method, path, body)
        response = connection.getresponse()
        return response.status, response.read()
    finally:
        connection.close()


def main():
    caddy, http3_client = sys.argv[1:]
    modules = subprocess.check_output([caddy, "list-modules"], text=True).splitlines()
    for module in ("dns.providers.cloudflare", "dynamic_dns", "layer4", "http.handlers.forward_proxy", "http.handlers.webdav"):
        assert module in modules, f"Missing module: {module}"

    upstream = ThreadingHTTPServer(("127.0.0.1", 0), Upstream)
    threading.Thread(target=upstream.serve_forever, daemon=True).start()
    upstream_port = upstream.server_port
    http_port, tls_port, layer4_port = (free_port() for _ in range(3))
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        subprocess.run([
            "openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes",
            "-keyout", str(root / "key.pem"), "-out", str(root / "cert.pem"),
            "-days", "1", "-subj", "/CN=localhost",
            "-addext", "subjectAltName=DNS:localhost,IP:127.0.0.1",
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        (root / "files").mkdir()
        config = root / "Caddyfile"
        config.write_text(f"""{{
    admin off
    auto_https off
    layer4 {{
        127.0.0.1:{layer4_port} {{
            route {{
                proxy 127.0.0.1:{upstream_port}
            }}
        }}
    }}
}}
http://127.0.0.1:{http_port} {{
    route /dav/* {{
        webdav {{
            root {root}/files
            prefix /dav
        }}
    }}
    respond "hello"
}}
:{tls_port} {{
    bind 127.0.0.1
    tls {root}/cert.pem {root}/key.pem
    route {{
        forward_proxy {{
            basic_auth test password
            ports {upstream_port}
            acl {{
                allow 127.0.0.1
                deny all
            }}
            probe_resistance
        }}
        respond "ready"
    }}
}}
""")
        # Adapt DDNS separately so no external API is contacted during the test.
        ddns = root / "DDNS.Caddyfile"
        ddns.write_text("""{
    dynamic_dns {
        provider cloudflare test-token
        domains {
            example.invalid @
        }
        versions ipv4 ipv6
    }
}
""")
        adapted = json.loads(subprocess.check_output([caddy, "adapt", "--config", str(ddns)], text=True))
        assert adapted["apps"]["dynamic_dns"]["dns_provider"]["name"] == "cloudflare"
        log_path = root / "caddy.log"
        with log_path.open("w") as log:
            process = subprocess.Popen([caddy, "run", "--config", str(config)], stdout=log, stderr=log)
            try:
                for _ in range(100):
                    if process.poll() is not None:
                        raise RuntimeError(log_path.read_text())
                    try:
                        if request(http_port, "GET", "/") == (200, b"hello"):
                            break
                    except OSError:
                        time.sleep(0.1)
                else:
                    raise RuntimeError("Caddy did not become ready")
                assert request(http_port, "PUT", "/dav/file.txt", b"webdav") == (201, b"Created")
                assert request(http_port, "GET", "/dav/file.txt") == (200, b"webdav")
                assert (root / "files/file.txt").read_bytes() == b"webdav"
                assert request(layer4_port, "GET", "/") == (200, b"upstream")

                # An unauthenticated CONNECT must not create a usable tunnel.
                context = ssl._create_unverified_context()
                with context.wrap_socket(socket.create_connection(("127.0.0.1", tls_port), timeout=5), server_hostname="localhost") as connection:
                    connection.sendall(f"CONNECT 127.0.0.1:{upstream_port} HTTP/1.1\r\nHost: 127.0.0.1:{upstream_port}\r\n\r\n".encode())
                    response = http.client.HTTPResponse(connection)
                    response.begin()
                    assert response.read() == b"ready", "Unauthenticated proxy request bypassed probe resistance"

                # Verify authenticated HTTPS CONNECT and traffic through the tunnel.
                with context.wrap_socket(socket.create_connection(("127.0.0.1", tls_port), timeout=5), server_hostname="localhost") as connection:
                    auth = base64.b64encode(b"test:password").decode()
                    connection.sendall(f"CONNECT 127.0.0.1:{upstream_port} HTTP/1.1\r\nHost: 127.0.0.1:{upstream_port}\r\nProxy-Authorization: Basic {auth}\r\n\r\n".encode())
                    headers = b""
                    while not headers.endswith(b"\r\n\r\n"):
                        byte = connection.recv(1)
                        assert byte, "Proxy closed the connection before accepting CONNECT"
                        headers += byte
                    assert headers.startswith(b"HTTP/1.1 200"), headers
                    connection.sendall(b"GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n")
                    response = http.client.HTTPResponse(connection)
                    response.begin()
                    assert response.status == 200 and response.read() == b"upstream"

                subprocess.run(["go", "run", http3_client, f"https://127.0.0.1:{tls_port}/"], check=True)
                assert '"controller":"sing-quic BBRv1"' in log_path.read_text(), "HTTP/3 did not enable BBRv1"
            except BaseException:
                print(log_path.read_text(), file=sys.stderr)
                raise
            finally:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
    upstream.shutdown()
    upstream.server_close()
    print("Cloudflare/DDNS configuration, WebDAV, layer4, authenticated forward proxy and HTTP/3 BBRv1 checks passed")


if __name__ == "__main__":
    main()
