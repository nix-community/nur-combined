{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.gaming;
in
{
  options = {
    profiles.gaming = {
      enable = mkEnableOption "Enable gaming profile";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      steam
      discord
    ];
  };
}
