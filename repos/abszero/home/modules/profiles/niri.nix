{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.profiles.niri;
in

{
  imports = [ ./full.nix ];

  options.abszero.profiles.niri.enable = mkEnableOption "niri profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.full.enable = true;
      programs.niri.enable = true;
    };

    home.packages = with pkgs; [
      brillo
      smile
      vicinae
    ];

    wayland.windowManager.niri.settings = {
      binds = {
        XF86MonBrightnessDown.spawn = [
          "sudo"
          "brillo"
          "-qu"
          "200000"
          "-U"
          "5"
        ];
        XF86MonBrightnessUp.spawn = [
          "sudo"
          "brillo"
          "-qu"
          "200000"
          "-A"
          "5"
        ];

        "Mod+Ctrl+t".spawn = "ghostty";
        "Mod+Ctrl+slash".spawn = [
          "vicinae"
          "open"
        ];
        "Mod+Ctrl+b".spawn = "zen-beta";
        "Mod+Ctrl+period".spawn = "smile";
      };

      spawn-at-startup = [
        "vicinae"
        "server"
      ];
    };

    programs.ghostty.enable = true;
  };
}
