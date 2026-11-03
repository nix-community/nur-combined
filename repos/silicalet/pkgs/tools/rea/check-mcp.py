"""Exercise the installed stdio server without writing agent configuration."""

import json
import os
import selectors
import subprocess
import sys
import time


with subprocess.Popen(
    [sys.argv[1], "mcp"], stdin=subprocess.PIPE, stdout=subprocess.PIPE
) as server:
    selector = selectors.DefaultSelector()
    selector.register(server.stdout, selectors.EVENT_READ)
    pending = bytearray()

    def send(message):
        server.stdin.write(json.dumps(message).encode() + b"\n")
        server.stdin.flush()

    def receive(request_id):
        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            if b"\n" not in pending:
                if not selector.select(max(0, deadline - time.monotonic())):
                    break
                chunk = os.read(server.stdout.fileno(), 65536)
                if not chunk:
                    raise RuntimeError("MCP server exited before responding")
                pending.extend(chunk)
                continue
            line, _, rest = pending.partition(b"\n")
            pending[:] = rest
            message = json.loads(line)
            if message.get("id") == request_id:
                if "error" in message:
                    raise RuntimeError(message["error"])
                return message["result"]
        raise TimeoutError(f"MCP request {request_id} timed out")

    try:
        send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {
            "protocolVersion": "2025-03-26", "capabilities": {},
            "clientInfo": {"name": "nix-install-check", "version": "1"},
        }})
        result = receive(1)
        assert "tools" in result["capabilities"], result
        send({"jsonrpc": "2.0", "method": "notifications/initialized"})
        send({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
        tools = receive(2)["tools"]
        assert tools and all("name" in tool and "inputSchema" in tool for tool in tools)
        print(f"MCP initialization and tools/list passed ({len(tools)} tools)")
    finally:
        selector.close()
        server.stdin.close()
        server.terminate()
        try:
            server.wait(timeout=10)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait()
