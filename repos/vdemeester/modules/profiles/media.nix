{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.media;
in
{
  options = {
    profiles.media = {
      enable = mkEnableOption "Enable media configuration";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [ youtube-dl ];
    }
    (
      mkIf config.profiles.desktop.enable {
        home.packages = with pkgs; [ spotify ];
      }
    )
  ]);
}
