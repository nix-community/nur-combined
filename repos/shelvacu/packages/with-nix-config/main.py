import argparse
import os
import dataclasses
import sys
import typing
from pathlib import Path
from scriptipy import run

_T_contra = typing.TypeVar("_T_contra", contravariant=True)

class SupportsWrite(typing.Protocol[_T_contra]):
    def write(self, s: _T_contra, /) -> object: ...

@dataclasses.dataclass(frozen=True, kw_only=True)
class Builder:
    name: str
    aliases: tuple[str, ...] = ()
    store_path: str
    system_types: tuple[str, ...] | None = None
    identity_file: str | Path | None = None
    jobs: int | None = None
    speed_factor: int | float | None = None
    supported_system_features: tuple[str, ...] | None = None
    required_system_features: tuple[str, ...] | None = None
    host_key: str | None = None

    def names(self) -> tuple[str, ...]:
        return (self.name, *self.aliases)

    def serialize(self) -> str:
        components_diverse: list[str | Path | list[str] | tuple[str, ...] | int | float | None] = [
            self.store_path,
            self.system_types,
            self.identity_file,
            self.jobs,
            self.speed_factor,
            self.supported_system_features,
            self.required_system_features,
            self.host_key,
        ]

        def conv(el: str | Path | list[str] | tuple[str, ...] | int | float | None) -> str:
            if el is None:
                return "-"
            if isinstance(el, (Path, int, float)):
                return str(el)
            if isinstance(el, (list, tuple)):
                return ",".join(el)
            return el

        components: list[str] = [conv(x) for x in components_diverse]

        while components[-1] == "-":
            components.pop()

        return " ".join(components)


BUILDERS:typing.Final[tuple[Builder, ...]] = (
    Builder(
        name="prophecy",
        aliases=("prop",),
        store_path="ssh-ng://prophecy",
        system_types=("x86_64-linux", "aarch64-linux"),
        jobs=22,
        supported_system_features=("benchmark", "big-parallel", "kvm", "nixos-test"),
    ),
    Builder(
        name="fw",
        store_path="ssh-ng://fw",
        system_types=("x86_64-linux", "aarch64-linux"),
        jobs=16,
        supported_system_features=("benchmark", "big-parallel", "kvm", "nixos-test"),
    ),
)

PROGRAM_NAME: typing.Final[str] = "with-nix-config"

def warn_print(
    first_arg: object,
    *args: object,
    sep: str | None = " ",
    end: str | None = "\n",
    file: SupportsWrite[str] | None = sys.stderr,
) -> None:
    return print(
        f"{PROGRAM_NAME}: warn: {first_arg}",
        *args,
        sep=sep,
        end=end,
        file=file,
    )

parser = argparse.ArgumentParser(
    prog=PROGRAM_NAME,
    description="execs {command} with the env var NIX_CONFIG set according to the given options. Will append to NIX_CONFIG if already set",
)
parser.add_argument(
    "-n",
    "--no-local",
    action="store_true",
    help="don't build on the local machine",
)
parser.add_argument(
    "-s",
    "--single-substituter",
    action="store_true",
    help="remove all substituters except the default, ie sets substituters = https://cache.nixos.org",
)
parser.add_argument(
    "--self-builder",
    action="store_true",
    help="set max-jobs=0 and add the local machine to builders. This allows setting a speed factor for the local machine",
)
parser.add_argument(
    "--self-builder-jobs",
    nargs=1,
)
parser.add_argument(
    "--self-builder-speed-factor",
    nargs=1,
    type=float,
)
parser.add_argument(
    "-o",
    "--option",
    action="append",
    nargs=2,
    dest="extra_options",
    default=[],
    metavar=("KEY","VALUE"),
    help="set an arbitrary option; `KEY = VALUE` is appended to NIX_CONFIG. can be specified multiple times",
)
for b in BUILDERS:
    parser.add_argument(
        *(f"--{n}" for n in b.names()),
        dest=b.name,
        action="store_true",
        help=f"build on {b.name}",
    )
    parser.add_argument(
        *(f"--{n}-jobs" for n in b.names()),
        dest=f"{b.name}_jobs",
        nargs=1,
        metavar="COUNT",
        type=int,
    )
    parser.add_argument(
        *(f"--{n}-speed-factor" for n in b.names()),
        dest=f"{b.name}_speed_factor",
        nargs=1,
        metavar="FACTOR",
        type=float,
    )

parser.add_argument("command", nargs=argparse.REMAINDER, metavar="command...")

args = parser.parse_args()

if not args.command:
    parser.error("no command given")

if args.self_builder and args.no_local:
    parser.error("--self-builder and --no-local can't be used together")

HOSTNAME = os.environ.get("HOSTNAME","")

for b in BUILDERS:
    if getattr(args, b.name) and HOSTNAME == b.name:
        base_msg = f"specified to build on remote builder {b.name}, but we are on {b.name}"
        if args.no_local:
            parser.error(f"{base_msg}, and --no-local was specified")
        else:
            warn_print(base_msg)

new_config: list[tuple[str, str]] = []

new_config.append(("builders-use-substitutes", "true"))

builders_list: list[Builder] = []

for b in BUILDERS:
    if getattr(args, b.name):
        overrides:dict[str, typing.Any] = {}
        for attr in ("jobs", "speed_factor"):
            arg = getattr(args, f"{b.name}_{attr}")
            if arg is not None:
                overrides[attr] = arg
        builders_list.append(dataclasses.replace(b, **overrides))

if args.self_builder:
    new_config.append(("max-jobs", "0"))
    old_config_full = run("nix", "--extra-experimental-features", "nix-command", "config", "show", "--json").json().must_succeed()
    old_config:dict[str, typing.Any] = {name: data["value"] for (name, data) in old_config_full.items()}
    system:str = old_config["system"]
    extra_platforms:list[str] = old_config["extra-platforms"]
    jobs:int = old_config["max-jobs"]
    if args.self_builder_jobs is not None:
        jobs = args.self_builder_jobs
    system_features:list[str] = old_config["system-features"]
    builders_list.append(
        Builder(
            name=HOSTNAME,
            store_path="auto",
            system_types=(system, *extra_platforms),
            identity_file=None,
            jobs=jobs,
            speed_factor=args.self_builder_speed_factor,
            supported_system_features=(*system_features,),
        )
    )


if len(builders_list) > 0:
    val = ";".join(x.serialize() for x in builders_list)
    new_config.append(("builders", val))

if args.no_local:
    new_config.append(("max-jobs", "0"))

if args.single_substituter:
    new_config.append(("substituters", "https://cache.nixos.org/"))

config_names: set[str] = set(k for (k, _) in new_config)

for [k, v] in args.extra_options:
    if k in config_names:
        parser.error(f"conflict: {k} set by --option already set")
    new_config.append((k, v))

new_environ = {k: v for (k, v) in os.environ.items()}

if len(new_config) > 0:
    val = os.environ.get("NIX_CONFIG", "")

    if val != "" and val[-1] != "\n":
        val += "\n"

    val += "\n".join(f"{k} = {v}" for (k, v) in new_config)
    new_environ["NIX_CONFIG"] = val
else:
    print(f"{parser.prog}: warning, no nix config applied (NIX_CONFIG unchanged)", file=sys.stderr)

os.execvpe(args.command[0], args.command, new_environ)
