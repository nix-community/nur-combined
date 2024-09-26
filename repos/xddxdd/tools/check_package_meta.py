#!/usr/bin/env python
import json
import multiprocessing as mp
import os
import random
import re
import subprocess
from typing import List

SKIP_CHECK = [
    "kernel",
    "lantianLinuxXanmod",
]

SKIP_BUILD = [
    "deepspeech-gpu",
    "deepspeech-wrappers",
    "kernel",
    "lantianLinuxXanmod",
]


def build_package(package_path: str, output: str = "result") -> dict:
    subprocess.run(
        ["nix", "build", f".#{package_path}", "-o", output],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


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


def verify_package_meta(package_path: str, meta: dict) -> bool:
    # Skip special packages
    package_name = package_path.split(".")[2]
    if package_name in SKIP_CHECK:
        return True

    valid = True

    if not meta.get("description"):
        print(f"{package_path}: no description set")
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

        main_program = package.get("mainProgram") or package_name
        if os.path.exists(f"{file}/bin") and not os.path.exists(
            f"{file}/bin/{main_program}"
        ):
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


def get_package_info(package_path: str) -> dict:
    nix_output = subprocess.run(
        ["nix", "derivation", "show", f".#{package_path}"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
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


def check_package(package_path: str) -> bool:
    valid = True

    package_info = get_package_info(package_path)
    package_meta = get_package_meta(package_path)

    # Do not check merged packages solely for CI purposes
    if package_info["name"] == "merged-packages":
        return True

    if not verify_package_info(package_path, package_info["env"]):
        valid = False

    if not verify_package_meta(package_path, package_meta):
        valid = False

    # if not validate_package_content(package_path, package_meta):
    #     valid = False

    return valid


if __name__ == "__main__":
    pool = mp.Pool()
    results = pool.map(check_package, get_packages())
    all_valid = all(results)
    exit(0 if all_valid else 1)
