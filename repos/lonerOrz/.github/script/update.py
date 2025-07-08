#!/usr/bin/env python3
import os
import subprocess
import re
import argparse
import shutil
from pathlib import Path

# Configuration: Define paths and package file name in one place
ROOT_NIX_FILE = "./default.nix"  # Root nix file for callPackage
PKGS_DIR = "./pkgs"  # Directory containing package subdirectories
PACKAGE_FILE_NAME = (
    "default.nix"  # Package file name in subdirs (e.g., default.nix or package.nix)
)


def check_auto_update(package_nix_file):
    """Check if the package nix file has passthru.autoUpdate = false"""
    try:
        content = package_nix_file.read_text()
        # Look for passthru.autoUpdate = false
        match = re.search(r"passthru\.autoUpdate\s*=\s*false", content)
        return (
            match is None
        )  # Return True if autoUpdate is not false (i.e., include package)
    except Exception as e:
        print(f"Error reading {package_nix_file} for autoUpdate check: {e}")
        return True  # Include package if file can't be read (safe default)


def find_packages(pkgs_dir, package_file_name):
    """Scan the pkgs directory for package files (pkgs/xxx.nix and pkgs/*/package_file_name)"""
    packages = []
    excluded_packages = []
    pkgs_path = Path(pkgs_dir).resolve()
    print(f"Scanning directory: {pkgs_path} for {package_file_name} and *.nix files")

    # Find package files in subdirectories (e.g., pkgs/xxxx/default.nix)
    print(f"Checking subdirectories for {package_file_name}...")
    for item in pkgs_path.glob(f"*/{package_file_name}"):
        package_name = item.parent.name
        if not check_auto_update(item):
            print(
                f"Skipping package {package_name} at {item} (passthru.autoUpdate = false)"
            )
            excluded_packages.append((package_name, item))
            continue
        packages.append((package_name, item))
        print(f"Found package: {package_name} at {item}")

    # Find top-level nix files (e.g., pkgs/xxx.nix)
    print(f"Checking top-level *.nix files...")
    for item in pkgs_path.glob("*.nix"):
        package_name = item.stem
        if not check_auto_update(item):
            print(
                f"Skipping package {package_name} at {item} (passthru.autoUpdate = false)"
            )
            excluded_packages.append((package_name, item))
            continue
        packages.append((package_name, item))
        print(f"Found package: {package_name} at {item}")

    return packages, excluded_packages


def check_update_script(package_dir, package_file_name):
    """Check if the package's nix file defines passthru.updateScript = ./xxxx.sh"""
    package_nix_file = package_dir / package_file_name
    if not package_nix_file.exists():
        print(f"Package nix file {package_nix_file} does not exist")
        return None

    try:
        content = package_nix_file.read_text()
        # Look for passthru.updateScript = ./xxxx.sh pattern
        match = re.search(r"passthru\.updateScript\s*=\s*\./([^\s;]+\.sh)", content)
        if match:
            update_script_name = match.group(1)  # Extract xxxx.sh
            update_sh = package_dir / update_script_name
            if update_sh.exists():
                print(f"Found custom update script: {update_sh}")
                return update_sh
            else:
                print(f"Custom update script {update_sh} does not exist")
    except Exception as e:
        print(f"Error reading {package_nix_file}: {e}")

    return None


def update_package(package_name, package_nix_file, root_nix_file, extra_args=None):
    """Update a single package"""
    extra_args = extra_args or []

    pkg_dir = package_nix_file.parent

    # Prioritize custom update script
    update_script = check_update_script(pkg_dir, package_nix_file.name)
    if update_script:
        print(f"Updating {package_name} using custom update script: {update_script}")
        try:
            subprocess.run(["bash", str(update_script)], check=True, cwd=pkg_dir)
            print(f"Successfully updated {package_name} using custom update script")
        except subprocess.CalledProcessError as e:
            print(f"Failed to update {package_name} using custom update script: {e}")
        return

    # Check if nix-update is available
    if not shutil.which("nix-update"):
        print(
            f"Error: 'nix-update' command not found. Please install it using 'nix-env -iA nixpkgs.nix-update' or run in a nix-shell with 'nix-shell -p nix-update'."
        )
        return

    # Fallback to nix-update with root nix file
    cmd = ["nix-update", package_name, "-f", str(root_nix_file)]
    if extra_args:
        cmd.extend(extra_args)

    print(f"Updating {package_name} using nix-update: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True, cwd=os.getcwd())
        print(f"Successfully updated {package_name}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to update {package_name}: {e}")


def main():
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Specify a single package to update")
    parser.add_argument(
        "--commit", action="store_true", help="Pass --commit to nix-update"
    )
    parser.add_argument("--test", action="store_true", help="Pass --test to nix-update")
    parser.add_argument(
        "--build", action="store_true", help="Pass --build to nix-update"
    )
    parser.add_argument(
        "extra_args", nargs="*", help="Additional arguments for nix-update"
    )
    args = parser.parse_args()

    root_nix_file = Path(ROOT_NIX_FILE).resolve()
    pkgs_dir = PKGS_DIR
    package_file_name = PACKAGE_FILE_NAME

    if not os.path.isdir(pkgs_dir):
        print(f"Directory {pkgs_dir} does not exist")
        return
    if not root_nix_file.exists():
        print(f"Root nix file {root_nix_file} does not exist")
        return

    packages, excluded_packages = find_packages(pkgs_dir, package_file_name)
    print(f"Found packages: {packages}")
    print(f"Excluded packages: {excluded_packages}")
    if not packages and not excluded_packages:
        print(
            f"No packages found in {pkgs_dir} with file name {package_file_name} or *.nix"
        )
        return

    # Build extra arguments for nix-update
    extra_args = []
    if args.commit:
        extra_args.append("--commit")
    if args.test:
        extra_args.append("--test")
    if args.build:
        extra_args.append("--build")
    extra_args.extend(args.extra_args)

    if args.package:
        # Update only the specified package
        for pkg_name, pkg_nix_file in packages:
            if pkg_name == args.package:
                update_package(pkg_name, pkg_nix_file, root_nix_file, extra_args)
                break
        else:
            # Check if the package was excluded due to passthru.autoUpdate = false
            for pkg_name, pkg_nix_file in excluded_packages:
                if pkg_name == args.package:
                    print(
                        f"Package {args.package} was excluded because passthru.autoUpdate = false in {pkg_nix_file}"
                    )
                    break
            else:
                print(f"Package {args.package} not found in {pkgs_dir}")
    else:
        # Update all packages
        print(f"Found {len(packages)} packages to update")
        for pkg_name, pkg_nix_file in packages:
            update_package(pkg_name, pkg_nix_file, root_nix_file, extra_args)


if __name__ == "__main__":
    main()
