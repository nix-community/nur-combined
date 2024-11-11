#!/usr/bin/env python3
import ast
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional

NIXPKGS_PATH = os.environ.get("NIXPKGS_PATH") or "/home/lantian/Projects/nixpkgs-xddxdd"


@dataclass
class NvfetcherDefinition:
    pname: str
    version: str
    src: str

    @property
    def src_func(self) -> str:
        return re.search(r"^(\S+)", self.src)[1]

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
    return set(re.findall(r"[^a-z]+sources\.([a-zA-Z0-9_-]+)[^a-z]+", nix_file))


def substitute_nvfetcher_references(
    nix_file: str, ref_name: str, ref_value: NvfetcherDefinition
) -> str:
    result = nix_file

    # Step 1: replace "inherit (sources.xxx) pname version src;"
    def replace_inherit(match: re.Match[str]) -> str:
        fields = re.split(r"\s+", match[1])
        result = ""

        if "pname" in fields:
            result += f"pname = {ref_value.pname};\n"
        if "version" in fields:
            result += f"version = {ref_value.version};\n"
        if "src" in fields:
            result += f"src = {ref_value.src};\n"

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
            result = f"({ref_value.src})"
        else:
            result = match[2]

        return match[1] + result + match[3]

    regex = r"^([^#]+)sources\." + ref_name + r"\.([a-zA-Z0-9]+)([^a-zA-Z0-9]+)"
    result = re.sub(regex, replace_direct_reference, result, flags=re.MULTILINE)

    # Step 3: inject function used to obtain src
    regex = ref_value.src_func + r","
    if re.search(regex, result):
        pass
    else:
        result = result.replace("{", "{" + ref_value.src_func + ",", 1)

    # Step 4: remove sources import
    result = re.sub(r"\s+sources,\s+", "", result, count=1)

    # Step 5: remove inherit sources
    result = re.sub(r"inherit\s+sources\s*;", "", result)

    return result


def format_with_nixfmt(nix_file: str) -> str:
    p = subprocess.Popen(
        ["nixfmt"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    return p.communicate(nix_file)[0]


def nixpkgs_get_existing_version(package_name: str) -> Optional[str]:
    subprocess.run(["git", "-C", NIXPKGS_PATH, "checkout", "master"], check=True)
    subprocess.run(["git", "-C", NIXPKGS_PATH, "fetch", "upstream"], check=True)
    subprocess.run(
        ["git", "-C", NIXPKGS_PATH, "reset", "--hard", "upstream/master"], check=True
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
            cwd=NIXPKGS_PATH,
            env={
                **os.environ,
                "NIXPKGS_ALLOW_UNFREE": "1",
                "NIXPKGS_ALLOW_INSECURE": "1",
            },
        ).stdout.strip()
    except subprocess.CalledProcessError:
        return None


def nixpkgs_create_package(package_name: str) -> Path:
    # Step 1: create new branch
    try:
        subprocess.run(
            ["git", "-C", NIXPKGS_PATH, "checkout", "-b", package_name], check=True
        )
    except subprocess.CalledProcessError:
        subprocess.run(
            ["git", "-C", NIXPKGS_PATH, "checkout", package_name], check=True
        )
    subprocess.run(
        ["git", "-C", NIXPKGS_PATH, "reset", "--hard", "upstream/master"], check=True
    )

    # Step 2: create package dir
    pkg_path = (
        Path(NIXPKGS_PATH) / "pkgs" / "by-name" / package_name[0:2] / package_name
    )
    os.makedirs(pkg_path, exist_ok=True)

    return pkg_path


def nixpkgs_create_commit(commit_message: str):
    subprocess.run(["git", "-C", NIXPKGS_PATH, "add", NIXPKGS_PATH], check=True)
    subprocess.run(["git", "-C", NIXPKGS_PATH, "status"], check=True)
    subprocess.run(
        ["git", "-C", NIXPKGS_PATH, "commit", "-m", commit_message], check=True
    )


def nixpkgs_test_build(package_name: str):
    subprocess.run(
        ["nix-build", "-A", package_name],
        check=True,
        cwd=NIXPKGS_PATH,
        env={
            **os.environ,
            "NIXPKGS_ALLOW_UNFREE": "1",
            "NIXPKGS_ALLOW_INSECURE": "1",
        },
    )


def nixpkgs_push(package_name: str):
    subprocess.run(
        ["git", "-C", NIXPKGS_PATH, "push", "-u", "origin", package_name, "--force"],
        check=True,
    )


if __name__ == "__main__":
    nur_pkg_path = Path(sys.argv[1])
    if not nur_pkg_path.is_dir():
        raise ValueError("NUR package path should be a directory")

    pkg_name = nur_pkg_path.name
    if not pkg_name:
        raise ValueError("Invalid path")

    existing_pkg_version = nixpkgs_get_existing_version(pkg_name)
    print(f"Existing version is {existing_pkg_version}")

    nixpkgs_pkg_path = nixpkgs_create_package(pkg_name)
    pkg_version = None

    for f in nur_pkg_path.iterdir():
        nixpkgs_target_path = nixpkgs_pkg_path / f.relative_to(nur_pkg_path)
        if f.name == "default.nix":
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

    nixpkgs_create_commit(f"{pkg_name}: {version_from} {version_to}")

    nixpkgs_test_build(pkg_name)
    nixpkgs_push(pkg_name)
