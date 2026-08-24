import argparse
import os
import dataclasses
import sys
import typing
from pathlib import Path

_T_contra = typing.TypeVar("_T_contra", contravariant=True)

class SupportsWrite(typing.Protocol[_T_contra]):
    def write(self, s: _T_contra, /) -> object: ...


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
    "-p",
    "--prophecy",
    "--prop",
    action="store_true",
    help="build on prophecy",
)
parser.add_argument(
    "-f",
    "--fw",
    action="store_true",
    help="build on fw",
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
    "-o",
    "--option",
    action="append",
    nargs=2,
    dest="extra_options",
    default=[],
    metavar=("KEY","VALUE"),
    help="set an arbitrary option; `KEY = VALUE` is appended to NIX_CONFIG. can be specified multiple times",
)
parser.add_argument("command", nargs=argparse.REMAINDER, metavar="command...")

args = parser.parse_args()

if not args.command:
    parser.error("no command given")

HOSTNAME = os.environ.get("HOSTNAME","")

for hostname in ("prophecy", "fw"):
    if getattr(args, hostname) and HOSTNAME == hostname:
        base_msg = f"specified to build on remote builder {hostname}, but we are on {hostname}"
        if args.no_local:
            parser.error(f"{base_msg}, and --no-local was specified")
        else:
            warn_print(base_msg)

new_config: list[tuple[str, str]] = []

new_config.append(("builders-use-substitutes", "true"))


@dataclasses.dataclass(frozen=True)
class Builder:
    store_path: str
    system_types: list[str] | None = None
    identity_file: str | Path | None = None
    build_count: int | None = None
    speed_factor: int | None = None
    supported_system_features: list[str] | None = None
    required_system_features: list[str] | None = None
    host_key: str | None = None

    def serialize(self) -> str:
        components_diverse: list[str | Path | list[str] | int | None] = [
            self.store_path,
            self.system_types,
            self.identity_file,
            self.build_count,
            self.speed_factor,
            self.supported_system_features,
            self.required_system_features,
            self.host_key,
        ]

        def conv(el: str | Path | list[str] | int | None) -> str:
            if el is None:
                return "-"
            if isinstance(el, (Path, int)):
                return str(el)
            if isinstance(el, list):
                return ",".join(el)
            return el

        components: list[str] = [conv(x) for x in components_diverse]

        while components[-1] == "-":
            components.pop()

        return " ".join(components)

BUILDERS_PROPHECY:Builder = Builder(
    store_path="ssh-ng://prophecy",
    system_types=["x86_64-linux", "aarch64-linux"],
    build_count=22,
    supported_system_features=["benchmark", "big-parallel", "kvm", "nixos-test"],
)

BUILDERS_FW:Builder = Builder(
    store_path="ssh-ng://fw",
    system_types=["x86_64-linux", "aarch64-linux"],
    build_count=16,
    supported_system_features=["benchmark", "big-parallel", "kvm", "nixos-test"],
)


builders_list: list[Builder] = []

if args.prophecy:
    builders_list.append(BUILDERS_PROPHECY)

if args.fw:
    builders_list.append(BUILDERS_FW)

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
