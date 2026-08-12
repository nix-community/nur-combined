from __future__ import annotations

import json
import re
from pathlib import Path

from .models import PackageState, SourceKind
from .process import ROOT, run
from .versions import version_mode


def nix_eval_attrset(source_kind: SourceKind, attrset: str, apply_expr: str) -> str:
    if source_kind == "flake":
        command = ["nix", "eval", "--raw", f".#{attrset}", "--apply", apply_expr]
    else:
        command = [
            "nix",
            "eval",
            "--raw",
            "--file",
            "default.nix",
            attrset,
            "--apply",
            apply_expr,
        ]
    return run(command).stdout


def list_derivations(source_kind: SourceKind, attrset: str) -> list[str]:
    output = nix_eval_attrset(
        source_kind,
        attrset,
        r"""
pkgs:
  builtins.concatStringsSep "\n"
  (builtins.filter
    (name:
      let v = builtins.getAttr name pkgs;
      in builtins.isAttrs v && v ? type && v.type == "derivation")
    (builtins.attrNames pkgs))
""",
    )
    return [line for line in output.splitlines() if line]


def list_file_attrsets() -> list[str]:
    output = run(
        [
            "nix",
            "eval",
            "--raw",
            "--file",
            "default.nix",
            "--apply",
            r"""
f:
let
  attrs = f {};
  isDerivation = v: builtins.isAttrs v && v ? type && v.type == "derivation";
  hasDerivationMembers = set:
    builtins.any (name: isDerivation (builtins.getAttr name set)) (builtins.attrNames set);
in
  builtins.concatStringsSep "\n"
  (builtins.filter
    (name:
      let v = builtins.getAttr name attrs;
      in builtins.isAttrs v && !isDerivation v && hasDerivationMembers v)
    (builtins.attrNames attrs))
""",
        ]
    ).stdout
    return [line for line in output.splitlines() if line]


def flake_attrsets(system: str) -> list[str]:
    attrset = f"packages.{system}"
    result = run(["nix", "eval", "--raw", f".#{attrset}", "--apply", 'pkgs: ""'], check=False)
    return [attrset] if result.returncode == 0 else []


def read_state(source_kind: SourceKind, attrset: str, attr: str) -> PackageState:
    escaped = _escape(attr)
    output = nix_eval_attrset(
        source_kind,
        attrset,
        f'''
pkgs:
  let
    pkg = builtins.getAttr "{escaped}" pkgs;
    src = if builtins.isAttrs pkg && pkg ? src then pkg.src else {{}};
  in builtins.toJSON {{
    version = if builtins.isAttrs pkg && pkg ? version then pkg.version else "";
    srcUrl = if builtins.isAttrs src && src ? url then src.url else null;
    srcRev = if builtins.isAttrs src && src ? rev then src.rev else null;
    srcHash = if builtins.isAttrs src && src ? outputHash then src.outputHash else null;
    dependencyHash = if builtins.isAttrs pkg && pkg ? dependencyHash then pkg.dependencyHash else null;
  }}
''',
    )
    data = json.loads(output)
    version = data.get("version") or ""
    return PackageState(
        version=version,
        version_mode=version_mode(version),
        src_url=data.get("srcUrl"),
        src_rev=data.get("srcRev"),
        src_hash=data.get("srcHash"),
        dependency_hash=data.get("dependencyHash"),
    )


def attr_file_path(source_kind: SourceKind, attrset: str, attr: str) -> Path | None:
    escaped = _escape(attr)
    position = nix_eval_attrset(
        source_kind,
        attrset,
        f'''
pkgs:
  let pkg = builtins.getAttr "{escaped}" pkgs;
  in if builtins.isAttrs pkg && pkg ? meta && pkg.meta ? position then pkg.meta.position else ""
''',
    ).strip()
    if not position:
        return None

    file_name = position.split(":", 1)[0]
    if source_kind == "flake":
        match = re.match(r"^/nix/store/[^/]+-source(/.*)$", file_name)
        if match:
            file_name = str(ROOT) + match.group(1)

    file_path = Path(file_name)
    if not file_path.is_relative_to(ROOT) or not file_path.is_file():
        return None

    root_dir = file_path.parent
    for candidate in (root_dir / attr / "default.nix", root_dir / f"{attr}.nix"):
        if candidate.is_file():
            return candidate
    return file_path


def _escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')
