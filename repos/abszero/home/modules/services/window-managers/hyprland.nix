{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  inherit (builtins) concatLists genList;
  cfg = config.abszero.wayland.windowManager.hyprland;
in

{
  options.abszero.wayland.windowManager.hyprland.enable = mkEnableOption "Wayland compositor";

  config = mkIf cfg.enable {
    abszero = {
      services.hypridle.enable = mkDefault true;
      programs.hyprlock.enable = mkDefault true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";

        general = {
          allow_tearing = true;
          resize_on_border = true;
        };

        input = {
          follow_mouse = 2; # Detach cursor focus from keyboard focus
          touchpad = {
            natural_scroll = true;
            drag_lock = true; # Don't interrupt drag on short breaks
          };
        };

        gestures.workspace_swipe = true;

        misc = {
          vrr = 1;
        };

        bind =
          [
            "$mod,       w,       killactive"
            "$mod,       Left,    movefocus,  l"
            "$mod,       Right,   movefocus,  r"
            "$mod,       Up,      movefocus,  u"
            "$mod,       Down,    movefocus,  d"
            "$mod,       Page_Up, fullscreen, 1"
            "$mod+SHIFT, Page_Up, fullscreen, 0"
            "$mod,       Space,   exec,       albert"
          ]
          ++ concatLists (
            genList (
              i:
              let
                ws = toString (i + 1);
              in
              [
                "$mod,       ${ws}, workspace,       ${ws}"
                "$mod+SHIFT, ${ws}, movetoworkspace, ${ws}"
              ]
            ) 5
          );

        xwayland.use_nearest_neighbor = false;

        windowrulev2 = [
          "immediate, class:osu!" # Enable tearing for osu!
        ];
      };
    };

    # services.hyprpaper.enable = mkDefault true;
  };
}
