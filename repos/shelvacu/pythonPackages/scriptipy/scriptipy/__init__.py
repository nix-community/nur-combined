from __future__ import annotations
from os import PathLike

# system imports
from collections.abc import Collection, Mapping
from dataclasses import dataclass
import json
import subprocess
from typing import Any, NoReturn, Callable, NamedTuple, Iterable, Never, Literal
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
from . import typeshed_clone


if sys.version_info >= (3, 15):
    type _readonlydict[K, V] = readonlydict[K, V]
else:
    type _readonlydict[K, V] = Never

type _JsonPlainValue = str | int | float | bool | None

type JsonValue = _JsonPlainValue | list[JsonValue] | dict[str, JsonValue]

type ToJsonValue = _JsonPlainValue | Collection[ToJsonValue] | Mapping[str, ToJsonValue]


def _type_assert(a:JsonValue) -> ToJsonValue: # pyright: ignore[reportUnusedFunction]
    return a

def from_json(data: str|bytes|bytearray, /, empty_okay:bool=False) -> JsonValue:
    if empty_okay and len(data) == 0:
        return None
    return json.loads(data)

class MorallyCorrectJsonEncoder(json.JSONEncoder):
    def default(self, o: object) -> object:
        if isinstance(o, (str, int, float, bool)) or o is None:
            return o
        elif isinstance(o, Mapping):
            return dict(**o) # pyright: ignore[reportUnknownVariableType,reportUnknownArgumentType]
        elif isinstance(o, Collection):
            return list(*o) # pyright: ignore[reportUnknownVariableType]
        else:
            return super().default(o)

def to_json(
    obj: ToJsonValue,
    /,
    # no skipkeys
    ensure_ascii:bool = True,
    check_circular:bool = True,
    allow_nan:Literal[False] = False,
    # no cls
    indent:int|str|None = None,
    separators:tuple[Literal[',',', '], Literal[':',': ']]|None = None,
    default:None = None,
    sort_keys:bool = False,
) -> str:
    return json.dumps(
        obj,
        ensure_ascii=ensure_ascii,
        check_circular=check_circular,
        allow_nan=allow_nan,
        indent=indent,
        separators=separators,
        default=default,
        sort_keys=sort_keys,
    )


def die(first_arg: object, /, *args:object) -> NoReturn:
    eprint("FATAL:", first_arg, *args)
    sys.exit(1)


def eprint(
    *args:object,
    sep:str|None=' ',
    end:str|None='\n',
    flush:bool=True,
) -> None:
    print(*args, sep=sep, end=end, file=sys.stderr, flush=flush)


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
        *cmd: str | bytes | PathLike[str] | PathLike[bytes],
        verbose:bool=True,
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


def count(it: Iterable[Any], /) -> int:
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
    # self imports
    "typeshed_clone",
    # self
    "JsonValue",
    "ProcessResult",
    "die",
    "eprint",
    "run",
    "count",
]
