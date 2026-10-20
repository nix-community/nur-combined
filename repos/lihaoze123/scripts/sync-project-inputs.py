#!/usr/bin/env python3
"""Snapshot upstream Nix recipes and evaluation metadata for the standard NUR entry.

Flake inputs are maintenance pins only. Packages never import remote expressions
or read fetched sources during evaluation. Run after updating a project input.
"""

import argparse
import json
import re
from pathlib import Path
import shutil
import subprocess
import textwrap
import tomllib

ROOT = Path(__file__).resolve().parents[1]
PROJECTS = {
    "computer-use": ("lihaoze123", "niri-computer-use"),
    "dms-xhup": ("lihaoze123", "dms-xhup"),
    "edunet": ("lihaoze123", "hhu-edunet-cli"),
    "gxfp5130Chicago": ("lihaoze123", "gxfp5130-chicago"),
}


def write(path, content):
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content)


def write_json(path, value):
    write(path, json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def copy(source, target):
    destination = ROOT / target
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)


def replace(text, old, new):
    if text.count(old) != 1:
        raise ValueError(f"Upstream recipe changed; review the snapshot adapter: {old[:100]}")
    return text.replace(old, new, 1)


def block(text, start, end, replacement):
    first = text.index(start)
    last = text.index(end, first)
    return text[:first] + replacement + text[last:]


def source_info(target):
    name = json.dumps(target)
    nested = ""
    if target == "computer-use":
        nested = '''
          desktop = pick f.inputs.computer-use.inputs.codex-desktop-current;
          backend = pick f.inputs.computer-use.inputs.codex-desktop-linux;
          niri = pick f.inputs.computer-use.inputs.niri-src;
        '''
    expression = '''
      let f = builtins.getFlake (toString ./.);
          pick = input: { path = input.outPath; inherit (input) rev narHash lastModified; };
      in { project = pick f.inputs.%s; %s }
    ''' % (name, nested)
    return json.loads(subprocess.check_output(
        ["nix", "eval", "--impure", "--json", "--no-write-lock-file", "--expr", expression],
        cwd=ROOT, text=True,
    ))


def pin(info, owner, repo):
    return {"owner": owner, "repo": repo, "rev": info["rev"], "hash": info["narHash"],
            "lastModified": info["lastModified"]}


def group(package, target):
    write_json(f"pkgs/{package}/update.json", {"group": target})


def sync_dms(info):
    source = Path(info["project"]["path"])
    metadata = pin(info["project"], *PROJECTS["dms-xhup"])
    metadata["version"] = json.loads((source / "plugin.json").read_text())["version"]
    write_json("pkgs/dms-xhup/source.json", metadata)
    group("dms-xhup", "dms-xhup")


def sync_edunet(info):
    source = Path(info["project"]["path"])
    metadata = pin(info["project"], *PROJECTS["edunet"])
    metadata["version"] = tomllib.loads((source / "pyproject.toml").read_text())["project"]["version"]
    typer = next(package for package in tomllib.loads((source / "uv.lock").read_text())["package"]
                 if package["name"] == "typer")
    wheel = next(wheel for wheel in typer["wheels"] if wheel["url"].endswith("-py3-none-any.whl"))
    metadata["typer"] = {"version": typer["version"], "url": wheel["url"], "hash": wheel["hash"]}
    write_json("pkgs/edunet/source.json", metadata)
    text = (source / "nix/nixos.nix").read_text()
    text = replace(text, "{ self }:\n", "")
    text = replace(text, "self.packages.${pkgs.stdenv.hostPlatform.system}.default",
                   "(import ../../default.nix { inherit pkgs; }).edunet")
    write("nixos-modules/edunet/default.nix", text)
    options = (source / "nix/options.nix").read_text().replace(
        '"edunet.packages.<system>.default"', '"nur.repos.lihaoze123.edunet"')
    write("nixos-modules/edunet/options.nix", options)
    group("edunet", "edunet")


