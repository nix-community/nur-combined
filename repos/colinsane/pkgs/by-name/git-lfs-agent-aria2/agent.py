#!@python@
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def send(**message):
    print(json.dumps(message), flush=True)


def download(batch_url, oid, size, target, log):
    # Standalone agents get no download action, so query the LFS Batch API
    # for a download URL using just the OID and size.
    body = json.dumps(
        {
            "operation": "download",
            "transfers": ["basic"],
            "objects": [{"oid": oid, "size": size}],
        }
    )
    # Allow .netrc authentication only for the LFS API, not the CDN.
    # fmt: off
    batch = subprocess.run(
        [
            "@curl@",
            "--disable",
            "--silent",
            "--show-error",
            "--fail",
            "--max-time", "60",
            "--netrc-optional",
            "--header", "Accept: application/vnd.git-lfs+json",
            "--header", "Content-Type: application/vnd.git-lfs+json",
            "--data-binary", body,
            batch_url,
        ],
        stdout=subprocess.PIPE,
    )
    # fmt: on
    if batch.returncode:
        raise ValueError(f"LFS batch request failed (curl exit {batch.returncode})")
    (obj,) = json.loads(batch.stdout)["objects"]
    if "error" in obj:
        raise ValueError(f"LFS batch object error: {obj['error']}")
    action = obj["actions"]["download"]
    href = action["href"]
    headers = [
        f"--header={key}: {value}" for key, value in action.get("header", {}).items()
    ]
    # Keep .netrc credentials off the CDN request.
    # aria2 doesn't honor SSL_CERT_FILE on its own. Pass it through so the
    # agent uses the same Nix-provided trust bundle as curl and Git.
    ca_file = os.environ.get("SSL_CERT_FILE")
    ca_args = [f"--ca-certificate={ca_file}"] if ca_file else []
    print(f"aria2: downloading LFS object {oid} ({size} bytes)", file=log, flush=True)
    result = subprocess.run(
        [
            "@aria2@",
            "--no-netrc",
            "--max-connection-per-server=4",
            *ca_args,
            "--dir=" + str(target.parent),
            "--out=" + target.name,
            *headers,
            "--",
            href,
        ],
        stdout=log,
        stderr=subprocess.STDOUT,
    )
    if result.returncode:
        raise ValueError(f"LFS download failed (aria2 exit {result.returncode})")
    send(event="progress", oid=oid, bytesSoFar=size, bytesSinceLast=size)


log_path = os.environ.get("GIT_LFS_ARIA2_LOG")
log = open(log_path, "a") if log_path else sys.stderr
init = json.loads(sys.stdin.readline())
if init.get("event") != "init" or init.get("operation") != "download":
    send(error={"code": 1, "message": "Expected a download init"})
    sys.exit(1)

try:
    lfs_env = dict(
        line.split("=", 1)
        for line in subprocess.check_output(
            ["git", "lfs", "env"], text=True
        ).splitlines()
        if "=" in line
    )
    remote = init.get("remote") or "origin"
    endpoint = lfs_env.get(f"Endpoint ({remote})")
    # Git LFS abbreviates the default origin entry to just "Endpoint".
    if endpoint is None and remote == "origin":
        endpoint = lfs_env.get("Endpoint")
    if not endpoint:
        raise ValueError(f"No Git LFS endpoint found for remote {remote!r}")
    endpoint = endpoint.split(" (auth=", 1)[0]
    batch_url = endpoint.rstrip("/") + "/objects/batch"
    # Stage on the same filesystem as the LFS store so Git LFS can rename
    # the object into place after checking its OID.
    media_dir = lfs_env["LocalMediaDir"]
except (OSError, subprocess.CalledProcessError, ValueError, KeyError) as exc:
    send(error={"code": 1, "message": str(exc)})
    sys.exit(1)

with tempfile.TemporaryDirectory(dir=media_dir) as staging:
    send()
    target = Path(staging) / "object"
    for line in sys.stdin:
        request = json.loads(line)
        if request["event"] == "terminate":
            break
        oid, size = request["oid"], request["size"]
        try:
            target.unlink(missing_ok=True)
            target.with_suffix(".aria2").unlink(missing_ok=True)
            download(batch_url, oid, size, target, log)
            send(event="complete", oid=oid, path=str(target))
        except (OSError, ValueError, KeyError) as exc:
            send(event="complete", oid=oid, error={"code": 1, "message": str(exc)})
