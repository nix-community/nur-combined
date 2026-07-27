import os

if "PREFIX_PYTHON_MODULES_DEBUG" in os.environ:
    import pdb

    pdb.set_trace()

import argparse
import fnmatch
import shutil
import sys
import tempfile
import textwrap
import traceback
from pathlib import Path
from typing import List, Literal, Optional, Tuple

from rope.base.project import Project
from rope.refactor.move import MoveModule
from rope.refactor.rename import Rename

parser = argparse.ArgumentParser("prefix-python-modules")
parser.add_argument("repo_root", type=Path)
parser.add_argument(
    "--rename-external",
    nargs=3,
    action="append",
    help="Takes (old_name, new_name, glob), e.g.:"
    ' --rename-external utils dino.utils "**/extract_dino_features.py"',
)
parser.add_argument("-e", "--exclude-glob", action="append")
parser.add_argument("--dont-catch", action="store_true")
parser.add_argument("--prefix", required=True)
parser.add_argument("--verbose", action="store_true")
parser.add_argument("--quiet", action="store_true")
parser.add_argument(
    "--mode",
    default="first-error",
    choices=("first-error", "keep-going", "interactive"),
)

CATCH_ERRORS = True


def indent(s: str, n: int = 4) -> str:
    return textwrap.indent(s, " " * n)


def convert_to_packages(project_root, exclude_globs: List[str]):
    project = Project(project_root)
    python_files = [p for p in project.get_python_files()]
    python_files = [
        p for p in python_files if not fnmatch_any_glob(p.path, exclude_globs)
    ]

    try:
        for f in python_files:
            rel_path = Path(f.path)
            while rel_path.parent != Path("."):
                path = project_root / rel_path.parent / "__init__.py"
                path.touch()
                rel_path = rel_path.parent
    finally:
        project.close()


def apply_changes(
    project,
    changes,
    mode: Literal["first-error", "keep-going", "interactive"],
) -> Tuple[
    Optional[Literal["quit", "next"]],
    Optional[str],
    Optional[Exception],
    Optional[str],
]:
    description = changes.get_description()

    while True:
        try:
            if mode == "interactive":
                print("Apply the following patch?")
                print(indent(description))
                print("[Y]es, [n]o, [q]uit? [Ynq]")
                action = input().lower().strip()
                if action == "":
                    action = "y"
                assert action in "ynq", action
                if action == "n":
                    return ("next", None, None, None)
                elif action == "q":
                    return ("quit", None, None, None)
            project.do(changes)
            project.validate()
        except Exception as e:
            if not CATCH_ERRORS:
                raise
            if mode != "interactive":
                return (None, description, e, traceback.format_exc())

            keep_asking = True
            action = "q"
            while keep_asking:
                print(
                    f"Failed to apply the patch: {e}\n"
                    "...[r]etry, print [v]erbose error, skip and proceed to the [n]ext patch, or [Q]uit? [rvnQ]"
                )
                action = input().lower().strip()
                if action == "":
                    action = "q"
                assert action in "rvnq", action
                if action == "v":
                    print(traceback.format_exc())
                    continue
                keep_asking = False
            if action == "q":
                return ("quit", description, e, traceback.format_exc())
            elif action == "n":
                return ("next", description, e, traceback.format_exc())
            else:
                continue
        else:
            return (None, description, None, None)


def fnmatch_any_glob(path, globs):
    return any(fnmatch.fnmatchcase(path, g) for g in globs)