def sync_fingerprint(info):
    source = Path(info["project"]["path"])
    write_json("pkgs/gxfp5130-libfprint/source.json", pin(info["project"], *PROJECTS["gxfp5130Chicago"]))
    for package, filename, subdir in [("gxfp5130-libfprint", "libfprint", "libfprint"),
                                      ("gxfp5130-kernel", "kernel", "kernel")]:
        text = (source / f"nix/{filename}.nix").read_text()
        text = replace(text, "  stdenv,", "  stdenv,\n  fetchFromGitHub,")
        text = replace(text, "}:\nstdenv.mkDerivation", "}:\nlet pin = lib.importJSON ../gxfp5130-libfprint/source.json;\nin\nstdenv.mkDerivation")
        text = replace(text, f"src = lib.sources.cleanSource ../{subdir};",
                       f'src = fetchFromGitHub {{ inherit (pin) owner repo rev hash; }};\n  sourceRoot = "source/{subdir}";')
        if filename == "kernel":
            text = replace(text, "  kernel,", "  kernel ? linuxPackages.kernel,\n  linuxPackages,")
        write(f"pkgs/{package}/default.nix", text)
    text = (source / "nix/fprintd.nix").read_text().replace("libfprint-gxfp", "gxfp5130-libfprint")
    # Do not inherit a nixpkgs maintainer entry for this downstream fork.
    text = replace(text, "maintainers = with lib.maintainers; [abbradar];", "maintainers = [];" )
    write("pkgs/gxfp5130-fprintd/default.nix", text)
    for patch in ["skip-test-test_removal_during_enroll.patch", "chicago-study-persistence.patch"]:
        copy(source / f"nix/{patch}", f"pkgs/gxfp5130-fprintd/{patch}")
    text = (source / "nix/module.nix").read_text()
    text = replace(text, "packages = import ./packages.nix { inherit pkgs; };",
                   "packages = import ../default.nix { inherit pkgs; };")
    text = text.replace("packages.fprintd", "packages.gxfp5130-fprintd").replace("packages.tools", "packages.gxfp5130-tools")
    text = replace(text, "./kernel.nix", "../pkgs/gxfp5130-kernel")
    write("nixos-modules/gxfp5130-chicago.nix", text)
    for package in ["gxfp5130-fprintd", "gxfp5130-libfprint", "gxfp5130-tools", "gxfp5130-kernel"]:
        group(package, "gxfp5130Chicago")


