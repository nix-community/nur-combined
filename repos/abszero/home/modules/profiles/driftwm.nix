{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.profiles.driftwm;
in

{
  imports = [ ./full.nix ];

  options.abszero.profiles.driftwm.enable = mkEnableOption "driftwm profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.full.enable = true;
      programs.driftwm = {
        enable = true;
        settings = {
          autostart = [ "vicinae server" ];

          keybindings = {
            XF86MonBrightnessDown = "exec brillo -qu 200000 -U 5";
            XF86MonBrightnessUp = "exec brillo -qu 200000 -A 5";
            Print = "exec driftwm msg screenshot --output - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";
            "shift+Print" =
              "exec driftwm msg screenshot all --output - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

            "mod+ctrl+t" = "exec ghostty";
            "mod+ctrl+slash" = "exec vicinae open";
            "mod+ctrl+b" = "exec zen-beta";
            "mod+ctrl+period" = "exec smile";
          };
        };
      };
    };

    home.packages = with pkgs; [
      brillo
      satty
      smile
      vicinae
    ];

    programs.ghostty.enable = true;
  };
}
