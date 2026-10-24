"""Validate real OpenSSH configuration against the shared, explicit policy."""

import json
import subprocess
import sys
import tempfile
from pathlib import Path


def run(*args):
    result = subprocess.run(
        args, capture_output=True, text=True, stdin=subprocess.DEVNULL
    )
    if result.returncode:
        print(result.stderr, file=sys.stderr)
        result.check_returncode()
    return result.stdout


def settings(output):
    return {
        key.lower(): value
        for key, value in (line.split(None, 1) for line in output.splitlines())
    }


client_path, server_path, expected_path = sys.argv[1:]
policy = json.loads(Path(expected_path).read_text())
expected = {
    "kexalgorithms": policy["kexAlgorithms"],
    "ciphers": policy["ciphers"],
    "macs": policy["macs"],
    "hostkeyalgorithms": policy["keyAlgorithms"],
    "pubkeyacceptedalgorithms": policy["keyAlgorithms"],
}

# Keep the intended restrictions even when editing the allowlist itself.
assert policy["kexAlgorithms"][0].startswith(("mlkem", "sntrup"))
assert all(
    "x25519" in name or name.startswith("curve25519-")
    for name in policy["kexAlgorithms"]
)
assert all(
    name.endswith("-gcm@openssh.com") or name == "chacha20-poly1305@openssh.com"
    for name in policy["ciphers"]
)
assert all(name.endswith("-etm@openssh.com") and "sha1" not in name for name in policy["macs"])
assert all(
    name.startswith(("ssh-ed25519", "sk-ssh-ed25519", "rsa-sha2-"))
    for name in policy["keyAlgorithms"]
)

client = settings(run("ssh", "-G", "-F", client_path, "policy-check.invalid"))
with tempfile.TemporaryDirectory() as directory:
    host_key = str(Path(directory) / "host_key")
    run("ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", host_key)
    server = settings(run("sshd", "-T", "-f", server_path, "-h", host_key))

for role, effective in (("client", client), ("server", server)):
    for option, allowed in expected.items():
        assert effective[option].split(",") == allowed, (role, option, effective[option])

assert server["permitrootlogin"] == "no"
assert server["passwordauthentication"] == "no"
assert server["kbdinteractiveauthentication"] == "no"
assert server["authenticationmethods"] == "publickey"
assert server["port"] == "3939"
print("OpenSSH client/server allowlists and server authentication policy passed")
