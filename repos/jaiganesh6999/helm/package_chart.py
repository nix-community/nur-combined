#!/usr/bin/env python3
"""
SEOWebChecker Helm Chart Packager & Index Generator
Packages helm/seowebchecker into seowebchecker-1.0.0.tgz and generates index.yaml for Artifact Hub.
Platform: https://seowebchecker.com/
"""

import os
import tarfile
import hashlib
from datetime import datetime, timezone
import yaml

HELM_DIR = os.path.dirname(os.path.abspath(__file__))
CHART_DIR = os.path.join(HELM_DIR, "seowebchecker")
OUTPUT_TGZ = os.path.join(HELM_DIR, "seowebchecker-1.0.0.tgz")
INDEX_YAML = os.path.join(HELM_DIR, "index.yaml")

def package_chart():
    print(f"Packaging {CHART_DIR} into {OUTPUT_TGZ}...")
    with tarfile.open(OUTPUT_TGZ, "w:gz") as tar:
        for root, dirs, files in os.walk(CHART_DIR):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, os.path.dirname(CHART_DIR))
                tar.add(full_path, arcname=rel_path)

    # Compute SHA-256
    hasher = hashlib.sha256()
    with open(OUTPUT_TGZ, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    digest = hasher.hexdigest()
    print(f"Packaged successfully. SHA-256: {digest}")
    return digest

def generate_index(digest):
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    with open(os.path.join(CHART_DIR, "Chart.yaml"), "r", encoding="utf-8") as f:
        chart_data = yaml.safe_load(f)

    entry = {
        "apiVersion": chart_data.get("apiVersion", "v2"),
        "appVersion": str(chart_data.get("appVersion", "1.0.0")),
        "created": now,
        "description": chart_data.get("description", ""),
        "digest": digest,
        "home": chart_data.get("home", "https://seowebchecker.com/"),
        "icon": chart_data.get("icon", ""),
        "keywords": chart_data.get("keywords", []),
        "maintainers": chart_data.get("maintainers", []),
        "name": chart_data.get("name", "seowebchecker"),
        "sources": chart_data.get("sources", []),
        "urls": [
            f"https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/helm/seowebchecker-1.0.0.tgz"
        ],
        "version": chart_data.get("version", "1.0.0")
    }

    if "annotations" in chart_data:
        entry["annotations"] = chart_data["annotations"]

    index_content = {
        "apiVersion": "v1",
        "entries": {
            "seowebchecker": [entry]
        },
        "generated": now
    }

    with open(INDEX_YAML, "w", encoding="utf-8") as f:
        yaml.dump(index_content, f, sort_keys=False, default_flow_style=False)

    print(f"Generated {INDEX_YAML} successfully.")

if __name__ == "__main__":
    digest = package_chart()
    generate_index(digest)