def prefix_modules(
    project_root,
    prefix,
    *,
    mode: Literal["first-error", "keep-going", "interactive"],
    verbose: bool,
    exclude_globs: List[str],
):
    project = Project(project_root)

    parallel_tree_for_rope = tempfile.mkdtemp()

    try:
        project.validate()

        python_files = [p for p in project.get_python_files()]
        python_files = [p for p in python_files if Path(p.path).parts[0] != prefix]
        python_files = [
            p for p in python_files if not fnmatch_any_glob(p.path, exclude_globs)
        ]

        toplevel_files = sorted(set(Path(p.path).parts[0] for p in python_files))
        toplevel_module_names = [name.removesuffix(".py") for name in toplevel_files]

        assert all("-" not in x for x in toplevel_module_names), toplevel_module_names

        new_package = project.get_folder(prefix)
        if not new_package.exists():
            new_package.create()
            new_package.create_file("__init__.py")

        successes = []
        failures = []
        for name in toplevel_module_names:
            m = project.get_module(name)
            r = m.get_resource()

            old_path = r.pathlib

            try:
                changes = MoveModule(project, r).get_changes(new_package)
            except:
                print(
                    "Fatal error: coudln't prepare a MoveModule for"
                    f" {name} -> {new_package.path}.{name}"
                )
                raise
            (action, description, error, tb) = apply_changes(
                project, changes, mode=mode
            )

            if error is not None and verbose:
                failures.append((description, tb))
            elif error is not None:
                failures.append((description, error))
            if error is None and description is not None:
                successes.append(description)
                continue

            if action == "quit":
                parser.exit(0)
            elif action == "next":
                continue

            if error is not None and mode == "first-error":
                break

            assert not old_path.exists()

        return successes, failures
    finally:
        project.close()
        shutil.rmtree(parallel_tree_for_rope, ignore_errors=True)


def rename_external(
    project_root,
    old_name,
    new_name,
    pattern,
    mode,
    quiet,
    exclude_globs: List[str],
):
    if not quiet:
        print(
            f"rename_external({repr(project_root)}, {repr(old_name)}, {repr(new_name)}, {repr(pattern)})"
        )
    project = Project(project_root)

    old_parts = old_name.split(".")
    old_path = Path(*old_parts)

    resources = project.get_python_files()
    resources = [p for p in resources if fnmatch.fnmatchcase(p.path, pattern)]
    resources = [p for p in resources if not fnmatch_any_glob(p.path, exclude_globs)]

    fake_package = tempfile.mkdtemp()
    sys.path.append(fake_package)

    os.makedirs(Path(fake_package) / old_path)
    (Path(fake_package) / old_path / "__init__.py").touch()

    old_mod = project.find_module(old_name)

    changes = Rename(project, old_mod).get_changes(new_name, resources=resources)

    try:
        return apply_changes(project, changes, mode=mode)
    finally:
        project.close()
        shutil.rmtree(fake_package, ignore_errors=True)
        sys.path.remove(fake_package)


def main():
    args = parser.parse_args()

    global CATCH_ERRORS
    CATCH_ERRORS = not args.dont_catch

    exclude_globs = args.exclude_glob or []

    successes, failures = [], []

    for old_name, new_name, pattern in args.rename_external or []:
        action, description, error, tb = rename_external(
            args.repo_root,
            old_name,
            new_name,
            pattern,
            mode=args.mode,
            quiet=args.quiet,
            exclude_globs=exclude_globs,
        )
        if error is not None:
            failures.append((description, error if args.quiet else tb))
        if error is None and description is not None:
            successes.append(description)
        elif action == "next":
            continue
        elif action == "quit":
            parser.exit(0)

    convert_to_packages(args.repo_root, exclude_globs=exclude_globs)

    _successes, _failures = prefix_modules(
        args.repo_root,
        args.prefix,
        mode=args.mode,
        verbose=args.verbose,
        exclude_globs=exclude_globs,
    )
    successes.extend(_successes)
    failures.extend(_failures)

    if args.mode != "interactive" and not args.quiet:
        for description in successes:
            print("Successfully applied the patch:")
            print(indent(description))

        for description, e in failures:
            print("Failed to apply the patch:")
            print(indent(description))
            print(f"The error was: ({type(e).__name__}) {e}")

    if not args.quiet and failures:
        print(f"Observed the total of {len(failures)} failures")

    if failures:
        parser.exit(1)


if __name__ == "__main__":
    main()
