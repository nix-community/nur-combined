from __future__ import annotations
import argparse
import shutil
import tempfile
import abc
import contextlib
from enum import Enum
from types import TracebackType
import typing
from typing import Iterator, Iterable, Protocol, Self, Final
from collections import OrderedDict, defaultdict

from scriptipy import *
import humanfriendly
import nixdata


class HasItems[K, V](Protocol):
    def items(self) -> Iterator[tuple[K, V]]: ...


def pydantic_parse_as[T](typ: type[T], val: object, /) -> T:
    return pydantic.TypeAdapter(typ).validate_python(val)


@contextlib.contextmanager
def error_context(msg: str):
    try:
        yield
    except Exception as ex:
        full_msg: str
        if ex.args:
            full_msg = f"{msg}: {ex.args[0]}"
        else:
            full_msg = msg
        ex.args = (full_msg,) + ex.args[1:]
        raise


class BuildInfo(pydantic.BaseModel):
    broken: bool
    impure: bool
    allSystems: list[str]
    aliases: list[str]


class InputDerivationInfo(pydantic.BaseModel):
    dynamicOutputs: dict[object, object]  # no idea what this is for
    outputs: list[
        str
    ]  # a list of output names like "out", "man". The outputs that are depended upon.


class OutputInfo(pydantic.BaseModel):
    path: Path


# see https://nix.dev/manual/nix/2.33/protocols/json/derivation/index.html
class DerivationInfo(pydantic.BaseModel):
    args: list[str]
    builder: str
    env: dict[str, str]
    inputDrvs: dict[Path, InputDerivationInfo]
    inputSrcs: list[Path]
    name: str
    outputs: dict[str, OutputInfo]
    system: str

    def iter_outputs(self) -> Iterator[tuple[str, Path]]:
        for output_name, output_info in self.outputs.items():
            yield output_name, output_info.path


# the expected return value of `nix derivation show`
NixDerivationShowResult = dict[Path, DerivationInfo]


class SingleBuild(pydantic.BaseModel):
    drvPath: Path
    # key is the output name like "out" or "man"
    # value is the nix store path like "/nix/store/a5mjvh6l75533g2gfy984vpyc45zipfw-nix-2.31.2-man"
    outputs: dict[str, Path]


# the expected return value of `nix build --json`
NixBuildResult = list[SingleBuild]


build_infos: dict[str, BuildInfo] = {
    name: pydantic_parse_as(BuildInfo, x) for name, x in nixdata.builds.items()
}

print(f"{build_infos=}")

alias_to_name = {
    alias: name for name, data in build_infos.items() for alias in data.aliases
}

all_systems = set(system for v in build_infos.values() for system in v.allSystems)


def comma_separated(arg: str) -> list[str]:
    if arg == "":
        return []
    return arg.split(",")


parser = argparse.ArgumentParser(prog="archive")
parser.add_argument("--min-space", default="50G")
parser.add_argument("--systems", type=comma_separated)
parser.add_argument("--include-broken", action=argparse.BooleanOptionalAction)
parser.add_argument("builds", nargs="*")
args = parser.parse_args()
min_space_bytes = humanfriendly.parse_size(args.min_space)
min_space_text = humanfriendly.format_size(min_space_bytes)

systems: set[str]

if args.systems is None:
    systems = all_systems
else:
    systems = set(args.systems)
    for s in systems:
        if s not in all_systems:
            die(f"Unrecognized system {s!r}; expected one of {all_systems!r}")

if len(systems) == 0:
    die("specified no systems, nothing to do???")

which_builds: set[str]
specified_builds = len(args.builds) > 0

if specified_builds:
    which_builds = set()
    for build_name in args.builds:
        if build_name in build_infos:
            which_builds.add(build_name)
        elif build_name in alias_to_name:
            which_builds.add(alias_to_name[build_name])
        else:
            die(f"unrecognized build {build_name!r}")
else:
    which_builds = set(build_infos.keys())

if len(which_builds) == 0:
    die("specified no builds, nothing to do???")

include_broken: bool
if args.include_broken is None:
    include_broken = specified_builds
else:
    include_broken = args.include_broken


