{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  inherit (builtins) concatMap;
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
          repeat_rate = 50;
          repeat_delay = 200;
          follow_mouse = 2; # Detach cursor focus from keyboard focus
          mouse_refocus = false; # Don't move cursor to focused window
          touchpad = {
            natural_scroll = true;
            drag_lock = true; # Don't interrupt drag on short breaks
          };
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_distance = 200;
          workspace_swipe_direction_lock = false;
          workspace_swipe_forever = true;
        };

        misc = {
          vrr = 1;
          middle_click_paste = false;
        };

        bind =
          [
            "$mod,       q,         exit"
            "$mod,       w,         killactive"
            "$mod,       Page_Up,   fullscreen,     0"
            "$mod,       Page_Down, fullscreen,     1"
            "$mod,       Space,     togglefloating"

            "$mod,       Left,      movefocus,      l"
            "$mod,       Right,     movefocus,      r"
            "$mod,       Up,        movefocus,      u"
            "$mod,       Down,      movefocus,      d"
            "$mod+SHIFT, Left,      movewindow,     l"
            "$mod+SHIFT, Right,     movewindow,     r"
            "$mod+SHIFT, Up,        movewindow,     u"
            "$mod+SHIFT, Down,      movewindow,     d"

            "$mod,       Slash,     exec,           albert show"
            "$mod,       t,         exec,           foot"
          ]
          ++ concatMap
            (i: [
              "$mod,       ${i}, workspace,       ${i}"
              "$mod+SHIFT, ${i}, movetoworkspace, ${i}"
            ])
            [
              "1"
              "2"
              "3"
              "4"
              "5"
            ];

        xwayland.use_nearest_neighbor = false;

        windowrulev2 = [
          "float, title:^Albert$"
          "pin, title:^Albert$"
          "size 600 600, title:^Albert$"
          "center, title:^Albert$"
          "noblur, title:^Albert$"
          "noborder, title:^Albert$"
          # "immediate, class:osu!" # Enable tearing for osu!
        ];
      };
    };

    # services.hyprpaper.enable = mkDefault true;
  };
}
