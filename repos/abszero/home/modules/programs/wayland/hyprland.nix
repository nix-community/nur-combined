# NOTE: The hyprland option in home-manager is `wayland.windowManager.hyprland`, however we use
#       `programs.hyprland` to be consistent with NixOS.
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (builtins) concatMap;
  cfg = config.abszero.programs.hyprland;
in

{
  # imports = [ ./mosaic-tiling.nix ];

  options.abszero.programs.hyprland.enable = mkEnableOption "Wayland compositor";

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
        touchpad = {
          natural_scroll = true;
          drag_lock = true; # Don't interrupt drag on short breaks
        };
      };

      cursor = {
        persistent_warps = true; # Remember cursor position for each window
        warp_on_change_workspace = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_distance = 200;
        workspace_swipe_direction_lock = false;
        workspace_swipe_forever = true;
      };

      render.direct_scanout = true;

      # Do not scale xwayland windows
      xwayland.force_zero_scaling = true;

      ecosystem = {
        no_update_news = true;
        # no_donation_nag = true;
      };

      misc = {
        vrr = 1;
        # Allow screen locker to restart after crash
        allow_session_lock_restore = true;
        focus_on_activate = true; # Focus windows that request to be focused
        middle_click_paste = false;
      };

      experimental.xx_color_management_v4 = true;

      bind = [
        # https://wiki.hyprland.org/Configuring/Dispatchers
        "$mod,       q,                    exec,           uwsm stop"
        "$mod,       w,                    killactive"
        "$mod,       Page_Up,              fullscreen,     0"
        "$mod,       Page_Down,            fullscreen,     1"
        "$mod,       Space,                togglefloating"

        "$mod,       Left,                 movefocus,      l"
        "$mod,       Right,                movefocus,      r"
        "$mod,       Up,                   movefocus,      u"
        "$mod,       Down,                 movefocus,      d"
        "$mod+SHIFT, Left,                 movewindow,     l"
        "$mod+SHIFT, Right,                movewindow,     r"
        "$mod+SHIFT, Up,                   movewindow,     u"
        "$mod+SHIFT, Down,                 movewindow,     d"

        ",           XF86AudioMute,        exec,           wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",           XF86AudioLowerVolume, exec,           wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",           XF86AudioRaiseVolume, exec,           wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",           XF86AudioMicMute,     exec,           wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ]
      ++
        concatMap
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

      bindm = "$mod, mouse:272, movewindow";

      exec-once = [
        # "fcitx5 -d"
        # Polkit authentication agent
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &"
      ];
    };
  };
}
