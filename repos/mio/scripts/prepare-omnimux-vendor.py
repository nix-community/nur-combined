#!/usr/bin/env python3
"""
Prepares the vendored dependencies for omnimux when building in non-Nix environments.
Downloads upstream crate tarballs and GitHub archives, extracts them to
`by-name/om/omnimux/src/vendor/`, and applies the local patches.
"""

import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OMNIMUX_DIR = os.path.join(REPO_ROOT, "by-name", "om", "omnimux")
VENDOR_DIR = os.path.join(OMNIMUX_DIR, "src", "vendor")
PATCHES_DIR = os.path.join(OMNIMUX_DIR, "patches")

SOURCES = [
    {
        "name": "alacritty_terminal",
        "url": "https://static.crates.io/crates/alacritty_terminal/alacritty_terminal-0.26.0.crate",
        "archive_subfolder": "alacritty_terminal-0.26.0",
        "dest": "alacritty_terminal",
        "patch": os.path.join(PATCHES_DIR, "alacritty_terminal.patch"),
    },
    {
        "name": "gpui-pre-linux",
        "url": "https://static.crates.io/crates/gpui-pre-linux/gpui-pre-linux-0.3.8.crate",
        "archive_subfolder": "gpui-pre-linux-0.3.8",
        "dest": "gpui-pre-linux",
        "patch": os.path.join(PATCHES_DIR, "gpui-pre-linux.patch"),
    },
    {
        "name": "gpui-pre-wgpu",
        "url": "https://static.crates.io/crates/gpui-pre-wgpu/gpui-pre-wgpu-0.3.8.crate",
        "archive_subfolder": "gpui-pre-wgpu-0.3.8",
        "dest": "gpui-pre-wgpu",
        "patch": os.path.join(PATCHES_DIR, "gpui-pre-wgpu.patch"),
    },
    {
        "name": "gpui-pre-macos",
        "url": "https://static.crates.io/crates/gpui-pre-macos/gpui-pre-macos-0.3.8.crate",
        "archive_subfolder": "gpui-pre-macos-0.3.8",
        "dest": "gpui-pre-macos",
        "patch": os.path.join(PATCHES_DIR, "gpui-pre-macos.patch"),
    },
    {
        "name": "gpui-terminal",
        "url": "https://github.com/zortax/gpui-terminal/archive/45c63e57181d27c260124a81c7e4b68a6b6e57b0.tar.gz",
        "archive_subfolder": "gpui-terminal-45c63e57181d27c260124a81c7e4b68a6b6e57b0",
        "dest": "gpui-terminal",
        "patch": os.path.join(PATCHES_DIR, "gpui-terminal.patch"),
    },
]


def apply_patch(target_dir: str, patch_file: str):
    print(f"Applying patch {os.path.basename(patch_file)} in {target_dir}...")
    # Try git apply first
    res = subprocess.run(
        ["git", "apply", "--whitespace=nowarn", "-p1", patch_file],
        cwd=target_dir,
        capture_output=True,
        text=True,
    )
    if res.returncode == 0:
        return

    # Fallback to patch -p1
    patch_bin = shutil.which("patch") or "patch"
    res2 = subprocess.run(
        [patch_bin, "-p1", "-i", patch_file],
        cwd=target_dir,
        capture_output=True,
        text=True,
    )
    if res2.returncode != 0:
        print(f"Error applying patch {patch_file}:\nGit stderr: {res.stderr}\nPatch stderr: {res2.stderr}", file=sys.stderr)
        sys.exit(1)


def main():
    os.makedirs(VENDOR_DIR, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmpdir:
        for item in SOURCES:
            dest_dir = os.path.join(VENDOR_DIR, item["dest"])
            if os.path.exists(dest_dir):
                print(f"Cleaning existing directory {dest_dir}...")
                shutil.rmtree(dest_dir)

            tar_filename = os.path.join(tmpdir, f"{item['name']}.tar.gz")
            print(f"Downloading {item['name']} from {item['url']}...")
            req = urllib.request.Request(
                item["url"],
                headers={"User-Agent": "Mozilla/5.0 (OmnimuxVendorDownloader/1.0)"},
            )
            with urllib.request.urlopen(req) as resp, open(tar_filename, "wb") as f:
                shutil.copyfileobj(resp, f)

            extract_dir = os.path.join(tmpdir, f"extract_{item['name']}")
            os.makedirs(extract_dir, exist_ok=True)
            with tarfile.open(tar_filename, "r:*") as tar:
                tar.extractall(extract_dir)

            src_folder = os.path.join(extract_dir, item["archive_subfolder"])
            if not os.path.isdir(src_folder):
                # Try finding first subdirectory
                subdirs = [d for d in os.listdir(extract_dir) if os.path.isdir(os.path.join(extract_dir, d))]
                if subdirs:
                    src_folder = os.path.join(extract_dir, subdirs[0])
                else:
                    src_folder = extract_dir

            shutil.copytree(src_folder, dest_dir)

            if item.get("patch") and os.path.isfile(item["patch"]):
                apply_patch(dest_dir, item["patch"])

    print("All Omnimux vendored dependencies prepared successfully in:", VENDOR_DIR)


if __name__ == "__main__":
    main()
