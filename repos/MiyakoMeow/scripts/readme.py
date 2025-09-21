#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent
PKGS_DIR = REPO_ROOT / "pkgs"
README = REPO_ROOT / "README.md"
GITHUB_REPO = "MiyakoMeow/nur-packages"
DEFAULT_BRANCH = "main"
DEFAULT_SYSTEM = os.environ.get("NIX_SYSTEM", "x86_64-linux")

BEGIN_MARK = "<!-- BEGIN_PACKAGE_LIST -->"
END_MARK = "<!-- END_PACKAGE_LIST -->"


def run(cmd: List[str], cwd: Optional[Path] = None) -> Tuple[int, str, str]:
    proc = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    return proc.returncode, proc.stdout, proc.stderr


def nix_eval_for_pkg(
    package_file: Path, system: str = DEFAULT_SYSTEM
) -> Dict[str, Optional[str]]:
    expr = (
        """
let
  flake = builtins.getFlake "path:{repo}";
  pkgs = import flake.inputs.nixpkgs {{ system = "{system}"; }};
  lib = pkgs.lib;
  v = pkgs.callPackage {pkg} {{}};
  target =
    if lib.isDerivation v then v
    else if lib.isAttrs v && v ? meta && lib.isDerivation v.meta then v.meta
    else throw "not a derivation";
  getName = drv: if drv ? pname then drv.pname else lib.getName drv;
  getVersion = drv: if drv ? version then drv.version else lib.getVersion drv;
  getDesc = drv: if drv ? meta && drv.meta ? description then drv.meta.description else (if drv ? description then drv.description else "");
  getHomePage = drv: if drv ? meta && drv.meta ? homepage then drv.meta.homepage else "";
  getChangelog = drv: if drv ? meta && drv.meta ? changelog then drv.meta.changelog else "";
  in {{ pname = getName target; version = getVersion target; description = getDesc target; homepage = getHomePage target; changelog = getChangelog target; }}
"""
    ).format(repo=str(REPO_ROOT), system=system, pkg=str(package_file))
    code, out, err = run(
        [
            "nix",
            "eval",
            "--impure",
            "--json",
            "--extra-experimental-features",
            "nix-command flakes",
            "--expr",
            expr,
        ],
        cwd=REPO_ROOT,
    )
    if code != 0:
        raise RuntimeError(
            f"nix eval failed for {package_file}: {err}\nExpression was:\n{expr}"
        )
    return json.loads(out)


def nix_list_children(
    package_file: Path, system: str = DEFAULT_SYSTEM
) -> List[Dict[str, Optional[str]]]:
    expr = (
        """
let
  flake = builtins.getFlake "path:{repo}";
  pkgs = import flake.inputs.nixpkgs {{ system = "{system}"; }};
  lib = pkgs.lib;
  v = pkgs.callPackage {pkg} {{}};
  children =
    if lib.isDerivation v then {{}} else
    if lib.isAttrs v then v else {{}};
  names = lib.filter (n: n != "meta" && (builtins.hasAttr n children) && lib.isDerivation (builtins.getAttr n children)) (lib.attrNames children);
  toObj = name:
    let drv = builtins.getAttr name children; in
    {{ name = name;
       version = if drv ? version then drv.version else lib.getVersion drv;
       description = if drv ? meta && drv.meta ? description then drv.meta.description else (if drv ? description then drv.description else "");
       homepage = if drv ? meta && drv.meta ? homepage then drv.meta.homepage else "";
       changelog = if drv ? meta && drv.meta ? changelog then drv.meta.changelog else "";
    }};
  in map toObj names
"""
    ).format(repo=str(REPO_ROOT), system=system, pkg=str(package_file))
    code, out, err = run(
        [
            "nix",
            "eval",
            "--impure",
            "--json",
            "--extra-experimental-features",
            "nix-command flakes",
            "--expr",
            expr,
        ],
        cwd=REPO_ROOT,
    )
    if code != 0:
        return []
    try:
        return json.loads(out)
    except Exception:
        return []


essential_groups_order = [
    "by-name",
]


