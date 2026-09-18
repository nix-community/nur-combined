#!/usr/bin/env nix
#! nix shell --inputs-from .# nixpkgs#python3 --command python3
# ruff: noqa: EXE005

import html
import json
import re
import subprocess
from collections import defaultdict
from pathlib import Path

BEGIN_MARKER = "<!-- BEGIN GENERATED PACKAGE DOCS -->"
END_MARKER = "<!-- END GENERATED PACKAGE DOCS -->"
REPOSITORY = "github:XYenon/nur-packages"
ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"


def load_packages():
    result = subprocess.run(
        [
            "nix",
            "eval",
            "--json",
            "--file",
            str(ROOT / "scripts/generate-package-docs.nix"),
        ],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    return json.loads(result.stdout)


def validate(package):
    missing = []
    for field in ("description", "homepage", "license", "version"):
        if not package.get(field):
            missing.append(field)
    if package.get("license") and any(
        not license_name for license_name in package["license"]
    ):
        missing.append("license")
    return missing


def summary_description(description):
    plain = re.sub(r"\[([^]]+)]\([^)]+\)", r"\1", description)
    return html.escape(plain)


def render_package(package):
    attr = package["attr"]
    licenses = ", ".join(dict.fromkeys(package["license"]))
    homepage = package["homepage"]
    return "\n".join(
        [
            "<details>",
            (
                f"<summary><strong><code>{html.escape(attr)}</code></strong> — "
                f"{summary_description(package['description'])}</summary>"
            ),
            "",
            f"- **Version:** `{package['version']}`",
            f"- **License:** {licenses}",
            f"- **Homepage:** [{homepage}]({homepage})",
            f"- **Build:** `nix build {REPOSITORY}#{attr}`",
            "",
            "</details>",
        ]
    )


def render(packages):
    visible = [package for package in packages if not package["hidden"]]
    invalid = {
        package["attr"]: missing
        for package in visible
        if (missing := validate(package))
    }
    if invalid:
        details = "\n".join(
            f"  {attr}: {', '.join(fields)}" for attr, fields in sorted(invalid.items())
        )
        raise SystemExit(f"Packages have incomplete documentation metadata:\n{details}")

    deduplicated = {}
    for package in sorted(
        visible, key=lambda item: (item["attr"].count("."), item["attr"])
    ):
        identity = (
            package["name"],
            package["version"],
            package["description"],
            package["homepage"],
            tuple(package["license"]),
        )
        deduplicated.setdefault(identity, package)

    groups = defaultdict(list)
    for package in deduplicated.values():
        top_level, separator, _ = package["attr"].partition(".")
        group = top_level if separator else "Top-level packages"
        groups[group].append(package)

    ordered_groups = ["Top-level packages"] + sorted(
        group for group in groups if group != "Top-level packages"
    )
    sections = []
    for group in ordered_groups:
        if group not in groups:
            continue
        entries = "\n\n".join(
            render_package(package)
            for package in sorted(groups[group], key=lambda item: item["attr"])
        )
        sections.append(f"### {group}\n\n{entries}")
    return "\n\n".join(sections)


def update_readme(generated):
    content = README.read_text()
    if content.count(BEGIN_MARKER) != 1 or content.count(END_MARKER) != 1:
        raise SystemExit(
            "README must contain exactly one pair of package documentation markers"
        )

    before, remainder = content.split(BEGIN_MARKER)
    _, after = remainder.split(END_MARKER)

    updated = f"{before}{BEGIN_MARKER}\n\n{generated}\n\n{END_MARKER}{after}"
    if updated != content:
        README.write_text(updated)


if __name__ == "__main__":
    update_readme(render(load_packages()))
