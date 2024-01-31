{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.mpv;
in
{
  options.my.home.mpv = with lib; {
    enable = mkEnableOption "mpv configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      scripts = [
        pkgs.mpvScripts.mpris # Allow controlling using media keys
        pkgs.mpvScripts.mpv-cheatsheet # Show some simple mappings on '?'
        pkgs.mpvScripts.uosc # Nicer UI
      ];
    };
  };
}
