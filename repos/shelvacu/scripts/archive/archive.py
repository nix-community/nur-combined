# flake8: noqa
from __future__ import annotations
import argparse
from collections.abc import Callable
from dataclasses import dataclass
import json
import shutil
import subprocess
import sys
import random
from typing import Any

from scriptipy import *
import humanfriendly


# @dataclass
# class ProcessResult[T]:
#     stdout: T
#     returncode: int
#
#     def success(self) -> bool:
#         return self.returncode == 0
#
#     def map[U](self, f: Callable[[T], U]) -> ProcessResult[U]:
#         new_stdout: U = f(self.stdout)
#         return ProcessResult(stdout=new_stdout, returncode=self.returncode)
#
#
# def run(*cmd: str, verbose=True) -> ProcessResult[str]:
#     if verbose:
#         print(f"running {cmd!r}")
#     proc = subprocess.Popen(
#         cmd, stdout=subprocess.PIPE, stderr=None, stdin=subprocess.DEVNULL, text=True
#     )
#     (stdout_data, _) = proc.communicate()
#     if verbose:
#         print(f"finished, exit code {proc.returncode}")
#     return ProcessResult(stdout=stdout_data, returncode=proc.returncode)
#
#
# def must_succeed(*cmd: str, verbose=True) -> str:
#     res = run(*cmd, verbose=verbose)
#     assert res.success()
#     return res.stdout
#
#
# def parse_maybe_json(maybe_json: str) -> Any:
#     if maybe_json.strip() == "":
#         return None
#     else:
#         return json.loads(maybe_json)
#
#
# def run_json(*cmd: str, verbose=True) -> ProcessResult[Any]:
#     res = run(*cmd, verbose=verbose)
#     return res.map(parse_maybe_json)


def do_build(installable: str, impure: bool) -> bool:
    eval_command = ["nix", "derivation", "show", installable]
    if impure:
        eval_command.append("--impure")
    res = run(*eval_command).json()
    if not res.success():
        return False
    drv_paths = list(res.stdout.keys())
    for drv_path in drv_paths:
        print(f"{installable=} {drv_path=}")
        res = run(
            "nix",
            "build",
            "-j1",
            "--keep-going",
            "--no-link",
            "--json",
            drv_path + "^*",
        ).json()
        if not res.success():
            return False
        builds = res.stdout
        for build in builds:
            for out_path in build["outputs"].values():
                print(f"{installable=} {out_path=}")
                res = run("into-nix-cache", out_path)
                if not res.success():
                    return False
    return True


parser = argparse.ArgumentParser()
parser.add_argument("--min-space", default="50G")
args = parser.parse_args()
min_space_bytes = humanfriendly.parse_size(args.min_space)
min_space_text = humanfriendly.format_size(min_space_bytes)


def clean_if_space_needed():
    usage = shutil.disk_usage("/nix/store")
    if usage.free < min_space_bytes:
        free_space_text = humanfriendly.format_size(usage.free)
        print(
            f"free space ({free_space_text}) is less than min ({min_space_text}), running a gc"
        )
        must_succeed("nix", "store", "gc")
    usage = shutil.disk_usage("/nix/store")
    if usage.free < min_space_bytes:
        print("Couldn't clear enough storage, bailing")
        sys.exit(1)


res = run("nix", "eval", ".#.", "--json", "--apply", "f: f.archival.archiveList").json()
assert res.success()
build_list = res.stdout

random.shuffle(build_list)

for info in build_list:
    name = info["name"]
    if info["broken"]:
        eprint(f"Skipping {name}, marked broken")
        continue
    clean_if_space_needed()
    res = do_build(f".#archival.drvs.{name}", impure=info["impure"])
    if not res:
        continue
    do_build(f".#archival.buildDepsDrvs.{name}", impure=info["impure"])
