#!/usr/bin/env python3
import subprocess
import argparse
import shutil
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
ROOT_NIX_FILE = str(REPO_ROOT / "default.nix")


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
        return True  # 默认允许更新


def is_derivation(pkg_name):
    """判断 passthru.updateScript 是否为一个 Nix Derivation"""
    try:
        # 更加健壮的判定：同时检查 builtins.isDerivation 和 .type 属性
        expr = (
            f"let p = (import {ROOT_NIX_FILE} {{ pkgs = import <nixpkgs> {{}}; }}).{pkg_name}.passthru.updateScript; "
            f"in (p.type or \"\") == \"derivation\" || builtins.isDerivation p"
        )
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--impure",
                "--json",
                "--expr",
                expr,
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        return json.loads(result.stdout) is True
    except subprocess.CalledProcessError:
        return False


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
        return None


def get_update_args(pkg_name):
    """获取包的 passthru.updateArgs，如果有"""
    try:
        result = subprocess.run(
            [
                "nix",
                "eval",
                "--impure",
                "--json",
                "-f",
                ROOT_NIX_FILE,
                f"{pkg_name}.passthru.updateArgs",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        return json.loads(result.stdout) or []
    except subprocess.CalledProcessError:
        return []


def run_update_script(script, pkg_dir: Path, pkg_name: str, extra_args=None):
    """执行传统 updateScript (字符串、列表或字典格式)"""
    extra_args = extra_args or []

    if isinstance(script, str):
        if "nix-update" in script:
            cmd = [script, pkg_name, "-f", ROOT_NIX_FILE] + extra_args
            print(f"[RUN CMD] {' '.join(cmd)}")
            subprocess.run(cmd, check=True, cwd=pkg_dir)
            return

        update_file = Path(script)
        # 如果是 store 路径且本地不存在，说明不应通过本地文件方式运行
        if not update_file.is_absolute():
            update_file = pkg_dir / update_file

        if not update_file.exists():
            print(f"[ERROR] updateScript {update_file} not found, skipping")
            return

        print(f"[RUN UPDATE SCRIPT] {update_file} {' '.join(extra_args)}")
        subprocess.run([str(update_file)] + extra_args, check=True, cwd=pkg_dir)

    elif isinstance(script, list):
        for step in script:
            run_update_script(step, pkg_dir, pkg_name, extra_args)
    elif isinstance(script, dict):
        if "command" in script:
            cmd = script["command"] + extra_args
            print(f"[RUN CMD] {' '.join(cmd)} (dictionary command format)")
            subprocess.run(cmd, check=True, cwd=pkg_dir)
        else:
            print(f"[SKIP] Unknown dictionary format in updateScript: {script}")


def update_package(pkg_name, extra_args=None):
    """更新单个包，包含 drv 优先判断"""
    extra_args = extra_args or []

    if not check_auto_update(pkg_name):
        print(f"[SKIP] {pkg_name}: passthru.autoUpdate = false")
        return

    update_args = get_update_args(pkg_name)
    combined_args = update_args + extra_args
    pkg_dir = (REPO_ROOT / "pkgs" / pkg_name).resolve()

    # 1. 优先检查并使用 nix run 执行 drv 脚本
    # 必须先于 get_update_script 执行，防止 drv 被错误识别为普通路径字符串
    if is_derivation(pkg_name):
        print(f"[NIX RUN] Running {pkg_name}'s updateScript as derivation...")
        cmd = ["nix", "run", f".#{pkg_name}.passthru.updateScript", "--"] + combined_args
        try:
            subprocess.run(cmd, check=True)
            print(f"[OK] {pkg_name} updated via nix run")
            return
        except subprocess.CalledProcessError as e:
            print(f"[FAIL] {pkg_name} nix run failed: {e}")
            return

    # 2. 检查传统脚本格式 (string/list/dict)
    update_script = get_update_script(pkg_name)
    if update_script:
        print(f"[UPDATE SCRIPT] Running {pkg_name}'s traditional updateScript...")
        try:
            run_update_script(update_script, pkg_dir, pkg_name, combined_args)
            print(f"[OK] {pkg_name} updated via traditional script")
        except subprocess.CalledProcessError as e:
            print(f"[FAIL] {pkg_name} updateScript failed: {e}")
        return

    # 3. 兜底使用 nix-update
    if not shutil.which("nix-update"):
        print("[ERROR] nix-update not found.")
        return

    cmd = ["nix-update", pkg_name, "-f", ROOT_NIX_FILE] + combined_args
    print(f"[NIX-UPDATE] Running: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True)
        print(f"[OK] {pkg_name} updated via nix-update")
    except subprocess.CalledProcessError as e:
        print(f"[FAIL] {pkg_name} nix-update failed: {e}")


def main():
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Update a single package")
    parser.add_argument("--commit", action="store_true", help="Pass --commit")
    parser.add_argument("--test", action="store_true", help="Pass --test")
    parser.add_argument("--build", action="store_true", help="Pass --build")
    parser.add_argument("extra_args", nargs="*", help="Additional args")
    args = parser.parse_args()

    extra_args = []
    if args.commit: extra_args.append("--commit")
    if args.test: extra_args.append("--test")
    if args.build: extra_args.append("--build")
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