def clean_if_space_needed():
    usage = shutil.disk_usage("/nix/store")
    if usage.free < min_space_bytes:
        free_space_text = humanfriendly.format_size(usage.free)
        print(
            f"free space ({free_space_text}) is less than min ({min_space_text}), running a gc"
        )
        run("nix", "store", "gc").must_succeed()
    usage = shutil.disk_usage("/nix/store")
    if usage.free < min_space_bytes:
        die("Couldn't clear enough storage, bailing")


@dataclass(frozen=True)
class EvalArgs:
    impure: bool

    @classmethod
    def default(cls) -> Self:
        return cls(impure=False)

    def to_args(self) -> list[str]:
        if self.impure:
            return ["--impure"]
        else:
            return []


class EvalResultBase(metaclass=abc.ABCMeta):
    is_success: bool


@dataclass(frozen=True)
class EvalSuccess(EvalResultBase):
    drvs: dict[Path, DerivationInfo]

    is_success = True


@dataclass(frozen=True)
class EvalFail(EvalResultBase):
    is_success = False


EvalResult = EvalSuccess | EvalFail


class BuildResult(Enum):
    OK = "ok"
    CACHED = "cached"
    FAIL = "fail"
    DEPENDENCY_FAIL = "dependency-fail"

    def usable(self) -> bool:
        return self == self.OK or self == self.CACHED


@dataclass(frozen=True)
class ResultInt:
    raw: int

    def __int__(self) -> int:
        return self.raw

    def __str__(self) -> str:
        return self.raw.__str__()


result_int_counter: int = 1

BINARY_CACHE_PATH: Final = Path("/propdata/nixcache")
NIX_STORE_PATH: Final = Path("/nix/store")


@dataclass(frozen=True)
class StorePathComponents:
    nar_hash: str
    name: str


def parse_store_path(store_path: Path) -> StorePathComponents:
    assert store_path.parent == NIX_STORE_PATH
    pieces = store_path.name.split("-", 1)
    assert len(pieces) == 2
    nar_hash, name = pieces
    return StorePathComponents(nar_hash=nar_hash, name=name)


def allocate_result_int() -> ResultInt:
    global result_int_counter
    res = result_int_counter
    result_int_counter += 1
    return ResultInt(res)


def find_paths_with_prefix(prefix: Path) -> Iterator[Path]:
    assert prefix.name != ""
    for p in prefix.parent.iterdir():
        if p.name.startswith(prefix.name):
            yield p


def unique_and_sorted_equal[T](a: Iterable[T], b: Iterable[T]) -> bool:
    a_set: set[T] = set()
    b_set: set[T] = set()
    for iterator, s in ((a, a_set), (b, b_set)):
        for item in iterator:
            if item in s:
                return False
            s.add(item)
    return a_set == b_set


