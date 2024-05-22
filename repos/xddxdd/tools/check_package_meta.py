#!/usr/bin/env python
import json
import re
import subprocess

PLATFORMS = [
    "x86_64-linux",
    "aarch64-linux",
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
