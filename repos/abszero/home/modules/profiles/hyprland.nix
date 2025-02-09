{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.hyprland;
in

{
  imports = [ ./full.nix ];

  options.abszero.profiles.hyprland.enable = mkExternalEnableOption config "hyprland profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.full.enable = true;
      wayland.windowManager.hyprland.enable = true;
      services.hypridle.enable = true;
      programs.hyprlock.enable = true;
    };

    home.packages = with pkgs; [
      albert
      grimblast
      brillo
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        ",      XF86MonBrightnessDown, exec, brillo -qu 200000 -U 5"
        ",      XF86MonBrightnessUp,   exec, brillo -qu 200000 -A 5"

        "$mod,  Slash,                 exec, albert show"
        "$mod,  t,                     exec, ghostty"
        ",      Print,                 exec, grimblast copysave area"
        "SHIFT, Print,                 exec, grimblast copysave output"
      ];

      exec-once = [ "albert" ];
    };

    services.hyprpaper.enable = true;
  };
}
