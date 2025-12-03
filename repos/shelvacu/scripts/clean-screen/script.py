#!/usr/bin/env python3
from __future__ import annotations
from dataclasses import dataclass
from collections.abc import Callable
from typing import NoReturn
from pathlib import PosixPath
import subprocess
import os
import re
import sys
import stat


@dataclass
class ProcessResult[T]:
    stdout: T
    returncode: int

    def success(self) -> bool:
        return self.returncode == 0

    def map[U](self, f: Callable[[T], U]) -> ProcessResult[U]:
        new_stdout: U = f(self.stdout)
        return ProcessResult(stdout=new_stdout, returncode=self.returncode)


def to_bytes(thing: bytes | str) -> bytes:
    if isinstance(thing, bytes):
        return thing
    else:
        return thing.encode()


def run(
    *cmd: str,
    verbose=True,
    override_env: None | dict[bytes | str, bytes | str] = None,
    **kwargs,
) -> ProcessResult[str]:
    if override_env is not None and "env" in kwargs:
        raise ValueError("Cannot specify both override_env and env")
    if verbose:
        addl = ""
        if override_env is not None:
            addl = f" with env {override_env!r}"
        print(f"running {cmd!r}{addl}")
    if override_env is not None:
        new_env = os.environb | {
            to_bytes(k): to_bytes(v) for k, v in override_env.items()
        }
        kwargs["env"] = new_env
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=None,
        stdin=subprocess.DEVNULL,
        text=True,
        **kwargs,
    )
    (stdout_data, _) = proc.communicate()
    if verbose:
        print(f"finished, exit code {proc.returncode}")
    return ProcessResult(stdout=stdout_data, returncode=proc.returncode)


def die(msg: str) -> NoReturn:
    print(msg)
    sys.exit(1)


res = run("screen", "-ls", override_env={"LC_ALL": "C"})
lines = res.stdout.splitlines()

# print(f"{lines=}")

if lines[0] not in ["There are screens on:", "There is a screen on:"]:
    die(f"Dunno how to handle {lines[0]=}")

lines = lines[1:]

m = re.fullmatch(r"\d+ Sockets in (?P<path>.*)\.", lines[-1])

if m is None:
    die(f"Dunno how to handle {lines[-1]=}")

sockets_path = PosixPath(m["path"])

lines = lines[:-1]

LINE_RE = re.compile(
    r"""
    \t
    (?P<pid>\d+) \. (?P<name>[a-z0-9-]+)
    \t
    \(
    (?P<status>[a-z ,?]+)
    \)
""",
    re.VERBOSE | re.ASCII | re.IGNORECASE,
)

for line in lines:
    m = LINE_RE.fullmatch(line)
    if m is None:
        die(f"Couldn't parse {line=}")
    pid = int(m["pid"])
    name = m["name"]
    status = m["status"]
    socket_path = sockets_path / f"{pid}.{name}"

    if status in ["Attached", "Detached", "Multi, attached", "Multi, detached"]:
        pass
    elif status in ["Remote or dead", "Dead ???", "Removed"]:
        print(f"{pid=} {name=} {status=} {socket_path=}")
        if os.path.exists(f"/proc/{pid}"):
            continue
        stat_result = socket_path.stat(follow_symlinks=False)
        # print(f"{socket_path=} {stat_result=}")
        is_socket = stat.S_ISSOCK(stat_result.st_mode)
        if not is_socket:
            continue
        print(f"Deleting {socket_path}")
        socket_path.unlink()
    # There's also "Private" but I don't know how I should deal with that, so warn along with any unrecognized ones
    else:
        print(f"Warn: Unrecognized {status=}")
print("Done.")
