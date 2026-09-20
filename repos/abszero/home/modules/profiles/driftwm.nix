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
          background.type = "none";

          keybindings = {
            XF86MonBrightnessDown = "exec sudo brillo -qu 200000 -U 5";
            XF86MonBrightnessUp = "exec sudo brillo -qu 200000 -A 5";
            Print = "exec noctalia msg screenshot-fullscreen";
            "shift+Print" = "exec noctalia msg screenshot-region";

            "mod+ctrl+t" = "exec ghostty";
            "mod+ctrl+slash" = "exec noctalia msg panel-toggle launcher";
            "mod+ctrl+b" = "exec zen-beta";
            "mod+ctrl+period" = "exec smile";
          };
        };
      };
    };

    home.packages = with pkgs; [
      kdePackages.breeze
      brillo
      ddcutil # For controlling brightness with noctalia
      satty
      smile
    ];

    programs = {
      ghostty = {
        enable = true;
        settings.window-decoration = "none";
      };
      noctalia = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
