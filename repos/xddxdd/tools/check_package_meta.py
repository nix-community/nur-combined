#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.toml
import argparse
import json
import multiprocessing as mp
import os
import random
import re
import subprocess
from typing import List, Optional

import toml

SKIP_CHECK = [
    "kernel",
    "lantianLinuxCachyOS",
    "lantianLinuxXanmod",
    "nvidia-grid",
]

SKIP_BUILD = [
    "kernel",
    "lantianLinuxCachyOS",
    "lantianLinuxXanmod",
]


def build_package(package_path: str, output: str = "result"):
    subprocess.run(["nix", "build", f".#{package_path}", "-o", output], check=True)


def verify_package_info(package_path: str, package_info: dict) -> bool:
    # Skip special packages
    package_name = package_path.split(".")[2]
    if package_name in SKIP_CHECK:
        return True

    valid = True

    version = package_info.get("version", "")

    if version.startswith("v"):
        print(f"{package_path}: version should not start with v")
        valid = False

    if re.match(r"[0-9a-f]{40}", version):
        print(
            f'{package_path}: should use date for version similar to "unstable-2020-01-01"'
        )
        valid = False

    for phase in ["unpack", "patch", "configure", "build", "install", "fixup"]:
        if f"{phase}Phase" in package_info:
            command = package_info[f"{phase}Phase"]
            if not command:
                continue

            if f"runHook pre{phase.capitalize()}" not in command:
                print(
                    f"{package_path}: runHook pre{phase.capitalize()} not in build script"
                )
                valid = False
            if f"runHook post{phase.capitalize()}" not in command:
                print(
                    f"{package_path}: runHook post{phase.capitalize()} not in build script"
                )
                valid = False
            if "\\\n\n" in command:
                print(f"{package_path}: extra backslash in command")
                valid = False

    return valid


