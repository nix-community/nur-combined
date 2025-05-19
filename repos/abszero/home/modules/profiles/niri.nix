{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.niri;
in

{
  imports = [ ./full.nix ];

  options.abszero.profiles.niri.enable = mkExternalEnableOption config "niri profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.full.enable = true;
      programs = {
        foot.enable = true;
        niri.enable = true;
      };
    };

    home.packages = with pkgs; [
      albert
      brillo
      smile
    ];

    services.hyprpaper.enable = true;

    programs.niri.settings = {
      binds = with config.lib.niri.actions; {
        XF86MonBrightnessDown.action = spawn "sudo" "brillo" "-qu" "200000" "-U" "5";
        XF86MonBrightnessUp.action = spawn "sudo" "brillo" "-qu" "200000" "-A" "5";

        "Mod+Ctrl+t".action = spawn "foot";
        "Mod+Ctrl+slash".action = spawn "albert" "show";
        "Mod+Ctrl+b".action = spawn "zen";
        "Mod+Ctrl+period".action = spawn "smile";
      };

      window-rules = [
        {
          open-floating = true;
          matches = [
            { app-id = "it\\.mijorus\\.smile"; }
          ];
        }
      ];

      spawn-at-startup = [
        { command = [ "albert" ]; }
      ];
    };
  };
}
