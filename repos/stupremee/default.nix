{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  mon2cam = pkgs.callPackage ./pkgs/mon2cam { inherit deno; };
  deno = pkgs.callPackage ./pkgs/deno { };
  ghidra = pkgs.callPackage ./pkgs/ghidra { };
  vimPlugins = pkgs.recurseIntoAttrs
    (pkgs.callPackage ./pkgs/vimPlugins { inherit pkgs; });
  blastradius = pkgs.callPackage ./pkgs/blastradius { };
  rust-analyzer = pkgs.callPackage ./pkgs/rust-analyzer { };

  # Currently broken
  # veloren = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/veloren { });

  # Somehow the build currently hangs
  # ddlog = pkgs.callPackage ./pkgs/ddlog { };
}
