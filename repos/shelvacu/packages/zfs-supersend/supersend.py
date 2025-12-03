import sys
import os
from typing import Any, Self
from enum import Enum
from dataclasses import dataclass
from scriptipy import *

JSON_ARGS = ["-j", "--json-int"]

MBUF_PORTS = [*range(36910, 36940)]


class Endpoint(Enum):
    SRC = 1
    DEST = 2


@dataclass
class Snapshot:
    e: Endpoint
    name: str
    # type:"SNAPSHOT"
    pool: str
    createtxg: int
    dataset: str
    snapshot_name: str
    # properties: Any


def snapshot_from_json(e: Endpoint, data: Any) -> Snapshot:
    return Snapshot(
        e=e,
        name=data["name"],
        pool=data["pool"],
        createtxg=data["createtxg"],
        dataset=data["dataset"],
        snapshot_name=data["snapshot_name"],
    )


@dataclass
class Dataset:
    e: Endpoint
    name: str
    # type:"DATASET"
    pool: str
    createtxg: int
    # properties:

    def snapshots(self) -> list[Snapshot]:
        res = run_at(
            self.e, "zfs", "list", *JSON_ARGS, "-t", "snapshot", self.name
        ).json()
        assert res.success()
        return [snapshot_from_json(self.e, x) for x in res.stdout["datasets"].values()]


def dataset_from_json(e: Endpoint, data: Any) -> Dataset:
    return Dataset(
        e=e,
        name=data["name"],
        pool=data["pool"],
        createtxg=data["createtxg"],
    )


source_server = "trip"
source_dataset = "trip"

destination_dataset = "propdata/trip"

# def run_source(*cmd) -> ProcessResult[str]:
#     return run("ssh", source_server, "--", *cmd)


def run_at(e: Endpoint, *cmd) -> ProcessResult[str]:
    args = [*cmd]
    if e == Endpoint.SRC:
        args = ["ssh", source_server, "--", *cmd]
    return run(*args)


run_destination = run

res = run_at(Endpoint.SRC, "zfs", "list", *JSON_ARGS).json()
assert res.success()
source_datasets = [
    dataset_from_json(Endpoint.SRC, x)
    for x in res.stdout["datasets"].values()
    if x["name"] == source_dataset or x["name"].startswith(f"{source_dataset}/")
]

# print(repr(source_datasets[0].snapshots()[0]))
for dataset in source_datasets:
    # print(f"{dataset=}")
    for snap in dataset.snapshots():
        print(f"{snap=}")

# res = run_source("zfs", "list", "-j", "-t", "snapshot", "/".join(source_dataset)).json()
# assert res.success()
# source_snapshots = [*res.stdout["datasets"].values()]
#
# # print(f"{source_snapshots=}")
#
# for snap in source_snapshots:
#     print(snap["dataset"])
#     # if snap["dataset"] == "trip":
#     #     snapshot_name = snap["snapshot_name"]
#     #     createtxg = snap["createtxg"]
#     #     print(f"{snapshot_name=} {createtxg=}")
