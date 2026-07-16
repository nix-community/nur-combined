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

    programs = {
      ghostty.enable = true;
      niri.settings = {
        binds = with config.lib.niri.actions; {
          XF86MonBrightnessDown.action = spawn "sudo" "brillo" "-qu" "200000" "-U" "5";
          XF86MonBrightnessUp.action = spawn "sudo" "brillo" "-qu" "200000" "-A" "5";

          "Mod+Ctrl+t".action = spawn "ghostty";
          "Mod+Ctrl+slash".action = spawn "vicinae" "open";
          "Mod+Ctrl+b".action = spawn "zen-beta";
          "Mod+Ctrl+period".action = spawn "smile";
        };

        spawn-at-startup = [
          {
            command = [
              "vicinae"
              "server"
            ];
          }
        ];
      };
    };
  };
}
