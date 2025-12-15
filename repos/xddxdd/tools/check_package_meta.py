#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.toml -p nixfmt-rfc-style
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
    "_meta",
    "deprecated",
    "kernel",
    "lantianLinuxCachyOS",
    "lantianLinuxXanmod",
    "nvidia-grid",
]

SKIP_BUILD = [
    "_meta",
    "deprecated",
    "kernel",
    "lantianLinuxCachyOS",
    "lantianLinuxXanmod",
]


def build_package(package_path: str, output: str = "result"):
    subprocess.run(["nix", "build", f".#{package_path}", "-o", output], check=True)


class Check:
    def __init__(
        self, package_path: str, meta: dict, package_info: Optional[dict] = None
    ):
        self.package_path = package_path
        self.package_name = package_path.split(".")[2]
        self.meta = meta
        self.package_info = package_info
        self.valid = True

    def fail(self, message: str):
        print(f"{self.package_path}: {message}")
        self.valid = False

    def verify(self) -> bool:
        raise NotImplementedError


class DescriptionCheck(Check):
    def verify(self) -> bool:
        description: Optional[str] = self.meta.get("description")
        package_name = self.package_path.split(".")[2]

        if not description:
            self.fail("no description set")
            return self.valid
        elif description.startswith(" ") or description.endswith(" "):
            self.fail("description has space at beginning or end")
        elif re.match(r"^(a|an|the) ", description.lower(), re.IGNORECASE):
            self.fail("description has article at beginning")
        elif re.match(r"^[a-z]", description):
            self.fail("description starts with lower case letter")
        elif description.endswith("."):
            self.fail("description has period at end")

        # New checks for description
        if len(description.split(". ")) > 1:
            self.fail("description should be short, just one sentence")
        if description.lower().startswith(package_name.lower()):
            self.fail("description should not start with the package name")

        return self.valid


class LicenseCheck(Check):
    def verify(self) -> bool:
        license_attr = self.meta.get("license")

        if not license_attr:
            self.fail("meta.license must be set")
            return self.valid

        return self.valid


class MaintainersCheck(Check):
    def verify(self) -> bool:
        maintainers = self.meta.get("maintainers")

        if not maintainers:
            self.fail("meta.maintainers must be set for new packages")
        if not isinstance(maintainers, list) or not maintainers:
            self.fail("meta.maintainers must be a non-empty list")
        if not any([m.get("github") == "xddxdd" for m in (maintainers or [])]):
            self.fail("xddxdd not in maintainers")
        return self.valid


class PackageInfoCheck(Check):
    def verify(self) -> bool:
        # Skip special packages
        if self.package_name in SKIP_CHECK:
            return True

        if self.package_info is None:
            self.fail("package_info is None, cannot perform checks")
            return self.valid

        version = self.package_info.get("version", "")

        if version.startswith("v"):
            self.fail("version should not start with v")

        if re.match(r"[0-9a-f]{40}", version):
            self.fail('should use date for version similar to "unstable-2020-01-01"')

        for phase in ["unpack", "patch", "configure", "build", "install", "fixup"]:
            if f"{phase}Phase" in self.package_info:
                command = self.package_info[f"{phase}Phase"]
                if not command:
                    continue

                if f"runHook pre{phase.capitalize()}" not in command:
                    self.fail(f"runHook pre{phase.capitalize()} not in build script")
                if f"runHook post{phase.capitalize()}" not in command:
                    self.fail(f"runHook post{phase.capitalize()} not in build script")
                if "\\\n\n" in command:
                    self.fail("extra backslash in command")

        return self.valid


def format_with_nixfmt(nix_file: str) -> str:
    p = subprocess.Popen(
        ["nixfmt"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    return p.communicate(nix_file)[0]


def apply_package_meta_change(meta: dict, statement: str):
    if not meta.get("position"):
        return

    match = re.search(r"/(pkgs/.+\.nix):", meta["position"], re.IGNORECASE)
    if not match:
        print(f"Cannot find nix file for {meta['position']}")
        return
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


class HomepageCheck(Check):
    def verify(self) -> bool:
        if not self.meta.get("homepage"):
            self.fail("no homepage set")
        return self.valid


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


def verify_package(
    package_path: str,
    package_meta: dict,
    package_info: dict,
) -> bool:
    # Skip special packages
    package_name = package_path.split(".")[2]
    if package_name in SKIP_CHECK:
        return True

    valid = True

    checks: List[Check] = [
        DescriptionCheck(package_path, package_meta),
        LicenseCheck(package_path, package_meta),
        MaintainersCheck(package_path, package_meta),
        PackageInfoCheck(package_path, package_meta, package_info["env"]),
        HomepageCheck(package_path, package_meta),
    ]

    for check in checks:
        if not check.verify():
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

    autocorrect_package_meta(
        package_path, package_meta, nvfetcher_config, nvfetcher_generated
    )

    if not verify_package(package_path, package_meta, package_info):
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
