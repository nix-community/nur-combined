from __future__ import annotations
from collections.abc import Callable
from dataclasses import dataclass
import json
import subprocess
from typing import Any
import sys
from os import PathLike


def eprint(*args, **kwargs):
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


def must_succeed(*cmd: str, verbose=True) -> str:
    res = run(*cmd, verbose=verbose)
    assert res.success()
    return res.stdout


def _parse_maybe_json(maybe_json: str) -> Any:
    if maybe_json.strip() == "":
        return None
    else:
        return json.loads(maybe_json)


__all__ = [
    "ProcessResult",
    "eprint",
    "run",
    "must_succeed",
]