def find_packages() -> Dict[str, List[Dict[str, str]]]:
    groups: Dict[str, List[Dict[str, str]]] = {}

    for entry in sorted(PKGS_DIR.iterdir()):
        if not entry.is_dir():
            continue
        if entry.name == "by-name":
            continue
        group = entry.name

        direct_pkg = None
        if (entry / "package.nix").is_file():
            direct_pkg = entry / "package.nix"
        elif (entry / "default.nix").is_file():
            direct_pkg = entry / "default.nix"
        if direct_pkg:
            groups.setdefault(group, []).append(
                {
                    "usable_path": group,
                    "file": os.path.relpath(direct_pkg, REPO_ROOT),
                }
            )

        for sub in sorted(entry.iterdir()):
            if not sub.is_dir():
                continue
            pkg_file = None
            if (sub / "package.nix").is_file():
                pkg_file = sub / "package.nix"
            elif (sub / "default.nix").is_file():
                pkg_file = sub / "default.nix"
            if pkg_file:
                usable_path = f"{group}.{sub.name}"
                groups.setdefault(group, []).append(
                    {
                        "usable_path": usable_path,
                        "file": os.path.relpath(pkg_file, REPO_ROOT),
                    }
                )

    by_name_root = PKGS_DIR / "by-name"
    if by_name_root.is_dir():
        for prefix in sorted(by_name_root.iterdir()):
            if not prefix.is_dir():
                continue
            for pkgdir in sorted(prefix.iterdir()):
                if not pkgdir.is_dir():
                    continue
                pkg_file = pkgdir / "package.nix"
                if pkg_file.is_file():
                    groups.setdefault("by-name", []).append(
                        {
                            "usable_path": pkgdir.name,
                            "file": os.path.relpath(pkg_file, REPO_ROOT),
                        }
                    )
    return groups


def build_markdown(groups: Dict[str, List[Dict[str, str]]]) -> str:
    lines: List[str] = []
    lines.append("This section is auto-generated. Do not edit manually.")
    lines.append("")

    ordered_groups = [g for g in essential_groups_order if g in groups] + [
        g for g in sorted(groups.keys()) if g not in essential_groups_order
    ]

    for group in ordered_groups:
        entries = sorted(groups[group], key=lambda x: x["usable_path"].lower())

        rows: List[Tuple[str, str, str, str]] = []
        for e in entries:
            file_rel = e["file"]
            file_abs = REPO_ROOT / file_rel

            children = nix_list_children(file_abs)
            if children:
                for child in children:
                    usable = f"{e['usable_path']}.{child['name']}"
                    version = child.get("version") or "-"
                    desc = child.get("description") or ""
                    homepage = child.get("homepage")
                    changelog = child.get("changelog")
                    if changelog:
                        desc = f"[📝Changelog]({changelog}) {desc}"
                    if homepage:
                        desc = f"[🏠Homepage]({homepage}) {desc}"
                    rows.append((usable, version, desc, file_rel))
                continue

            try:
                meta = nix_eval_for_pkg(file_abs)
            except Exception as exc:
                print(
                    f"Skip non-derivation or eval error for {file_rel}: {exc}",
                    file=sys.stderr,
                )
                continue
            version = meta.get("version") or "-"
            desc = meta.get("description") or ""
            homepage = meta.get("homepage")
            changelog = meta.get("changelog")
            if changelog:
                desc = f"[📝Changelog]({changelog}) {desc}"
            if homepage:
                desc = f"[🏠Homepage]({homepage}) {desc}"
            rows.append((e["usable_path"], version, desc, file_rel))

        if not rows:
            continue

        lines.append(f"### {group}")
        lines.append("")
        lines.append("| useable-path | version | description |")
        lines.append("| --- | --- | --- |")
        for usable, version, desc, file_rel in rows:
            file_url = (
                f"https://github.com/{GITHUB_REPO}/blob/{DEFAULT_BRANCH}/{file_rel}"
            )
            lines.append(f"| `{usable}` | [{version}]({file_url}) | {desc} |")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def update_readme(content: str) -> None:
    text = README.read_text(encoding="utf-8")

    if BEGIN_MARK in text and END_MARK in text:
        pattern = re.compile(
            re.escape(BEGIN_MARK) + r"[\s\S]*?" + re.escape(END_MARK), re.MULTILINE
        )
        new_block = BEGIN_MARK + "\n\n" + content + "\n" + END_MARK
        text = pattern.sub(new_block, text)
    else:
        heading_regex = re.compile(r"(^## Package List\s*$)", re.MULTILINE)
        if heading_regex.search(text):
            insert_block = BEGIN_MARK + "\n\n" + content + "\n" + END_MARK
            text = heading_regex.sub(r"\1\n\n" + insert_block, text)
        else:
            insert_block = (
                "\n\n## Package List\n\n"
                + BEGIN_MARK
                + "\n\n"
                + content
                + "\n"
                + END_MARK
                + "\n"
            )
            text = text.rstrip() + insert_block

    README.write_text(text, encoding="utf-8")


def main() -> int:
    groups = find_packages()
    md = build_markdown(groups)
    update_readme(md)
    return 0


if __name__ == "__main__":
    sys.exit(main())
