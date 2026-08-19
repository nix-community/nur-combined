{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption mkIf;
  cfg = config.abszero.programs.driftwm;

  format = pkgs.formats.toml { };
in

{
  options.abszero.programs.driftwm = {
    enable = mkEnableOption "infinite canvas wayland compositor";
    settings = mkOption {
      type = format.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    abszero.programs.driftwm.settings = {
      window_placement = "auto";

      session = {
        suspend_on_close = true;
        restore_windows = true;
        restore_camera = true;
        restore_bookmarks = true;
      };

      input = {
        keyboard.repeat_rate = 50;
        # trackpad.drag_lock = true; # TODO: enable when supported
      };

      navigation.edge_pan = {
        speed_min = 1;
        speed_max = 4;
      };

      zoom = {
        reset_on_new_window = false;
        reset_on_activation = false;
      };

      snap.corners = true;

      bindings.disable_defaults = [
        "keys"
        "mouse"
      ];

      keybindings = {
        "mod+q" = "quit";
        "mod+r" = "reload-config";

        # Navigation
        "mod+space" = "center-window";
        "mod+up" = "center-nearest up";
        "mod+down" = "center-nearest down";
        "mod+left" = "center-nearest left";
        "mod+right" = "center-nearest right";

        "mod+tab" = "cycle-windows forward";
        "mod+shift+tab" = "cycle-windows backward";

        "mod+KP_1" = "go-to-bookmark 1";
        "mod+KP_2" = "go-to-bookmark 2";
        "mod+KP_3" = "go-to-bookmark 3";
        "mod+KP_4" = "go-to-bookmark 4";
        "mod+KP_5" = "go-to-bookmark 5";
        "mod+KP_6" = "go-to-bookmark 6";
        "mod+KP_7" = "go-to-bookmark 7";
        "mod+KP_8" = "go-to-bookmark 8";
        "mod+KP_9" = "go-to-bookmark 9";

        "mod+shift+KP_1" = "set-bookmark 1";
        "mod+shift+KP_2" = "set-bookmark 2";
        "mod+shift+KP_3" = "set-bookmark 3";
        "mod+shift+KP_4" = "set-bookmark 4";
        "mod+shift+KP_5" = "set-bookmark 5";
        "mod+shift+KP_6" = "set-bookmark 6";
        "mod+shift+KP_7" = "set-bookmark 7";
        "mod+shift+KP_8" = "set-bookmark 8";
        "mod+shift+KP_9" = "set-bookmark 9";

        # Window manipulation
        "mod+w" = "suspend-window";
        "mod+shift+w" = "close-window";
        "mod+f" = "toggle-fullscreen";
        "mod+m" = "fit-window"; # m for maximize
        "mod+x" = "fill-window"; # x for expand

        "mod+shift+up" = "nudge-window up";
        "mod+shift+down" = "nudge-window down";
        "mod+shift+left" = "nudge-window left";
        "mod+shift+right" = "nudge-window right";

        # Snap group manipulation
        "mod+shift+m" = "fit-window-snapped";

        # Media
        XF86AudioMute = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        XF86AudioLowerVolume = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        XF86AudioRaiseVolume = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        XF86AudioMicMute = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };

      mouse = {
        on-window = {
          "mod+left" = "move-window";
          "mod+right" = "resize-window";
          "mod+shift+left" = "move-snapped-windows";
          "mod+shift+right" = "resize-window-snapped";
        };
        on-canvas = {
          "middle" = "pan-viewport";
          "wheel-scroll" = "zoom";
          "shift+middle" = "center-nearest";
        };
        anywhere = {
          "mod+middle" = "pan-viewport";
          "mod+wheel-scroll" = "zoom";
          "mod+shift+middle" = "center-nearest";
        };
      };

      window_rules = [
        # Fullscreen
        {
          title = "Waydroid";
          fullscreen = true;
        }
        # Resize
        {
          title = "Buzz";
          size = [
            370
            370
          ];
        }
        {
          title = "KDE Connect";
          size = [
            370
            370
          ];
        }
        {
          app_id = "org.gnome.Solanum";
          size = [
            370
            370
          ];
        }
        # Pin
        {
          app_id = "org.kde.polkit-kde-authentication-agent-1";
          pinned_to_screen = true;
        }
        {
          title = "Satty";
          suspend_on_close = false;
          pinned_to_screen = true;
        }
        {
          app_id = "it.mijorus.smile";
          suspend_on_close = false;
          pinned_to_screen = true;
        }
        {
          app_id = "Vial";
          title = "Enter an arbitrary keycode";
          pinned_to_screen = true;
        }
        # Widget
        {
          title = "AIRI";
          widget = true;
          position = [
            1000
            (-800)
          ];
        }
        {
          app_id = "steam";
          title = "/^notificationtoasts_\\d+_desktop$/";
          position = [
            1000
            (-800)
          ];
        }
      ];
    };

    xdg.configFile."driftwm/config.toml".source = format.generate "driftwm-config.toml" cfg.settings;
  };
}
