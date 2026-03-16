#!/usr/bin/env python3
import argparse
import ast
import os
import re
import shutil
import subprocess
import sys
import textwrap
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional


@dataclass
class NvfetcherDefinition:
    pname: str
    version: str
    src: str

    @property
    def src_func(self) -> str:
        return re.search(r"^(\S+)", self.src)[1]

    def src_with_version_replacement(self, final_attrs: bool = False):
        version_eval = ast.literal_eval(self.version)
        if final_attrs:
            src = self.src.replace(version_eval, "${finalAttrs.version}")
            src = src.replace('"${finalAttrs.version}"', "finalAttrs.version")
        else:
            src = self.src.replace(version_eval, "${version}")
            src = src.replace('"${version}"', "version")
        return src

    @staticmethod
    def load(package: str) -> "NvfetcherDefinition":
        with open("_sources/generated.nix") as f:
            nvfetcher_generated = f.read()

        regex = r"^  " + package + r" = \{\n((.|\n)+?)\n  };$"
        result = re.search(
            regex,
            nvfetcher_generated,
            re.MULTILINE,
        )[1]

        pname = re.search(r"^\s+pname\s+=\s+(.+);$", result, re.MULTILINE)[1]
        version = re.search(r"^\s+version\s+=\s+(.+);$", result, re.MULTILINE)[1]
        src = re.search(r"^\s+src\s+=\s+((.|\n)+?\n\s+\});$", result, re.MULTILINE)[1]

        if version.startswith('"v'):
            version = '"' + version[2:]
        if version.startswith('"V'):
            version = '"' + version[2:]

        date_match = re.search(r"^\s+date\s+=\s+\"(.+)\";$", result, re.MULTILINE)
        if date_match:
            if re.match(r"\"[0-9a-f]{40}\"", version):
                try:
                    stable_definition = NvfetcherDefinition.load(f"{package}-stable")
                    base_version = ast.literal_eval(stable_definition.version)
                except Exception:
                    base_version = "0"
                version = f'"{base_version}-unstable-{date_match[1]}"'

        return NvfetcherDefinition(
            pname=pname,
            version=version,
            src=src,
        )


def find_nvfetcher_references(nix_file: str) -> Iterable[str]:
    return list(
        dict.fromkeys(re.findall(r"[^a-z]+sources\.([a-zA-Z0-9_-]+)[^a-z]+", nix_file))
    )


def substitute_nvfetcher_references(
    nix_file: str, ref_name: str, ref_value: NvfetcherDefinition
) -> str:
    result = nix_file
    use_final_attrs = "finalAttrs:" in result
    print(f"use_final_attrs: {use_final_attrs}")

    # Step 1: replace "inherit (sources.xxx) pname version src;"
    def replace_inherit(match: re.Match[str]) -> str:
        fields = re.split(r"\s+", match[1])
        result = ""

        if "pname" in fields:
            result += f"pname = {ref_value.pname};\n"
        if "version" in fields:
            result += f"version = {ref_value.version};\n"
        if "src" in fields:
            result += (
                f"src = {ref_value.src_with_version_replacement(use_final_attrs)};\n"
            )

        return result

    regex = r"^\s+inherit \(sources\." + ref_name + r"\) ((.|\n)+?);$"
    result = re.sub(regex, replace_inherit, result, flags=re.MULTILINE)

    # Step 2: replace direct references to sources.xxx.pname/version/src
    def replace_direct_reference(match: re.Match[str]) -> str:
        if match[2] == "pname":
            result = ref_value.pname
        elif match[2] == "version":
            result = ref_value.version
        elif match[2] == "src":
            result = f"{ref_value.src_with_version_replacement(use_final_attrs)}"
        else:
            result = match[2]

        return match[1] + result + match[3]

    regex = r"^([^#]+)sources\." + ref_name + r"\.([a-zA-Z0-9]+)([^a-zA-Z0-9]+)"
    result = re.sub(regex, replace_direct_reference, result, flags=re.MULTILINE)

    # Step 3: replace direct references to sources.xxx
    # Do not include pname since only case this will happen is multi source for multiarch packages
    def replace_direct_reference_entire_obj(match: re.Match[str]) -> str:
        result = textwrap.dedent(
            f"""
                rec {{
                    version = {ref_value.version};
                    src = {ref_value.src_with_version_replacement(use_final_attrs)};
                }}
            """
        ).strip()
        return match[1] + result + match[2]

    regex = r"^([^#]+)sources\." + ref_name + r"(\s+)"
    result = re.sub(
        regex, replace_direct_reference_entire_obj, result, flags=re.MULTILINE
    )

    # Step 4: inject function used to obtain src
    if re.search(r"^\s*#\s*" + ref_value.src_func + r",", result, re.MULTILINE):
        print("Uncomment existing placeholder...")
        result = re.sub(
            r"^\s*#\s*" + ref_value.src_func + r",",
            ref_value.src_func + ",",
            result,
            1,
            re.MULTILINE,
        )
    elif re.search(ref_value.src_func + r",", result):
        print(f"{ref_value.src_func} already in args")
    else:
        print(f"Inserting arg of {ref_value.src_func}")
        result = result.replace("{", "{" + ref_value.src_func + ",", 1)

    # Step 5: remove sources import
    result = re.sub(r"\s+sources,\s+", "", result, count=1)

    # Step 6: remove inherit sources
    result = re.sub(r"inherit\s+sources\s*;", "", result)

    return result


