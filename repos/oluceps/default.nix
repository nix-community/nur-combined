{
  pkgs ? import <nixpkgs> { },
}:
let
  genEmptyWithWarn =
    n:
    pkgs.callPackage (
      { stdenvNoCC, lib }:
      lib.warn "Package ${n} from NUR oluceps/nixos-config does NOT support nix without flake\nplease use it from github:oluceps/nixos-config#packages" (
        stdenvNoCC.mkDerivation {
          pname = n;
          version = "0.0.301-redirect";
          installPhase = "mkdir -p $out";
        }
      )
    ) { };
in
pkgs.lib.genAttrs (map (pkgs.lib.removeSuffix ".nix") (
  builtins.attrNames (builtins.readDir ./pkgs/by-name)
)) genEmptyWithWarn
