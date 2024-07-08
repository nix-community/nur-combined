#!/usr/bin/env python
import json
import os
import re
import subprocess

PLATFORMS = [
    "x86_64-linux",
    "aarch64-linux",
]

SKIP_BUILD = [
    "deepspeech-gpu",
    "deepspeech-wrappers",
]


def get_metas(platform: str) -> dict:
    nix_output = subprocess.run(
        ["nix", "eval", "--raw", f".#_metaJson.{platform}"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return json.loads(nix_output.stdout)


def get_versions(platform: str) -> dict:
    nix_output = subprocess.run(
        ["nix", "eval", "--raw", f".#_versionJson.{platform}"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return json.loads(nix_output.stdout)


def build_package(platform: str, package: str, output: str = "result") -> dict:
    subprocess.run(
        ["nix", "build", f".#legacyPackages.{platform}.{package}", "-o", output],
        check=True,
    )


def verify_version(platform: str, name: str, version: str) -> bool:
    valid = True

    if version.startswith("v"):
        print(f"{platform}: {name}: version should not start with v")
        valid = False

    if re.match(r"[0-9a-f]{40}", version):
        print(
            f'{platform}: {name}: should use date for version similar to "unstable-2020-01-01"'
        )
        valid = False

    return valid


def verify_package(platform: str, name: str, package: dict) -> bool:
    # Skip special packages
    if name in [
        # kernel package is imported unchanged from nixpkgs
        "kernel",
    ]:
        return True

    valid = True

    if not package.get("name"):
        print(f"{platform}: {name}: no name set")
        valid = False

    if not package.get("description"):
        print(f"{platform}: {name}: no description set")
        valid = False

    if not package.get("homepage"):
        print(f"{platform}: {name}: no homepage set")
        valid = False

    if not package.get("license"):
        print(f"{platform}: {name}: no license set")
        valid = False

    if not any([m.get("github") == "xddxdd" for m in package.get("maintainers", [])]):
        print(f"{platform}: {name}: xddxdd not in maintainers")
        valid = False

    if not valid:
        return valid

    valid = validate_package_content(platform, name, package)
    return valid


def validate_package_content(platform: str, name: str, package: dict) -> bool:
    if name in SKIP_BUILD:
        return True

    # Do not have compute power to build aarch64 packages
    if platform != "x86_64-linux":
        return True

    if package.get("broken"):
        return True

    platforms = package.get("platforms")
    if platforms and platform not in platforms:
        return True

    valid = True

    try:
        # print(f"{platform}: {name}: start build")
        build_package(platform, name)
    except Exception:
        print(f"{platform}: {name}: package build failed")
        valid = False

    for file in os.listdir():
        if not file.startswith("result"):
            continue

        main_program = package.get("mainProgram") or name
        if os.path.exists(f"{file}/bin") and not os.path.exists(
            f"{file}/bin/{main_program}"
        ):
            print(f"{platform}: {name}: main program {main_program} does not exist")
            print(os.listdir(f"{file}/bin"))
            valid = False

    # Cleanup build results
    for file in os.listdir():
        if file.startswith("result"):
            os.remove(file)

    return valid


all_valid = True
for platform in PLATFORMS:
    versions = get_versions(platform)
    for name, version in versions.items():
        if not verify_version(platform, name, version):
            all_valid = False

    metas = get_metas(platform)
    for name, package in metas.items():
        if not verify_package(platform, name, package):
            all_valid = False

exit(0 if all_valid else 1)
