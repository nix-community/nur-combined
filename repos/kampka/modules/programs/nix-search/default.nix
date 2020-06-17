{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.kampka.programs.nix-search;

  nix-search = pkgs.callPackage ./../../../pkgs/nix-search { };

in
{

  options.kampka.programs.nix-search = {
    enable = mkEnableOption "nix-search - accelerated nix-env search";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ nix-search ];
    environment.shellAliases = {
      ns = "nix-search";
    };
  };
}