class BuildManager:
    store_path_status: dict[Path, BuildResult] = dict()

    to_eval: dict[str | Path, EvalArgs] = dict()
    eval_done: dict[str | Path, EvalResult] = dict()

    to_build: OrderedDict[Path, DerivationInfo] = OrderedDict()
    build_done: dict[Path, BuildResult] = dict()

    # key: store path to copy
    # val: path to symlink
    to_copy: dict[Path, Path] = dict()
    copy_done: set[Path] = set()

    work_dir_obj = tempfile.TemporaryDirectory(prefix="vacu-archive-work-dir")

    @staticmethod
    def _binary_cache_has_impl(store_path: Path) -> bool:
        h = parse_store_path(store_path).nar_hash
        return (BINARY_CACHE_PATH / f"{h}.narinfo").exists()

    def binary_cache_has(self, store_path: Path) -> bool:
        res = self._binary_cache_has_impl(store_path)
        if res and store_path not in self.store_path_status:
            self.store_path_status[store_path] = BuildResult.CACHED
        return res

    def add_eval(self, installable: str | Path, args: EvalArgs, /) -> None:
        if (installable in self.eval_done) or (installable in self.to_eval):
            return
        self.to_eval[installable] = args

    def add_build(self, drv_path: Path, drv_info: DerivationInfo) -> None:
        if drv_path in self.to_build:
            self.to_build.move_to_end(drv_path)
            return
        if drv_path in self.build_done:
            return
        self.to_build[drv_path] = drv_info

    def add_copy(self, store_path: Path, maybe_symlink: Path | None = None, /) -> None:
        if self.binary_cache_has(store_path):
            self.copy_done.add(store_path)
        if (store_path in self.copy_done) or (store_path in self.to_copy):
            if maybe_symlink is not None:
                assert maybe_symlink.is_symlink()
                maybe_symlink.unlink()
            return
        symlink: Path
        if maybe_symlink is not None:
            symlink = maybe_symlink
        else:
            ref = allocate_result_int()
            run(
                "nix", "build", "--out-link", self.result_prefix(ref), store_path
            ).must_succeed()
            all_out_links = list(find_paths_with_prefix(self.result_prefix(ref)))
            assert len(all_out_links) == 1
            symlink = all_out_links[0]
            assert symlink == self.result_prefix(ref)
            assert symlink.is_symlink()
        self.to_copy[store_path] = symlink

    def run_eval_step(self) -> None:
        ins, eval_args = self.to_eval.popitem()
        eval_command = ["nix", "derivation", "show"]
        eval_command += eval_args.to_args()
        eval_command += ["--", ins]
        eval_res = run(*eval_command).json()
        if not eval_res.success():
            self.eval_done[ins] = EvalFail()
            return
        drvs = pydantic_parse_as(NixDerivationShowResult, eval_res.stdout)
        self.eval_done[ins] = EvalSuccess(drvs=drvs)
        for drv_path, drv_info in drvs.items():
            self.eval_done[drv_path] = EvalSuccess(drvs={drv_path: drv_info})
            self.add_copy(drv_path)  # copy the derivation file itself
            all_in_cache = all(
                self.binary_cache_has(x.path) for x in drv_info.outputs.values()
            )
            if not all_in_cache:
                self.add_build(drv_path, drv_info)
            elif drv_path not in self.build_done:
                self.build_done[drv_path] = BuildResult.CACHED
            for idrv_path in drv_info.inputDrvs.keys():
                self.add_eval(idrv_path, EvalArgs.default())
            for src in drv_info.inputSrcs:
                self.add_copy(src)
        return

    def run_build_step(self) -> None:
        drv_path, drv_info = self.to_build.popitem()

        def inner() -> BuildResult:
            for idrv_path in drv_info.inputDrvs.keys():
                if (
                    res := self.build_done.get(idrv_path)
                ) is not None and not res.usable():
                    return BuildResult.DEPENDENCY_FAIL
            for src in drv_info.inputSrcs:
                if (
                    res := self.store_path_status.get(src)
                ) is not None and not res.usable():
                    return BuildResult.DEPENDENCY_FAIL
            ref = allocate_result_int()
            result_prefix = self.result_prefix(ref)
            res = run(
                "nix",
                "build",
                "-L",
                "-v",
                "-j1",
                "--out-link",
                result_prefix,
                "--json",
                "--option",
                "timeout",
                str(60 * 60 * 4),
                str(drv_path) + "^*",
            ).json()
            if not res.success():
                return BuildResult.FAIL
            actual_out_links = list(find_paths_with_prefix(result_prefix))
            expected_out_links: list[Path] = []
            builds = pydantic_parse_as(NixBuildResult, res.stdout)
            for build in builds:
                for output_name, store_path in build.outputs.items():
                    expected_out_link: Path
                    if output_name == "out":
                        expected_out_link = result_prefix
                    else:
                        expected_out_link = result_prefix.with_name(
                            f"{result_prefix.name}-{output_name}"
                        )
                    expected_out_links.append(expected_out_link)
                    assert expected_out_link.readlink() == store_path
                    self.add_copy(store_path, expected_out_link)
            assert unique_and_sorted_equal(actual_out_links, expected_out_links)
            return BuildResult.OK

        build_result = inner()
        self.build_done[drv_path] = build_result
        for _, out_path in drv_info.iter_outputs():
            self.store_path_status[out_path] = BuildResult.FAIL

    def run_copy(self) -> None:
        if len(self.to_copy) == 0:
            return
        # at this stage, copy is not expected to fail for derivation-specific reasons, so do all in one command
        to_copy = self.to_copy
        self.to_copy = dict()
        run("into-nix-cache", "--", *to_copy.keys()).must_succeed()
        self.copy_done |= to_copy.keys()
        for result_sym in to_copy.values():
            assert result_sym.is_symlink()
            result_sym.unlink()

    def work_dir(self) -> Path:
        return Path(self.work_dir_obj.name)

    def result_prefix(self, ref: ResultInt) -> Path:
        return self.work_dir() / f"r{ref}_"

    def __enter__(self) -> Self:
        self.work_dir_obj.__enter__()  # this probably does nothing, but I figure its good practice
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None = None,
        exc_tb: TracebackType | None = None,
    ) -> bool | None:
        return self.work_dir_obj.__exit__(exc_type, exc_val, exc_tb)

    def do_build(self, installable: str | Path, impure: bool) -> str:
        self.add_eval(installable, EvalArgs(impure=impure))
        while len(self.to_eval) > 0:
            self.run_eval_step()
            while len(self.to_build) > 0:
                clean_if_space_needed()
                self.run_build_step()
                self.run_copy()
        eval_result = self.eval_done[installable]
        if not isinstance(eval_result, EvalSuccess):
            return "eval-fail"
        for drv_path in eval_result.drvs:
            return "build-" + self.build_done[drv_path].value
        return "nothing-to-build"

    def stats(self) -> str:
        eval_str: int = 0
        eval_path_success: int = 0
        eval_path_fail: int = 0
        for k, v in self.eval_done.items():
            if isinstance(k, str):
                eval_str += 1
            elif isinstance(v, EvalSuccess):
                eval_path_success += 1
            elif isinstance(v, EvalFail):  # type: ignore[reportUnnecessaryInstance]
                eval_path_fail += 1
            else:
                typing.assert_never(v)
        build_result_counts: defaultdict[BuildResult, int] = defaultdict(lambda: 0)
        for k, v in self.build_done.items():
            build_result_counts[v] += 1
        return f"""
            to_eval: {len(self.to_eval)}
            eval_done: {len(self.eval_done)}
                str: {eval_str}
                Path - success: {eval_path_success}
                Path - fail: {eval_path_fail}

            to_build: {len(self.to_build)}
            build_done: {len(self.build_done)}
                {build_result_counts!r}

            to_copy: {len(self.to_copy)}
            copy_done: {len(self.copy_done)}
        """


