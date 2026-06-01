{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
in
{
  # Diff after rebuild
  home.activation.diff = lib.hm.dag.entryAnywhere ''
    ${getExe pkgs.nvd} diff "$oldGenPath" "$newGenPath"
  '';

  # Custom packages
  nixpkgs.overlays = [ (import ../packages.nix) ];
}
