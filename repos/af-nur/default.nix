# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { }, bun2nix ? null, ... }:

let
  rikkahubDesktop =
    if bun2nix != null then
      pkgs.callPackage ./pkgs/rikkahub-desktop { inherit bun2nix; }
    else
      pkgs.stdenvNoCC.mkDerivation {
        pname = "rikkahub-desktop";
        version = "git";
        dontUnpack = true;

        buildPhase = ''
          cat >&2 <<'EOF'
          rikkahub-desktop requires the flake-provided bun2nix input.
          Build it with `nix build .#rikkahub-desktop`.
          EOF
          exit 1
        '';

        installPhase = ''
          mkdir -p $out
        '';

        meta = {
          description = "RikkaHub desktop package; requires flake-provided bun2nix to build";
          mainProgram = "rikkahub-pc";
          platforms = pkgs.lib.platforms.linux;
        };
      };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  homeModules = import ./hm-modules; # Home Manager modules
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  classin = pkgs.callPackage ./pkgs/classin { };
  hhsh = pkgs.callPackage ./pkgs/hhsh { };
  linuxqq-clipsync = pkgs.callPackage ./pkgs/linuxqq-clipsync { };
  mefrpc = pkgs.callPackage ./pkgs/mefrpc { };
  xwaylandvideobridge = pkgs.kdePackages.callPackage ./pkgs/xwaylandvideobridge { };
  rikkahub-desktop = rikkahubDesktop;
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
