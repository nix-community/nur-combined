from __future__ import annotations
from os import PathLike

# system imports
from dataclasses import dataclass
import json
import subprocess
from typing import Any, NoReturn, Callable, NamedTuple, Iterable
import sys
import os
import argparse
import uuid
import time
from pathlib import Path
import pprint
from pprint import pp
import asyncio

# library imports
import pydantic
import requests
import humanfriendly
import httpx

# self imports
import scriptipy.typeshed_clone


def die(*args) -> NoReturn:
    if len(args) == 0:
        eprint("FATAL: (no message)")
    else:
        eprint("FATAL:", *args)
    sys.exit(1)


def eprint(*args, **kwargs) -> None:
    print(*args, file=sys.stderr, **kwargs)


@dataclass
class ProcessResult[T]:
    stdout: T
    returncode: int

    def success(self) -> bool:
        return self.returncode == 0

    def map[U](self, f: Callable[[T], U]) -> ProcessResult[U]:
        new_stdout: U = f(self.stdout)
        return ProcessResult(stdout=new_stdout, returncode=self.returncode)

    def json(self: ProcessResult[str]) -> ProcessResult[Any]:
        return self.map(_parse_maybe_json)

    def must_succeed(self) -> T:
        if not self.success():
            die(f"command exited with code {self.returncode}")
        return self.stdout


def run(
    *cmd: str | bytes | PathLike[str] | PathLike[bytes], verbose=True
) -> ProcessResult[str]:
    if verbose:
        eprint(f"running {cmd!r}")
    proc = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=None, stdin=subprocess.DEVNULL, text=True
    )
    (stdout_data, _) = proc.communicate()
    if verbose:
        eprint(f"finished, exit code {proc.returncode}")
    return ProcessResult(stdout=stdout_data, returncode=proc.returncode)


def _parse_maybe_json(maybe_json: str) -> Any:
    if maybe_json.strip() == "":
        return None
    else:
        return json.loads(maybe_json)


def count(it: Iterable) -> int:
    res = 0
    for _ in it:
        res += 1
    return res


__all__ = [
    # system imports
    "dataclass",
    "json",
    "subprocess",
    "Any",
    "NoReturn",
    "Callable",
    "NamedTuple",
    "sys",
    "os",
    "argparse",
    "uuid",
    "time",
    "Path",
    "pprint",
    "pp",
    "asyncio",
    # library imports
    "pydantic",
    "requests",
    "humanfriendly",
    "httpx",
    # self
    "ProcessResult",
    "die",
    "eprint",
    "run",
    "count",
]
