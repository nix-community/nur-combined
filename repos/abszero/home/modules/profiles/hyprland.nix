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
      services.hypridle.enable = true;
      programs = {
        foot.enable = true;
        hyprland.enable = true;
        hyprlock.enable = true;
      };
    };

    home.packages = with pkgs; [
      albert
      grimblast
      brillo
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        ",      XF86MonBrightnessDown, exec, sudo brillo -qu 200000 -U 5"
        ",      XF86MonBrightnessUp,   exec, sudo brillo -qu 200000 -A 5"

        "$mod,  Slash,                 exec, albert show"
        "$mod,  t,                     exec, foot"
        ",      Print,                 exec, grimblast copysave area"
        "SHIFT, Print,                 exec, grimblast copysave output"
      ];

      windowrule = [
        "float,        title:Albert"
        "pin,          title:Albert"
        "noblur,       title:Albert"
        "noborder,     title:Albert"

        "pseudo,       title:.* - Anki"
        "size 666 560, title:.* - Anki"

        "float,        title:CollectorMainWindow"

        "size 600 500, class:foot"

        "size 600 500, class:com\\.mitchellh\\.ghostty"

        "pseudo,       title:KDE Connect"
        "size 350 350, title:KDE Connect"

        "immediate,    class:osu!" # Enable tearing

        "float,        class:it\\.mijorus\\.smile"

        "pseudo,       class:org\\.gnome\\.Solanum"
        "size 370 370, class:org\\.gnome\\.Solanum"

        "maximize,     title:Waydroid" # Full ui

        "float,        class:zen, title:^$" # Notification popups

        "float,        class:Zotero, title: Error"
      ];

      exec-once = [ "albert" ];
    };

    services.hyprpaper.enable = true;
  };
}