def format_with_nixfmt(nix_file: str) -> str:
    p = subprocess.Popen(
        ["nixfmt"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    return p.communicate(nix_file)[0]


def nixpkgs_get_existing_version(nixpkgs_path: str, package_name: str) -> Optional[str]:
    subprocess.run(["git", "-C", nixpkgs_path, "checkout", "master"], check=True)
    subprocess.run(["git", "-C", nixpkgs_path, "fetch", "upstream"], check=True)
    subprocess.run(
        ["git", "-C", nixpkgs_path, "reset", "--hard", "upstream/master"], check=True
    )

    try:
        return subprocess.run(
            [
                "nix-instantiate",
                "--eval",
                "-E",
                'with import ./. {  }; pkgs."' + package_name + '".version',
            ],
            stdout=subprocess.PIPE,
            check=True,
            text=True,
            cwd=nixpkgs_path,
            env={
                **os.environ,
                "NIXPKGS_ALLOW_UNFREE": "1",
                "NIXPKGS_ALLOW_INSECURE": "1",
            },
        ).stdout.strip()
    except subprocess.CalledProcessError:
        return None


def nixpkgs_create_branch(nixpkgs_path: str, package_name: str):
    try:
        subprocess.run(
            ["git", "-C", nixpkgs_path, "checkout", "-b", package_name], check=True
        )
    except subprocess.CalledProcessError:
        subprocess.run(
            ["git", "-C", nixpkgs_path, "checkout", package_name], check=True
        )
    subprocess.run(
        ["git", "-C", nixpkgs_path, "reset", "--hard", "upstream/master"], check=True
    )


def nixpkgs_create_package(nixpkgs_path: str, package_name: str) -> Path:
    pkg_path = (
        Path(nixpkgs_path) / "pkgs" / "by-name" / package_name[0:2] / package_name
    )
    os.makedirs(pkg_path, exist_ok=True)

    return pkg_path


def nixpkgs_create_commit(nixpkgs_path: str, commit_message: str):
    subprocess.run(["git", "-C", nixpkgs_path, "add", nixpkgs_path], check=True)
    subprocess.run(["git", "-C", nixpkgs_path, "status"], check=True)
    subprocess.run(
        ["git", "-C", nixpkgs_path, "commit", "-m", commit_message], check=True
    )


def nixpkgs_test_build(nixpkgs_path: str, package_name: str):
    subprocess.run(
        ["nix-build", "-A", package_name],
        check=True,
        cwd=nixpkgs_path,
        env={
            **os.environ,
            "NIXPKGS_ALLOW_UNFREE": "1",
            "NIXPKGS_ALLOW_INSECURE": "1",
        },
    )


def _get_current_branch_name(nixpkgs_path: str) -> str:
    return subprocess.run(
        ["git", "-C", nixpkgs_path, "rev-parse", "--abbrev-ref", "HEAD"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout.strip()


def nixpkgs_push(nixpkgs_path: str, package_name: str):
    subprocess.run(
        [
            "git",
            "-C",
            nixpkgs_path,
            "push",
            "-u",
            "origin",
            _get_current_branch_name(nixpkgs_path),
            "--force",
        ],
        check=True,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="auto_pr.py",
        description="Script to automatically create PRs for NUR packages",
    )
    parser.add_argument("package_path", help="Path to the package in NUR")
    parser.add_argument(
        "--dest",
        help="Custom target folder (full path) in nixpkgs, if unset, will use pkgs/by-name",
    )
    parser.add_argument(
        "--nixpkgs-path",
        help="Path to nixpkgs clone",
        metavar="PATH",
        default="/home/lantian/Projects/nixpkgs-xddxdd",
    )
    parser.add_argument(
        "--no-branch",
        help="Do not create Git branch automatically",
        action="store_true",
    )
    parser.add_argument(
        "--no-commit",
        help="Do not create Git commit automatically. Default to on if dest is set",
        action="store_true",
    )
    parser.add_argument(
        "--no-build",
        help="Do not try to build final package",
        action="store_true",
    )
    parser.add_argument(
        "--no-push",
        help="Do not push changes automatically. Default to on if dest is set",
        action="store_true",
    )
    args = parser.parse_args()

    nur_pkg_path = Path(args.package_path)
    if not nur_pkg_path.is_dir():
        raise ValueError("NUR package path should be a directory")

    pkg_name = nur_pkg_path.name
    if not pkg_name:
        raise ValueError("Invalid path")

    if not args.no_branch:
        existing_pkg_version = nixpkgs_get_existing_version(args.nixpkgs_path, pkg_name)
        print(f"Existing version is {existing_pkg_version}")

        nixpkgs_create_branch(args.nixpkgs_path, pkg_name)
    else:
        existing_pkg_version = None

    if args.dest:
        custom_target_path = True
        nixpkgs_pkg_path = Path(args.dest)
        os.makedirs(nixpkgs_pkg_path, exist_ok=True)
    else:
        custom_target_path = False
        nixpkgs_pkg_path = nixpkgs_create_package(args.nixpkgs_path, pkg_name)

    pkg_version = None

    for f in nur_pkg_path.iterdir():
        nixpkgs_target_path = nixpkgs_pkg_path / f.relative_to(nur_pkg_path)

        # Do not override file name if custom target path, which indicates by-name is not used
        if not custom_target_path and f.name == "default.nix":
            nixpkgs_target_path = nixpkgs_target_path.parent / "package.nix"

        if f.name.startswith("update."):
            # Do not copy update script specific to this repo
            pass
        elif not f.name.endswith(".nix"):
            shutil.copyfile(f, nixpkgs_target_path)
        else:
            with open(f) as fd:
                nix_file = fd.read()

            references = find_nvfetcher_references(nix_file)
            for ref in references:
                definition = NvfetcherDefinition.load(ref)
                if not pkg_version:
                    pkg_version = definition.version
                nix_file = substitute_nvfetcher_references(nix_file, ref, definition)

            nix_file = format_with_nixfmt(nix_file)
            with open(nixpkgs_target_path, "w") as fd:
                fd.write(nix_file)

    if existing_pkg_version:
        version_from = f"{ast.literal_eval(existing_pkg_version)} ->"
    else:
        version_from = "init at"

    if pkg_version:
        version_to = ast.literal_eval(pkg_version)
    else:
        version_to = "[UNKNOWN VERSION]"

    if not args.no_commit and not custom_target_path:
        nixpkgs_create_commit(
            args.nixpkgs_path, f"{pkg_name}: {version_from} {version_to}"
        )
        if not args.no_build:
            nixpkgs_test_build(args.nixpkgs_path, pkg_name)
        if not args.no_push:
            nixpkgs_push(args.nixpkgs_path, pkg_name)
