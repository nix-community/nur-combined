#!/usr/bin/env python3
"""Regenerate the package table in README.md from the flake's own outputs.

No package names are hardcoded here: every package exposed by
`packages.<system>` (except the `default` alias) gets a row, built from its
`meta.description` / `meta.homepage`, plus the upstream commit date for the
pinned `rev` (fetched from the GitHub API), so the table shows how fresh
each pinned version actually is.
"""
import json
import os
import pathlib
import re
import subprocess
import sys
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
PKGS_DIR = ROOT / "pkgs"
README = ROOT / "README.md"
START = "<!-- PACKAGES:START -->"
END = "<!-- PACKAGES:END -->"


def current_system() -> str:
    return subprocess.run(
        ["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()


def package_metadata(system: str) -> dict:
    expr = (
        "pkgs: builtins.mapAttrs (name: pkg: {"
        ' description = pkg.meta.description or "";'
        ' homepage = pkg.meta.homepage or "";'
        "}) (builtins.removeAttrs pkgs [\"default\"])"
    )
    out = subprocess.run(
        ["nix", "eval", "--json", f".#packages.{system}", "--apply", expr],
        check=True, capture_output=True, text=True, cwd=ROOT,
    ).stdout
    return json.loads(out)


def pinned_rev(name: str) -> str | None:
    """Extract the literal `rev` pinned in pkgs/<name>/default.nix, resolving
    a `${version}` interpolation if present."""
    default_nix = PKGS_DIR / name / "default.nix"
    if not default_nix.is_file():
        return None
    content = default_nix.read_text()

    rev_match = re.search(r'\brev\s*=\s*"([^"]+)"', content)
    if not rev_match:
        return None
    rev = rev_match.group(1)

    if "${version}" in rev:
        version_match = re.search(r'\bversion\s*=\s*"([^"]+)"', content)
        if not version_match:
            return None
        rev = rev.replace("${version}", version_match.group(1))

    return rev


def upstream_commit_date(homepage: str, rev: str) -> str | None:
    match = re.match(r"https://github\.com/([^/]+)/([^/]+)/?$", homepage)
    if not match:
        return None
    owner, repo = match.groups()

    url = f"https://api.github.com/repos/{owner}/{repo}/commits/{rev}"
    req = urllib.request.Request(url, headers={"User-Agent": "nur-packages-readme-bot"})
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        req.add_header("Authorization", f"Bearer {token}")

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.load(resp)
    except (urllib.error.URLError, urllib.error.HTTPError) as exc:
        print(f"warning: could not fetch commit date for {owner}/{repo}@{rev}: {exc}", file=sys.stderr)
        return None

    date = data.get("commit", {}).get("committer", {}).get("date")
    return date.split("T")[0] if date else None


def render_table(meta: dict) -> str:
    lines = [
        "| Package | Description | Source | Updated |",
        "| --- | --- | --- | --- |",
    ]
    for name in sorted(meta):
        info = meta[name]
        description = info["description"].strip()
        homepage = info["homepage"]
        label = homepage.removeprefix("https://github.com/") if homepage else homepage
        source = f"[{label}]({homepage})" if homepage else ""

        updated = ""
        rev = pinned_rev(name)
        if homepage and rev:
            updated = upstream_commit_date(homepage, rev) or ""

        lines.append(f"| `{name}` | {description} | {source} | {updated} |")
    return "\n".join(lines)


def main() -> None:
    system = current_system()
    meta = package_metadata(system)
    table = render_table(meta)

    content = README.read_text()
    pattern = re.compile(re.escape(START) + r".*" + re.escape(END), re.S)
    if not pattern.search(content):
        raise SystemExit(f"README.md is missing {START}/{END} markers")

    README.write_text(pattern.sub(f"{START}\n{table}\n{END}", content))


if __name__ == "__main__":
    main()
