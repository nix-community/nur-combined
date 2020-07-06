{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.core.nur;
in
{
  options = {
    core.nur = {
      enable = mkOption { type = types.bool; default = true; description = "Enable core.nur"; };
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.config = {
      packageOverrides = pkgs: {
        nur = (import ../../../nix).nur { inherit pkgs; };
      };
    };
  };
}
