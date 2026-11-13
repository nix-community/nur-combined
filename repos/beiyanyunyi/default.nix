{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  nixosModules = import ./nixos-modules;
  overlays = import ./overlays;

  rime-ice = pkgs.callPackage ./pkgs/rime-ice { };
  qingjian = pkgs.callPackage ./pkgs/qingjian { };
  patchelf-unstable = pkgs.callPackage ./pkgs/patchelf-unstable { };
  portop = pkgs.callPackage ./pkgs/portop { };
  mihomo-oix = pkgs.callPackage ./pkgs/mihomo-oix { };
  codex-bin = pkgs.callPackage ./pkgs/codex-bin { };
}
