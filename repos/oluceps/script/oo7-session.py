"""Manage oo7 host credentials and check session readiness without reading secrets."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

CREDENTIAL = "oo7.keyring-encryption-password"
SERVICE = "org.freedesktop.secrets"
ROOT = "/org/freedesktop/secrets"
COLLECTION = "org.freedesktop.Secret.Collection"
ITEM = "org.freedesktop.Secret.Item"


class CheckError(Exception):
    pass


def run(args, **kwargs):
    kwargs.setdefault("timeout", 10)
    result = subprocess.run(args, capture_output=True, **kwargs)
    if result.returncode:
        # Do not print subprocess output. It can contain credential data.
        raise CheckError("A required command failed. Check the service status.")
    return result.stdout


def secure_directory(path):
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    if path.is_symlink() or path.stat().st_uid != os.getuid():
        raise CheckError("The private directory has an unsafe owner or symbolic link.")
    path.chmod(0o700)


def keyring_names(config):
    return list(dict.fromkeys([config["default_keyring"], *config["required_keyrings"]]))


def snapshot(directory):
    result = {}
    for path in sorted(directory.rglob("*")):
        if path.is_symlink():
            raise CheckError("The keyring directory contains a symbolic link. Back up manually.")
        if path.is_file():
            result[str(path.relative_to(directory))] = hashlib.sha256(path.read_bytes()).hexdigest()
        elif not path.is_dir():
            raise CheckError("The keyring directory contains a special file.")
    return result


def backup(home):
    source = home / ".local/share/keyrings"
    if source.is_symlink() or not source.is_dir():
        raise CheckError("The existing keyring directory is missing or unsafe.")
    root = home / ".local/state/keyring-backups"
    secure_directory(root)
    before = snapshot(source)
    if not before:
        raise CheckError("The keyring directory is empty. No backup was made.")
    destination = Path(tempfile.mkdtemp(prefix="before-oo7-", dir=root))
    shutil.copytree(source, destination / "keyrings")
    if before != snapshot(source) or before != snapshot(destination / "keyrings"):
        raise CheckError("The keyrings changed during backup. Stop writers and try again.")
    for path in (destination / "keyrings").rglob("*"):
        path.chmod(0o700 if path.is_dir() else 0o600)
    (destination / "keyrings").chmod(0o700)
    manifest = destination / "manifest.json"
    manifest.write_text(json.dumps({"verified": True, "files": before}, indent=2) + "\n")
    manifest.chmod(0o600)
    print(f"Verified keyring backup: {destination}")
    return destination


def no_secret_service_owner(config):
    output = run([
        config["busctl"], "--user", "--timeout=2", "--json=short", "call",
        "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
        "NameHasOwner", "s", SERVICE,
    ])
    if json.loads(output)["data"][0]:
        raise CheckError("A Secret Service is already running. Do not replace it during migration.")


def prepare(config, home):
    credential_dir = os.environ.get("CREDENTIALS_DIRECTORY")
    if not credential_dir:
        raise CheckError("The systemd credential directory is missing.")
    credential = Path(credential_dir) / CREDENTIAL
    if not credential.is_file() or not 0 < credential.stat().st_size <= 65536:
        raise CheckError("The keyring credential is missing, empty, or too large.")
    directory = home / ".local/share/keyrings/v1"
    for name in keyring_names(config):
        path = directory / f"{name}.keyring"
        if not path.is_file() or path.is_symlink():
            raise CheckError(f"Required keyring file {name}.keyring is missing.")
    no_secret_service_owner(config)


class Bus:
    def __init__(self, config, expected_pid):
        self.tool = config["busctl"]
        self.owner = self.call(
            "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
            "GetNameOwner", "s", SERVICE,
        )[0]
        pid = self.call(
            "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
            "GetConnectionUnixProcessID", "s", self.owner,
        )[0]
        if pid != expected_pid:
            raise CheckError("The Secret Service owner is not the oo7 systemd process.")

    def call(self, destination, path, interface, method, *args):
        output = run([
            self.tool, "--user", "--timeout=2", "--json=short", "call",
            destination, path, interface, method, *args,
        ])
        return json.loads(output)["data"]

    def property(self, path, interface, name):
        output = run([
            self.tool, "--user", "--timeout=2", "--json=short", "get-property",
            self.owner, path, interface, name,
        ])
        return json.loads(output)["data"]

    def default_collection(self):
        return self.call(self.owner, ROOT, "org.freedesktop.Secret.Service", "ReadAlias", "s", "default")[0]


def check_ready(config, bus):
    collections = bus.property(ROOT, "org.freedesktop.Secret.Service", "Collections")
    by_label = {}
    for path in collections:
        label = bus.property(path, COLLECTION, "Label")
        by_label.setdefault(label, []).append(path)
    selected = {}
    for name in keyring_names(config):
        label = name[:1].upper() + name[1:]
        matches = by_label.get(label, [])
        if len(matches) != 1:
            raise CheckError("A required collection is missing or duplicated.")
        path = matches[0]
        if bus.property(path, COLLECTION, "Locked"):
            raise CheckError("A required collection is locked. Check its password.")
        selected[name] = path
    target = selected[config["default_keyring"]]
    if bus.default_collection() != target:
        raise CheckError("The default alias points to the wrong collection.")


def expected_pid(config, post_start):
    value = os.environ.get("MAINPID") if post_start else run([
        config["systemctl"], "--user", "show", "oo7-daemon.service", "--property=MainPID", "--value",
    ]).decode().strip()
    if not value or not value.isdecimal() or int(value) <= 0:
        raise CheckError("The oo7 process is not running.")
    return int(value)


def ready(config, post_start=False):
    deadline = time.monotonic() + (45 if post_start else 0)
    pid = expected_pid(config, post_start)
    while True:
        try:
            check_ready(config, Bus(config, pid))
            return
        except CheckError:
            if time.monotonic() >= deadline:
                raise
            time.sleep(0.25)


def enroll(config, home, replace=False):
    directory = home / ".config/credstore.encrypted"
    secure_directory(directory)
    destination = directory / CREDENTIAL
    if destination.is_symlink():
        raise CheckError("The credential path is a symbolic link.")
    if destination.exists() and not replace:
        raise CheckError("The credential exists. Use enroll --replace only to update its password.")
    # Only ciphertext is written to disk. Passwords stay in pipes and process memory.
    password = subprocess.run(
        [config["ask_password"], "--timeout=0", "-n", "Existing keyring password:"],
        stdout=subprocess.PIPE, check=True,
    ).stdout
    confirm = subprocess.run(
        [config["ask_password"], "--timeout=0", "-n", "Repeat the keyring password:"],
        stdout=subprocess.PIPE, check=True,
    ).stdout
    if not password or password != confirm:
        raise CheckError("The passwords are empty or do not match. No credential was saved.")
    with tempfile.TemporaryDirectory(prefix=".oo7-enroll-", dir=directory) as temporary:
        encrypted = Path(temporary) / CREDENTIAL
        run([
            config["systemd_creds"], "encrypt", "--user", "--with-key=host",
            f"--name={CREDENTIAL}", "-", str(encrypted),
        ], input=password, timeout=None)
        encrypted.chmod(0o600)
        with encrypted.open("rb") as file:
            os.fsync(file.fileno())
        if replace:
            os.replace(encrypted, destination)
        else:
            os.link(encrypted, destination)
        directory_fd = os.open(directory, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    print("The host credential is saved. No services were restarted.")


def main():
    parser = argparse.ArgumentParser(prog="oo7-session", description=__doc__)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("command", choices=["condition", "prepare", "post-start", "ready", "backup", "enroll"])
    parser.add_argument("--replace", action="store_true")
    args = parser.parse_args()
    os.umask(0o077)
    config = json.loads(args.config.read_text())
    if os.getuid() != config["uid"]:
        raise CheckError("Run this command as the configured user, without sudo.")
    if args.replace and args.command != "enroll":
        raise CheckError("The --replace option is only valid with enroll.")
    home = Path.home()
    if args.command == "condition":
        result = subprocess.run([
            config["systemctl"], "--user", "is-active", "--quiet", "graphical-session.target",
        ], timeout=10)
        return 0 if result.returncode == 0 else 1
    if args.command == "prepare":
        prepare(config, home)
    elif args.command in ["ready", "post-start"]:
        ready(config, post_start=args.command == "post-start")
    elif args.command == "backup":
        backup(home)
    elif args.command == "enroll":
        enroll(config, home, args.replace)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except CheckError as error:
        print(f"oo7-session: {error}", file=sys.stderr)
        sys.exit(1)
    except (OSError, ValueError, subprocess.SubprocessError):
        # Exception objects can include subprocess arguments or captured output.
        print("oo7-session failed. Check the credential, keyring backup, and service status.", file=sys.stderr)
        sys.exit(1)
