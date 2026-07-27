{ kitty-ntfy-cmd }:
{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.programs.myterminal;
  kitty_latest = (import <nixpkgs-unstable>{}).kitty;
in 
{
  options.programs.myterminal = {
    enable = mkEnableOption "My terminal emulator config";
  };
  config = mkIf cfg.enable (mkMerge ([
    ({
      
      programs.kitty = {
        enable = true;
        package = kitty_latest;
        settings = {
          scrollback_lines = 10000;
          enable_audio_bell = false;
          update_check_interval = 0;
          # watcher = "${kitty-ntfy-cmd}/share/KittyNtfyCmd/kitty_ntfy_cmd_watcher.py";
        };
        keybindings = {
          "alt+n" = "new_tab_with_cwd";
          "alt+h" = "previous_tab";
          "alt+j" = "move_tab_backward";
          "alt+k" = "move_tab_forward";
          "alt+l" = "next_tab";
          "f11" = "toggle_fullscreen";
          "ctrl+shift+p" = "change_font_size all +2.0";
          "ctrl+shift+n" = "change_font_size all -2.0";
        };
        shellIntegration.enableZshIntegration = true;
      };
    }
    )
  ]));
}
