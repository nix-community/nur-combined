{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.finances;
in
{
  options = {
    profiles.finances = {
      enable = mkEnableOption "Enable fincances profile";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ledger ];
  };
}
