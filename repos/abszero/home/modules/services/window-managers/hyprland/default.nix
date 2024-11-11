{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (builtins) concatMap;
  cfg = config.abszero.wayland.windowManager.hyprland;
in

{
  imports = [ ./mosaic-tiling.nix ];

  options.abszero.wayland.windowManager.hyprland.enable = mkEnableOption "Wayland compositor";

  config.wayland.windowManager.hyprland = mkIf cfg.enable {
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

      # Do not scale xwayland windows
      xwayland.force_zero_scaling = true;

      misc = {
        vrr = 1;
        # Allow screen locker to restart after crash
        allow_session_lock_restore = true;
        middle_click_paste = false;
      };

      bind =
        [
          "$mod,       q,                     exit"
          "$mod,       w,                     killactive"
          "$mod,       Page_Up,               fullscreen,     0"
          "$mod,       Page_Down,             fullscreen,     1"
          "$mod,       Space,                 togglefloating"

          "$mod,       Left,                  movefocus,      l"
          "$mod,       Right,                 movefocus,      r"
          "$mod,       Up,                    movefocus,      u"
          "$mod,       Down,                  movefocus,      d"
          "$mod+SHIFT, Left,                  movewindow,     l"
          "$mod+SHIFT, Right,                 movewindow,     r"
          "$mod+SHIFT, Up,                    movewindow,     u"
          "$mod+SHIFT, Down,                  movewindow,     d"

          ",           XF86AudioMute,         exec,           wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",           XF86AudioLowerVolume,  exec,           wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",           XF86AudioRaiseVolume,  exec,           wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",           XF86AudioMicMute,      exec,           wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",           XF86MonBrightnessDown, exec,           brillo -qu 200000 -U 5"
          ",           XF86MonBrightnessUp,   exec,           brillo -qu 200000 -A 5"

          "$mod,       Slash,                 exec,           albert show"
          "$mod,       t,                     exec,           foot"
          ",           Print,                 exec,           grimblast copysave area"
          "SHIFT,      Print,                 exec,           grimblast copysave output"
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

      windowrulev2 = [
        "float, title:^Albert$"
        "pin, title:^Albert$"
        "noblur, title:^Albert$"
        "noborder, title:^Albert$"
        "pseudo, title:.* - Anki"
        "size 666 560, title:.* - Anki"
        "pseudo, title:^KDE Connect$"
        "size 350 350, title:^KDE Connect$"
        "immediate, class:osu!" # Enable tearing for osu!
        "pseudo, class:org\.gnome\.Solanum"
        "size 370 370, class:org\.gnome\.Solanum"
      ];

      exec-once = [
        "albert"
        "fcitx5 -d"
      ];
    };
  };
}
