#!/usr/bin/env python3
"""
build_conda.py - Generates an official, standard noarch: python conda package
for upload to anaconda.org (Anaconda Cloud).
"""

import os
import sys
import json
import zipfile
import tarfile
import hashlib
import time
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
PYTHON_DIR = ROOT_DIR / "python"
DIST_DIR = ROOT_DIR / "conda" / "dist" / "noarch"
WHEEL_PATH = PYTHON_DIR / "dist" / "seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl"
RECIPE_DIR = ROOT_DIR / "conda" / "recipe"

def sha256_file(filepath):
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def main():
    if not WHEEL_PATH.exists():
        print(f"Error: wheel not found at {WHEEL_PATH}")
        sys.exit(1)

    DIST_DIR.mkdir(parents=True, exist_ok=True)
    temp_dir = ROOT_DIR / "conda" / "build_temp"
    if temp_dir.exists():
        import shutil
        shutil.rmtree(temp_dir)
    temp_dir.mkdir(parents=True)

    site_packages = temp_dir / "site-packages"
    site_packages.mkdir(parents=True)

    print(f"Extracting wheel: {WHEEL_PATH.name}...")
    with zipfile.ZipFile(WHEEL_PATH, "r") as z:
        z.extractall(site_packages)

    info_dir = temp_dir / "info"
    info_dir.mkdir(parents=True)

    # 1. info/index.json
    now_ms = int(time.time() * 1000)
    index_json = {
        "arch": None,
        "build": "py_0",
        "build_number": 0,
        "depends": [
            "python >=3.8",
            "requests >=2.25.0"
        ],
        "license": "MIT",
        "license_family": "MIT",
        "name": "seowebchecker-seoaudit-sdk",
        "noarch": "python",
        "platform": None,
        "subdir": "noarch",
        "timestamp": now_ms,
        "version": "1.0.0"
    }
    with open(info_dir / "index.json", "w", encoding="utf-8") as f:
        json.dump(index_json, f, indent=2)

    # 2. info/about.json
    about_json = {
        "description": "Automated on-page technical SEO diagnostic engine and client SDK for meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics. Powered by SEOWebChecker (https://seowebchecker.com/).",
        "dev_url": "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk",
        "doc_url": "https://seowebchecker.com/",
        "home": "https://seowebchecker.com/",
        "license": "MIT",
        "license_family": "MIT",
        "summary": "Lightweight client SDK for automated on-page technical SEO audits and Core Web Vitals checks."
    }
    with open(info_dir / "about.json", "w", encoding="utf-8") as f:
        json.dump(about_json, f, indent=2)

    # 3. info/link.json
    link_json = {
        "noarch": {
            "type": "python",
            "entry_points": [
                "seowebchecker = seowebchecker_seoaudit.cli:main"
            ]
        },
        "package_metadata_version": 1
    }
    with open(info_dir / "link.json", "w", encoding="utf-8") as f:
        json.dump(link_json, f, indent=2)

    # 4. info/recipe/meta.yaml
    recipe_copy_dir = info_dir / "recipe"
    recipe_copy_dir.mkdir(parents=True)
    if (RECIPE_DIR / "meta.yaml").exists():
        with open(RECIPE_DIR / "meta.yaml", "r", encoding="utf-8") as src:
            with open(recipe_copy_dir / "meta.yaml", "w", encoding="utf-8") as dst:
                dst.write(src.read())

    # 5. List all files and paths.json
    files_list = []
    paths_data = []

    for root, _, filenames in os.walk(temp_dir):
        for fname in filenames:
            fpath = Path(root) / fname
            rel_path = fpath.relative_to(temp_dir).as_posix()
            if rel_path.startswith("info/"):
                # info files except recipe are not in files/paths
                if not rel_path.startswith("info/recipe/"):
                    continue

            files_list.append(rel_path)
            paths_data.append({
                "_path": rel_path,
                "path_type": "hardlink",
                "sha256": sha256_file(fpath),
                "size_in_bytes": fpath.stat().st_size
            })

    files_list.sort()
    paths_data.sort(key=lambda x: x["_path"])

    with open(info_dir / "files", "w", encoding="utf-8") as f:
        for p in files_list:
            f.write(p + "\n")

    paths_json = {
        "paths": paths_data,
        "paths_version": 1
    }
    with open(info_dir / "paths.json", "w", encoding="utf-8") as f:
        json.dump(paths_json, f, indent=2)

    # Create tar.bz2 conda package
    out_archive = DIST_DIR / "seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2"
    print(f"Creating conda package: {out_archive}...")
    with tarfile.open(out_archive, "w:bz2", format=tarfile.USTAR_FORMAT) as tar:
        for root, dirs, filenames in os.walk(temp_dir):
            for fname in filenames:
                fpath = Path(root) / fname
                rel_path = fpath.relative_to(temp_dir).as_posix()
                tar.add(fpath, arcname=rel_path)

    import shutil
    shutil.rmtree(temp_dir)
    print(f"Successfully generated Conda package: {out_archive} ({out_archive.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
