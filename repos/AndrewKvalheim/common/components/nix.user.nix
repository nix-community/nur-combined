{ lib, pkgs, ... }:

let
  inherit (lib) getExe;

  nur = import ../../nur.nix { inherit pkgs; };
in
{
  imports = [ nur.hmModules.nixpkgs-issue-55674 ];

  config = {
    # Diff after rebuild
    home.activation.diff = lib.hm.dag.entryAnywhere ''
      ${getExe pkgs.nvd} diff "$oldGenPath" "$newGenPath"
    '';

    # Custom packages
    nixpkgs.overlays = [ (import ../packages.nix) ];
  };
}