# def do_build(installable: str, impure: bool) -> bool:
#     eval_command = ["nix", "derivation", "show", installable]
#     if impure:
#         eval_command.append("--impure")
#     res = run(*eval_command).json()
#     if not res.success():
#         return False
#     infos = {k: DerivationInfo(**v) for k, v in res.stdout.items()}
#     for drv_path, drv_info in infos.items():
#         clean_if_space_needed()
#         with tempfile.TemporaryDirectory() as tmpdirname:
#             print(f"{installable=} {drv_path=}")
#             res = run(
#                 "nix",
#                 "build",
#                 "-j1",
#                 "--keep-going",
#                 "--out-link", f"{tmpdirname}/result",
#                 "--json",
#                 drv_path + "^*",
#             ).json()
#             if not res.success():
#                 return False
#             builds = res.stdout
#             for build in builds:
#                 for out_path in build["outputs"].values():
#                     print(f"{installable=} {out_path=}")
#                     res = run("into-nix-cache", out_path)
#                     if not res.success():
#                         return False
#     return True


results: dict[str, str] = {}
with BuildManager() as manager:
    for system in systems:
        for build_name in which_builds:
            build_data = build_infos[build_name]
            if system not in build_data.allSystems:
                continue
            if build_data.broken and not include_broken:
                print(f"Skipping {build_name}.{system}, marked broken")
                continue
            res = manager.do_build(
                f'.#.vacuBuilds."{build_name}".derivations.{system}',
                impure=build_data.impure,
            )
            results[f"{build_name}.{system}"] = res
    print(manager.stats())

for name, res_str in results.items():
    print(f"{name}: {res_str}")