def sync_computer(info):
    project = Path(info["project"]["path"])
    desktop = Path(info["desktop"]["path"])
    backend = Path(info["backend"]["path"])
    metadata = {"project": pin(info["project"], *PROJECTS["computer-use"]),
                "desktop": pin(info["desktop"], "ilysenko", "codex-desktop-linux"),
                "backend": pin(info["backend"], "ilysenko", "codex-desktop-linux"),
                "niri": pin(info["niri"], "niri-wm", "niri")}
    backend_recipe = (project / "packages/codex-desktop.nix").read_text()
    metadata["backendVersion"] = re.search(r'version = "([^"]+)";', backend_recipe)[1]
    compatibility = backend_recipe.split("compatibilityPatches = [", 1)[1].split("]", 1)[0]
    metadata["backendPatches"] = re.findall(r"\.\./patches/([^\s]+\.patch)", compatibility)
    write_json("pkgs/codex-desktop/sources.json", metadata)
    copy(desktop / "LICENSE", "pkgs/codex-desktop/LICENSE.upstream")
    copy(desktop / "nix/upstream-linux-packages.json", "pkgs/codex-desktop/upstream-linux-packages.json")
    for original, target in [("Cargo.lock", "Cargo.lock"),
                             ("global-dictation-linux/Cargo.lock", "global-dictation-Cargo.lock"),
                             ("linux-features/mcp-helper-reaper/reaper/Cargo.lock", "mcp-reaper-Cargo.lock"),
                             ("nix/watchbound-Cargo.lock", "watchbound-Cargo.lock"),
                             ("linux-features/directory-only-working-tree-watch/watchbound-artifacts.json", "watchbound-artifacts.json")]:
        copy(desktop / original, f"pkgs/codex-desktop/{target}")
    features = {"compatibility": json.loads((desktop / "linux-features/compatibility.json").read_text()),
                "manifests": [json.loads(path.read_text()) for path in sorted((desktop / "linux-features").glob("*/feature.json"))]}
    write_json("pkgs/codex-desktop/feature-manifests.json", features)
    text = (desktop / "nix/linux-features.nix").read_text()
    text = block(text, "  featuresRoot =", "  manifestIds =", '''  data = lib.importJSON ./feature-manifests.json;
  inherit (data) compatibility manifests;
''')
    write("pkgs/codex-desktop/features.nix", text)
    # Extract only the upstream package definitions, leaving Flake outputs,
    # installers and VM tests in the upstream repository.
    original = (desktop / "flake.nix").read_text()
    text = original[original.index("        pkgs = import nixpkgs {"):original.index("        codexDesktop = lib.makeOverridable")]
    text = textwrap.dedent(text)
    text = block(text, "pkgs = import nixpkgs {", "lib = pkgs.lib;", "")
    text = text.replace("./nix/linux-features.nix", "./features.nix").replace("./nix/upstream-linux-packages.json", "./upstream-linux-packages.json")
    text = replace(text, 'self.rev or (self.dirtyRev or "")', "pins.desktop.rev")
    text = replace(text, "self.lastModified or 1", "pins.desktop.lastModified")
    text = block(text, "sourceRoot = lib.cleanSourceWith {", "runtimeLibraries =", "sourceRoot = pkgs.fetchFromGitHub { inherit (pins.desktop) owner repo rev hash; };\n")
    text = block(text, 'genericRuntimeProbe =', 'gsettingsSchemaPackages =', "")
    text = block(text, "helperWorkspaceSource = lib.cleanSourceWith {", "staticCratesFetchurl =", '''helperWorkspaceSource = pkgs.runCommand "codex-helper-workspace" {} ''
  mkdir -p "$out"
  cp -r ${sourceRoot}/{Cargo.toml,Cargo.lock,computer-use-linux,read-aloud-linux,record-replay-linux,updater} "$out/"
'';
''')
    text = text.replace("src = ./global-dictation-linux;", 'src = "${sourceRoot}/global-dictation-linux";')
    text = text.replace("src = ./linux-features/mcp-helper-reaper/reaper;", 'src = "${sourceRoot}/linux-features/mcp-helper-reaper/reaper";')
    text = text.replace("./global-dictation-linux/Cargo.lock", "./global-dictation-Cargo.lock")
    text = text.replace("./linux-features/mcp-helper-reaper/reaper/Cargo.lock", "./mcp-reaper-Cargo.lock")
    text = text.replace("./linux-features/directory-only-working-tree-watch/watchbound-artifacts.json", "./watchbound-artifacts.json")
    text = text.replace("./nix/watchbound-Cargo.lock", "./watchbound-Cargo.lock")
    write("pkgs/codex-desktop/base.nix", "# Adapted from ilysenko/codex-desktop-linux; see LICENSE.upstream.\n# Regenerate with scripts/sync-project-inputs.py computer-use.\n{ pkgs }:\nlet\n  pins = pkgs.lib.importJSON ./sources.json;\n  system = pkgs.stdenv.hostPlatform.system;\n" + text + "in\nlib.makeOverridable mkCodexDesktop {}\n")
    copy(backend / "Cargo.lock", "pkgs/codex-computer-use-niri/Cargo.lock")
    for patch in (project / "patches").glob("codex-*.patch"):
        if patch.name == "codex-linux-native-launch.patch":
            copy(patch, f"pkgs/codex-desktop/{patch.name}")
        else:
            copy(patch, f"pkgs/codex-computer-use-niri/patches/{patch.name}")
    for patch in ["smithay-input-method-keymap.patch", "niri-ipc-tiled-window-position.patch", "niri-agent-input.patch"]:
        copy(project / f"patches/{patch}", f"pkgs/niri-patched/patches/{patch}")
    text = (project / "packages/niri.nix").read_text()
    text = replace(text, "{ pkgs, niriSource, agentInput ? true }:", '''{ pkgs, agentInput ? true }:
let
  pins = pkgs.lib.importJSON ../codex-desktop/sources.json;
  niriSource = pkgs.fetchFromGitHub { inherit (pins.niri) owner repo rev hash; } // { inherit (pins.niri) rev; };
in''')
    text = text.replace("../patches/", "./patches/")
    write("pkgs/niri-patched/default.nix", text)
    text = (project / "modules/nixos.nix").read_text()
    text = replace(text, "{ self, codex-desktop-linux, niriSource }:\n", "")
    text = replace(text, "codex-desktop-linux.nixosModules.default", "./desktop.nix")
    text = replace(text, "self.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop", "(import ../../default.nix { inherit pkgs; }).codex-desktop")
    text = replace(text, '"computer-use.packages.\\${system}.codex-desktop"', '"nur.repos.lihaoze123.codex-desktop"')
    text = block(text, "import ../packages/niri.nix {", "      };", "pkgs.callPackage ../../pkgs/niri-patched {\n        inherit (cfg) agentInput;\n")
    write("nixos-modules/computer-use/default.nix", text)
    for original, target in [("nixos-module.nix", "desktop.nix"), ("package-selection.nix", "package-selection.nix"),
                             ("bundled-codex-cli.nix", "bundled-codex-cli.nix")]:
        text = (desktop / f"nix/{original}").read_text()
        text = text.replace("./linux-features.nix", "../../pkgs/codex-desktop/features.nix")
        if original == "nixos-module.nix":
            text = replace(text, "{ self }:\n", "")
            text = replace(text, "flakePackages = self.packages.${system};", "flakePackages.codex-desktop = import ../../pkgs/codex-desktop/base.nix { inherit pkgs; };" )
        write(f"nixos-modules/computer-use/{target}", text)
    for package in ["codex-desktop", "codex-computer-use", "codex-computer-use-niri", "niri-patched"]:
        group(package, "computer-use")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", nargs="?")
    parser.add_argument("--if-supported", action="store_true")
    args = parser.parse_args()
    if args.input and args.input not in PROJECTS:
        if args.if_supported:
            return
        parser.error(f"Unknown project: {args.input}")
    handlers = {"dms-xhup": sync_dms, "edunet": sync_edunet,
                "gxfp5130Chicago": sync_fingerprint, "computer-use": sync_computer}
    for target in [args.input] if args.input else PROJECTS:
        handlers[target](source_info(target))


if __name__ == "__main__":
    main()
