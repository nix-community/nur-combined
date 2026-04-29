# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{ pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import "${fetchTree gomod2nix.locked}/overlay.nix")
      ];
    }
  )
}:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit sources; });
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  agent-run = callPackage ./pkgs/agent-run.nix {};
  create-tauri-app = callPackage ./pkgs/create-tauri-app {};
  claude-code-bin = callPackage ./pkgs/claude-code {};
  codex = (callPackage ./pkgs/codex {}).codex;
  codex-bin = (callPackage ./pkgs/codex {}).codex-bin;
  dingtalk = callPackage ./pkgs/dingtalk {};
  kwok = callPackage ./pkgs/kwok/default.nix {};
  vagrant-vmware-utility = callPackage ./pkgs/vagrant-vmware-utility.nix {};
}
