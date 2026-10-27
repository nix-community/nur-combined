#!/usr/bin/env python3
"""Authorized remote rootless Podman integration test; does not restart Misskey."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
from realm_agent_controller import TestController

agent, helper, fixture = map(lambda s: str(Path(s).resolve()), sys.argv[1:4])
podman = ["systemd-run", "--machine=misskey@.host", "--user", "--quiet", "--pipe", "--wait", "--collect", "/run/current-system/sw/bin/podman"]
info = json.loads(subprocess.check_output([*podman, "inspect", "misskey"]))[0]
ca = next(m["Source"] for m in info["Mounts"] if m["Destination"] == "/misskey/ca.crt")
with tempfile.TemporaryDirectory(prefix="realm-agent-rootless-") as temp:
    directory = Path(temp)
    os.chmod(directory, 0o755)
    (directory / "routes.json").write_text("[]")
    config = {"workloads": [{
        "name": "rootless-fixture", "user": "misskey", "group": "misskey", "workerUser": "nobody",
        "socket": str(directory / "control.sock"),
        "dnsHosts": {"s3.nyaw.xyz": ["203.0.113.8"]},
        "routes": [{"prefix": "203.0.113.8/32", "port": 443, "socket": "/run/realm/misskey/egress/s3.sock"}],
        "internetSocket": "/run/realm/misskey/egress/internet.sock", "internetPorts": [443],
    }]}
    path = directory / "config.json"
    path.write_text(json.dumps(config))
    controller = TestController(agent, path, "realm-agent-rootless-controller.service")
    try:
        for _ in range(100):
            if (directory / "control.sock").exists():
                break
            if controller.poll() is not None:
                raise RuntimeError("agent failed")
            time.sleep(.05)
        for attempt in range(2):
            subprocess.run([
                *podman, "run", "--rm", "--pull=never", "--name=realm-agent-rootless-fixture",
                "--network=none", "--userns=keep-id:uid=1000,gid=1000", "--user=1000:1000",
                "--cap-drop=ALL", "--security-opt=no-new-privileges",
                "--entrypoint=/realm/helper", f"--volume={helper}:/realm/helper:ro",
                f"--volume={directory / 'routes.json'}:/realm/routes.json:ro",
                f"--volume={directory}:/realm/agent:ro", f"--volume={fixture}:/fixture.mjs:ro",
                f"--volume={ca}:/misskey/ca.crt:ro",
                "--env=NODE_EXTRA_CA_CERTS=/misskey/ca.crt",
                "--env=REALM_AGENT_SOCKET=/realm/agent/control.sock",
                info["Image"], "launch", "node", "/fixture.mjs",
            ], check=True, timeout=90)
            print(f"rootless container generation {attempt + 1}: passed", flush=True)
    finally:
        subprocess.run([*podman, "rm", "--force", "--ignore", "realm-agent-rootless-fixture"], check=False)
        controller.terminate()
        try:
            controller.wait(timeout=10)
        except subprocess.TimeoutExpired:
            controller.kill()
            controller.wait()
