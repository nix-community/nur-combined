{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.rofi;
in
{
  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      terminal = config.my.home.terminal.program; # null by default

      package = pkgs.rofi.override {
        plugins = with pkgs; [
          rofi-emoji
        ];
      };

      theme = "gruvbox-dark-hard";
    };
  };
}