def format_with_nixfmt(nix_file: str) -> str:
    p = subprocess.Popen(
        ["nixfmt"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    return p.communicate(nix_file)[0]


def apply_package_meta_change(meta: dict, statement: str):
    if not meta.get("position"):
        return

    match = re.search(r"/(pkgs/.+\.nix):", meta["position"], re.IGNORECASE)
    nix_file = match[1]

    try:
        with open(nix_file) as f:
            nix_str = f.read()
    except FileNotFoundError:
        print(f"Cannot open file {nix_file}")
        return

    if statement in nix_str:
        print(f"Meta change already present in {nix_file}, race condition?")
        return

    new_nix_str = re.sub(
        r"^[ ]*meta =(.+)\{$", r"meta =\1{\n" + statement, nix_str, flags=re.MULTILINE
    )
    if new_nix_str == nix_str:
        raise RuntimeError("Nix derivation before/after replacement are the same")

    new_nix_str = format_with_nixfmt(new_nix_str)
    with open(nix_file, "w") as f:
        f.write(new_nix_str)

    print(f"Applied meta change to {nix_file}")


def autocorrect_package_meta(
    package_path: str,
    meta: dict,
    nvfetcher_config: Optional[dict] = None,
    nvfetcher_generated: Optional[dict] = None,
):
    # Skip special packages
    package_name = package_path.split(".")[2]
    if package_name in SKIP_CHECK:
        return

    if not nvfetcher_config or not nvfetcher_generated:
        return

    github_release_src = nvfetcher_config.get("src", {}).get("github")
    github_fetch_src = nvfetcher_config.get("fetch", {}).get("github")

    nvfetcher_version = nvfetcher_generated.get("src", {}).get("rev", "")
    if nvfetcher_version.startswith("v"):
        version_prefix = "v"
    elif nvfetcher_version.startswith("V"):
        version_prefix = "V"
    else:
        version_prefix = ""

    if github_release_src and not meta.get("changelog"):
        statement = f'changelog = "https://github.com/{github_release_src}/releases/tag/{version_prefix}${{version}}";'
        apply_package_meta_change(meta, statement)

    if github_fetch_src and not meta.get("homepage"):
        statement = f'homepage = "https://github.com/{github_fetch_src}";'
        apply_package_meta_change(meta, statement)


def verify_package_meta(
    package_path: str,
    meta: dict,
) -> bool:
    # Skip special packages
    package_name = package_path.split(".")[2]
    if package_name in SKIP_CHECK:
        return True

    valid = True

    description: Optional[str] = meta.get("description")
    if not description:
        print(f"{package_path}: no description set")
        valid = False
    elif description.startswith(" ") or description.endswith(" "):
        print(f"{package_path}: description has space at beginning or end")
        valid = False
    elif re.match(r"^(a|an|the) ", description.lower(), re.IGNORECASE):
        print(f"{package_path}: description has article at beginning")
        valid = False
    elif re.match(r"^[a-z]", description):
        print(f"{package_path}: description starts with lower case letter")
        valid = False
    elif description.endswith("."):
        print(f"{package_path}: description has period at end")
        valid = False

    if not meta.get("homepage"):
        print(f"{package_path}: no homepage set")
        valid = False

    if not meta.get("license"):
        print(f"{package_path}: no license set")
        valid = False

    if not any([m.get("github") == "xddxdd" for m in meta.get("maintainers", [])]):
        print(f"{package_path}: xddxdd not in maintainers")
        valid = False

    return valid


def validate_package_content(package_path: str, package: dict) -> bool:
    # Skip special packages
    package_name = package_path.split(".")[2]
    if package_name in SKIP_CHECK:
        return True

    platform = package_path.split(".")[1]

    # Do not have compute power to build aarch64 packages
    if platform != "x86_64-linux":
        return True

    if package.get("broken"):
        return True

    platforms = package.get("platforms")
    if platforms and platform not in platforms:
        return True

    valid = True

    result_path = f"result{random.randint(100000000,999999999)}"

    try:
        # print(f"{package_path}: start build")
        build_package(package_path, result_path)
    except Exception:
        print(f"{package_path}: package build failed")
        valid = False

    for file in os.listdir():
        if not file.startswith(result_path):
            continue

        main_program = package.get("mainProgram")
        if os.path.exists(f"{file}/bin"):
            if not main_program:
                print(f"{package_path}: main program not set")
                print(os.listdir(f"{file}/bin"))
                valid = False
            elif not os.path.exists(f"{file}/bin/{main_program}"):
                print(f"{package_path}: main program {main_program} does not exist")
                print(os.listdir(f"{file}/bin"))
                valid = False

    # Cleanup build results
    for file in os.listdir():
        if file.startswith(result_path):
            os.remove(file)

    return valid


def get_packages() -> List[str]:
    nix_output = subprocess.run(
        ["nix", "search", "--json", ".", "^"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return list(json.loads(nix_output.stdout).keys())


def get_package_info(package_path: str) -> Optional[dict]:
    nix_output = subprocess.run(
        ["nix", "derivation", "show", f".#{package_path}"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if nix_output.returncode != 0:
        if "refusing to evaluate" in nix_output.stderr:
            return None
        else:
            raise RuntimeError(nix_output.stderr)
    return list(json.loads(nix_output.stdout).items())[0][1]


def get_package_meta(package_path: str) -> dict:
    nix_output = subprocess.run(
        ["nix", "eval", "--json", f".#{package_path}.meta"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return json.loads(nix_output.stdout)


def get_package_nvfetcher_config(package_path: str) -> Optional[dict]:
    with open("nvfetcher.toml") as f:
        data = toml.load(f)
    return data.get(package_path.split(".")[-1])


def get_package_nvfetcher_generated(package_path: str) -> Optional[dict]:
    with open("_sources/generated.json") as f:
        data = json.load(f)
    return data.get(package_path.split(".")[-1])


def check_package(args) -> bool:
    package_path: str
    build: bool
    package_path, build = args

    valid = True

    package_info = get_package_info(package_path)
    if package_info is None:
        # Skip check of broken package
        return True

    package_meta = get_package_meta(package_path)

    nvfetcher_config = get_package_nvfetcher_config(package_path)
    nvfetcher_generated = get_package_nvfetcher_generated(package_path)

    # Do not check merged packages solely for CI purposes
    if package_info["name"] == "merged-packages":
        return True

    autocorrect_package_meta(
        package_path, package_meta, nvfetcher_config, nvfetcher_generated
    )

    if not verify_package_info(package_path, package_info["env"]):
        valid = False

    if not verify_package_meta(package_path, package_meta):
        valid = False

    if build:
        if not validate_package_content(package_path, package_meta):
            valid = False

    return valid


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="check_package_meta.py",
        description="Script to check metadata of my NUR packages",
    )
    parser.add_argument(
        "--build",
        "-b",
        help="Enable checks that rely on building the package",
        action="store_true",
    )
    args = parser.parse_args()

    pool = mp.Pool()
    results = pool.map(check_package, [(p, args.build) for p in get_packages()])
    all_valid = all(results)
    exit(0 if all_valid else 1)
