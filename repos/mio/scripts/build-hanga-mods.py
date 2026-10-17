#!/usr/bin/env python3
"""
Builds Hanga WASM mods and prepares the mods/games assets directory.
Cross-platform helper for Linux, macOS, and Windows CI.
"""

import os
import shutil
import subprocess
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
HANGA_DIR = os.path.join(REPO_ROOT, "by-name", "ha", "hanga")


def patch_crate_type(cargo_toml_path: str, to_cdylib: bool):
    with open(cargo_toml_path, "r", encoding="utf-8") as f:
        content = f.read()
    if to_cdylib:
        new_content = content.replace('crate-type = ["rlib"]', 'crate-type = ["cdylib"]')
    else:
        new_content = content.replace('crate-type = ["cdylib"]', 'crate-type = ["rlib"]')
    with open(cargo_toml_path, "w", encoding="utf-8") as f:
        f.write(new_content)


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HANGA_DIR, "dist")
    mods_out = os.path.join(out_dir, "mods")
    games_out = os.path.join(out_dir, "games")
    wit_out = os.path.join(out_dir, "wit")

    os.makedirs(mods_out, exist_ok=True)
    os.makedirs(games_out, exist_ok=True)
    os.makedirs(wit_out, exist_ok=True)

    mods = ["urban_chaos", "testbed"]
    toml_files = [os.path.join(HANGA_DIR, "mods", m, "Cargo.toml") for m in mods]

    print("Patching mods Cargo.toml for cdylib...")
    for t in toml_files:
        patch_crate_type(t, to_cdylib=True)

    try:
        print("Compiling WASM mods...")
        env = os.environ.copy()
        # Enable wasm-ld if available or let lld/rust default handle it
        cmd = [
            "cargo",
            "build",
            "--release",
            "--target",
            "wasm32-unknown-unknown",
            "-p",
            "urban_chaos",
            "-p",
            "testbed",
        ]
        res = subprocess.run(cmd, cwd=HANGA_DIR, env=env)
        if res.returncode != 0:
            print("Failed to build WASM mods", file=sys.stderr)
            sys.exit(res.returncode)
    finally:
        print("Restoring mods Cargo.toml to rlib...")
        for t in toml_files:
            patch_crate_type(t, to_cdylib=False)

    wasm_target_dir = os.path.join(HANGA_DIR, "target", "wasm32-unknown-unknown", "release")
    wasm_tools = shutil.which("wasm-tools") or "wasm-tools"

    for m in mods:
        in_wasm = os.path.join(wasm_target_dir, f"{m}.wasm")
        out_wasm = os.path.join(mods_out, f"{m}.wasm")
        print(f"Creating WASM component for {m} -> {out_wasm}...")
        res = subprocess.run([wasm_tools, "component", "new", in_wasm, "-o", out_wasm])
        if res.returncode != 0:
            print(f"Failed to create component for {m}", file=sys.stderr)
            sys.exit(res.returncode)

        assets_dir = os.path.join(HANGA_DIR, "mods", m, "assets")
        if os.path.isdir(assets_dir):
            dest_assets = os.path.join(mods_out, m, "assets")
            shutil.copytree(assets_dir, dest_assets, dirs_exist_ok=True)

    print("Copying games and wit...")
    games_src = os.path.join(HANGA_DIR, "games")
    if os.path.isdir(games_src):
        for item in os.listdir(games_src):
            s = os.path.join(games_src, item)
            d = os.path.join(games_out, item)
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True)
            else:
                shutil.copy2(s, d)

    wit_src = os.path.join(HANGA_DIR, "wit")
    if os.path.isdir(wit_src):
        for item in os.listdir(wit_src):
            s = os.path.join(wit_src, item)
            d = os.path.join(wit_out, item)
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True)
            else:
                shutil.copy2(s, d)

    print(f"Hanga mods & assets successfully packaged in: {out_dir}")


if __name__ == "__main__":
    main()
