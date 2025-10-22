#!/usr/bin/env python3
import subprocess
import argparse
import shutil
import json
from pathlib import Path

ROOT_NIX_FILE = "./default.nix"  # Root nix file for callPackage


def list_packages():
    """获取 root Nix 文件下所有包名"""
    try:
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--expr",
                f"builtins.attrNames (import {ROOT_NIX_FILE} {{ pkgs = import <nixpkgs> {{}}; }})",
                "--json",
                "--impure",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Failed to list packages: {e.stderr}")
        return []


def check_auto_update(pkg_name):
    """判断包是否被禁用更新"""
    try:
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--expr",
                f"(import {ROOT_NIX_FILE} {{ pkgs = import <nixpkgs> {{}}; }}).{pkg_name}.passthru.autoUpdate",
                "--json",
                "--impure",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        value = json.loads(result.stdout)
        return value != False
    except subprocess.CalledProcessError:
        # 如果不存在 autoUpdate 字段，默认允许更新
        return True


def get_update_script(pkg_name):
    """获取包的 passthru.updateScript，如果有"""
    try:
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--impure",
                "--json",
                "-f",
                ROOT_NIX_FILE,
                f"{pkg_name}.passthru.updateScript",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError:
        # 没有 updateScript 时返回 None
        return None


def run_update_script(script, pkg_dir: Path, pkg_name: str):
    """
    执行 updateScript。
    如果是 nix-update 可执行文件，自动加上软件名作为参数
    """
    if isinstance(script, str):
        # 如果是 nix-update 直接加上软件名
        if "nix-update" in script:
            cmd = [script, pkg_name]
            print(f"[RUN CMD] {' '.join(cmd)}")
            subprocess.run(cmd, check=True, cwd=pkg_dir)
            return

        # 其他脚本路径
        update_file = Path(script)
        if not update_file.is_absolute():
            update_file = pkg_dir / update_file
        if not update_file.exists():
            print(f"[ERROR] updateScript {update_file} not found, skipping")
            return
        print(f"[RUN UPDATE SCRIPT] {update_file}")
        subprocess.run([str(update_file)], check=True, cwd=pkg_dir)

    elif isinstance(script, list):
        for step in script:
            run_update_script(step, pkg_dir, pkg_name)
    elif isinstance(script, dict):
        if "command" in script:
            print(f"[RUN CMD] {script['command']} (dictionary command format)")
            subprocess.run(script["command"], check=True, cwd=pkg_dir)
        else:
            print(f"[SKIP] Unknown dictionary format in updateScript: {script}")
    else:
        print(f"[WARN] Unsupported updateScript format: {script}")


def update_package(pkg_name, extra_args=None):
    """更新单个包"""
    extra_args = extra_args or []

    if not check_auto_update(pkg_name):
        print(f"[SKIP] {pkg_name}: passthru.autoUpdate = false")
        return

    update_script = get_update_script(pkg_name)
    pkg_dir = Path(f"./pkgs/{pkg_name}").resolve()

    if update_script:
        print(f"[UPDATE SCRIPT] Running {pkg_name}'s updateScript...")
        try:
            run_update_script(update_script, pkg_dir, pkg_name)
            print(f"[OK] {pkg_name} updated via updateScript")
        except subprocess.CalledProcessError as e:
            print(f"[FAIL] {pkg_name} updateScript failed: {e}")
        return

    # fallback: nix-update
    if not shutil.which("nix-update"):
        print("[ERROR] nix-update not found. Install it or run in nix-shell -p nix-update")
        return

    cmd = ["nix-update", pkg_name, "-f", ROOT_NIX_FILE] + extra_args
    print(f"[NIX-UPDATE] Running: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True)
        print(f"[OK] {pkg_name} updated via nix-update")
    except subprocess.CalledProcessError as e:
        print(f"[FAIL] {pkg_name} nix-update failed: {e}")


def main():
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Update a single package")
    parser.add_argument(
        "--commit", action="store_true", help="Pass --commit to nix-update"
    )
    parser.add_argument("--test", action="store_true", help="Pass --test to nix-update")
    parser.add_argument(
        "--build", action="store_true", help="Pass --build to nix-update"
    )
    parser.add_argument("extra_args", nargs="*", help="Additional nix-update args")
    args = parser.parse_args()

    extra_args = []
    if args.commit:
        extra_args.append("--commit")
    if args.test:
        extra_args.append("--test")
    if args.build:
        extra_args.append("--build")
    extra_args.extend(args.extra_args)

    packages = list_packages()
    if not packages:
        print("[ERROR] No packages found.")
        return

    if args.package:
        if args.package in packages:
            update_package(args.package, extra_args)
        else:
            print(f"[ERROR] Package {args.package} not found")
    else:
        for pkg in packages:
            update_package(pkg, extra_args)


if __name__ == "__main__":
    main()
