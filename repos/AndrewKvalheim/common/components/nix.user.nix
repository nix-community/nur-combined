{ lib, pkgs, ... }:

let
  nur = import ../../nur.nix { inherit pkgs; };
in
{
  imports = [ nur.hmModules.nixpkgs-issue-55674 ];

  config = {
    # Diff after rebuild
    home.activation.diff = lib.hm.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath"
    '';

    # Custom packages
    nixpkgs.overlays = [ (import ../packages.nix) ];
  };
}
