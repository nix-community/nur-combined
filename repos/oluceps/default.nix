{
  pkgs ? import <nixpkgs> { },
}:
let
  emptyWithWarn =
    n:
    pkgs.callPackage (
      { stdenvNoCC, lib }:
      lib.warn "Package ${n} from NUR oluceps/nixos-config does NOT support nix without flake" (
        stdenvNoCC.mkDerivation {
          pname = n;
          version = "0.0.0";
          installPhase = "mkdir -p $out";
        }
      )
    ) { };
in

pkgs.lib.genAttrs (map (pkgs.lib.removeSuffix ".nix") (
  builtins.attrNames (builtins.readDir ./pkgs/by-name)
)) emptyWithWarn
