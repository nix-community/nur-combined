{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
} :

let
  # Only expose top level derivations
  filterDerivations = pkgSet: with pkgs.lib; filterAttrs (name: value: isDerivation value) pkgSet;

  pkgsUnstable = lib.fix' (lib.extends (import ./default.nix) (self: pkgs));

in {
  overlays = {
    NixOS-QChem = import ./default.nix;
  };
} // filterDerivations pkgsUnstable.qchem


