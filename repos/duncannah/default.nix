{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  nixosModules = import ./nixos-modules;
  overlays = import ./overlays;

  gomerge = pkgs.callPackage ./pkgs/gomerge { };
  paintdotnet = pkgs.callPackage ./pkgs/paintdotnet { };
}
// pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  proton-wineland = pkgs.callPackage ./pkgs/proton-wineland/package.nix { };
}
