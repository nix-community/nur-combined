{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.driftwm;
in

{
  options.abszero.programs.driftwm.enable = mkEnableOption "infinite canvas wayland compositor";
  options.wayland.windowManager.driftwm.systemd.variables =
    with lib;
    mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

  config = mkIf cfg.enable {
    xdg.portal.config.driftwm = {
      default = "gtk";
      "org.freedesktop.impl.portal.FileChooser" = "gnome";
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };

    wayland.windowManager.driftwm = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];

      settings = {
        session = {
          restore_windows = false;
          restore_camera = false;
          restore_bookmarks = false;
        };

        input = {
          keyboard.repeat_rate = 50;
          # trackpad.drag_lock = true; # TODO: enable when supported
        };

        navigation.edge_pan = {
          speed_min = 1;
          speed_max = 4;
        };

        zoom.reset_on_activation = false;

        bindings.disable_defaults = [
          "keys"
          "mouse"
          "gestures"
        ];

        keybindings = {
          "mod+q" = "quit";
          "mod+r" = "reload-config";

          # Navigation

          "mod+space" = "center-window";
          "mod+up" = "focus-nearest up";
          "mod+down" = "focus-nearest down";
          "mod+left" = "focus-nearest left";
          "mod+right" = "focus-nearest right";

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

          "mod+w" = "close-window";
          "mod+f" = "toggle-fullscreen";
          "mod+m" = "fit-window"; # m for maximize
          "mod+x" = "fill-window"; # x for expand

          "mod+shift+up" = "move-to-snap up";
          "mod+shift+down" = "move-to-snap down";
          "mod+shift+left" = "move-to-snap left";
          "mod+shift+right" = "move-to-snap right";

          # Snap group manipulation

          "mod+ctrl+m" = "fit-window-snapped";

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
            "mod+ctrl+left" = "move-snapped-windows";
            "mod+ctrl+right" = "resize-window-snapped";
          };
          on-canvas = {
            "middle" = "pan-viewport";
            "wheel-scroll" = "zoom";
            "shift+middle" = "focus-nearest";
          };
          anywhere = {
            "mod+middle" = "pan-viewport";
            "mod+wheel-scroll" = "zoom";
            "mod+shift+middle" = "focus-nearest";
          };
        };

        gestures.anywhere = {
          "3-finger-swipe" = "pan-viewport";
          "4-finger-swipe" = "focus-nearest";
        };

        window_rules = [
          # Fullscreen

          {
            title = "Waydroid";
            fullscreen = true;
          }

          # Resize

          {
            title = "/^.* - Anki$/";
            size = [
              679
              711
            ];
          }
          {
            title = "Buzz";
            size = [
              370
              370
            ];
          }
          {
            title = "/^.*Discord.*$/";
            size = [
              941
              960
            ];
          }
          {
            app_id = "com.mitchellh.ghostty";
            size = [
              812
              494
            ];
          }
          {
            title = "KDE Connect";
            size = [
              342
              567
            ];
          }
          {
            title = "Lutris";
            size = [
              842
              894
            ];
          }

          # Pin

          {
            title = "AIRI";
            pinned_to_screen = true;
            position = [
              1000
              (-820)
            ];
            decoration = "none";
          }
          {
            app_id = "ai-moeru-airi";
            title = "Inlay";
            pinned_to_screen = true;
            position = [
              0
              (-800)
            ];
            decoration = "none";
          }
          {
            app_id = "org.kde.polkit-kde-authentication-agent-1";
            pinned_to_screen = true;
          }
          {
            title = "satty";
            pinned_to_screen = true;
          }
          {
            app_id = "it.mijorus.smile";
            pinned_to_screen = true;
          }
          {
            app_id = "steam";
            title = "/^notificationtoasts_\\d+_desktop$/";
            pinned_to_screen = true;
            position = [
              1000
              (-800)
            ];
          }
          {
            app_id = "Vial";
            title = "Enter an arbitrary keycode";
            pinned_to_screen = true;
          }
        ];
      };
    };
  };
}
