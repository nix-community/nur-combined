#!/usr/bin/env python3
import subprocess
import argparse
import shutil
import json
import sys
import datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
ROOT_NIX_FILE = str(REPO_ROOT / "default.nix")

# Per-package result collector: {pkg, status, detail?}
RESULTS = []

log = lambda *a: print(*a, file=sys.stderr)


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


def record(pkg_name, status, detail=None):
    """Record a package's final status (idempotent: same pkg recorded once)."""
    if any(r["pkg"] == pkg_name for r in RESULTS):
        return
    r = {"pkg": pkg_name, "status": status}
    if detail is not None:
        r["detail"] = detail
    RESULTS.append(r)


def update_package(pkg_name, extra_args=None):
    """Update a single package; any exception is isolated so it does not abort others."""
    extra_args = extra_args or []

    try:
        if not check_auto_update(pkg_name):
            log(f"[SKIP] {pkg_name}: passthru.autoUpdate = false")
            record(pkg_name, "skipped", "passthru.autoUpdate = false")
            return

        update_args = get_update_args(pkg_name)
        combined_args = update_args + extra_args
        pkg_dir = (REPO_ROOT / "pkgs" / pkg_name).resolve()

        if is_derivation(pkg_name):
            log(f"[NIX RUN] Running {pkg_name}'s updateScript as derivation...")
            cmd = ["nix", "run", f".#{pkg_name}.passthru.updateScript", "--"] + combined_args
            try:
                subprocess.run(cmd, check=True)
                log(f"[OK] {pkg_name} updated via nix run")
                record(pkg_name, "updated", "nix run")
                return
            except subprocess.CalledProcessError as e:
                msg = f"nix run failed: {e}"
                log(f"[FAIL] {pkg_name} {msg}")
                record(pkg_name, "failed", msg)
                return

        update_script = get_update_script(pkg_name)
        if update_script:
            log(f"[UPDATE SCRIPT] Running {pkg_name}'s traditional updateScript...")
            try:
                run_update_script(update_script, pkg_dir, pkg_name, combined_args)
                log(f"[OK] {pkg_name} updated via traditional script")
                record(pkg_name, "updated", "traditional script")
                return
            except subprocess.CalledProcessError as e:
                msg = f"updateScript failed: {e}"
                log(f"[FAIL] {pkg_name} {msg}")
                record(pkg_name, "failed", msg)
                return

        if not shutil.which("nix-update"):
            msg = "nix-update not found"
            log(f"[ERROR] {msg}.")
            record(pkg_name, "failed", msg)
            return

        cmd = ["nix-update", pkg_name, "-f", ROOT_NIX_FILE] + combined_args
        log(f"[NIX-UPDATE] Running: {' '.join(cmd)}")
        try:
            subprocess.run(cmd, check=True)
            log(f"[OK] {pkg_name} updated via nix-update")
            record(pkg_name, "updated", "nix-update")
        except subprocess.CalledProcessError as e:
            msg = f"nix-update failed: {e}"
            log(f"[FAIL] {pkg_name} {msg}")
            record(pkg_name, "failed", msg)

    except Exception as e:  # covers pre-update eval failures (check_auto_update/is_derivation/...)
        msg = f"unexpected error in pre-update eval: {type(e).__name__}: {e}"
        log(f"[FAIL] {pkg_name} {msg}")
        record(pkg_name, "failed", msg)


def emit_summary():
    """Emit the structured summary as a single JSON line on stdout."""
    result = {
        "updated": sum(1 for r in RESULTS if r["status"] == "updated"),
        "skipped": sum(1 for r in RESULTS if r["status"] == "skipped"),
        "failed": sum(1 for r in RESULTS if r["status"] == "failed"),
        "packages": RESULTS,
        "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }
    print(json.dumps(result, ensure_ascii=False))
    log(f"[SUMMARY] {result['updated']} updated / {result['skipped']} skipped / {result['failed']} failed")


def main():
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Update a single package")
    parser.add_argument("extra_args", nargs="*", help="Additional args forwarded to update scripts")
    args = parser.parse_args()

    extra_args = list(args.extra_args)

    packages = list_packages()
    if not packages:
        log("[ERROR] No packages found.")
        print(json.dumps({"updated": 0, "skipped": 0, "failed": 0, "packages": []}))
        return

    if args.package:
        if args.package in packages:
            update_package(args.package, extra_args)
        else:
            log(f"[ERROR] Package {args.package} not found")
            record(args.package, "failed", "package not found in repo")
    else:
        for pkg in packages:
            update_package(pkg, extra_args)

    emit_summary()


if __name__ == "__main__":
    main()
