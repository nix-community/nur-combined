{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.niri;
in

{
  options.abszero.programs.niri.enable = mkEnableOption "scrolling wayland compositor";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ xwayland-satellite ];

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;

      settings = {
        clipboard.disable-primary = true; # Disable the clipboard containing last mouse selection
        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

        input = {
          keyboard = {
            repeat-delay = 200;
            repeat-rate = 50;
          };
          touchpad = {
            dwt = true;
            drag-lock = true;
          };
        };

        layout = {
          empty-workspace-above-first = true;
          always-center-single-column = true;
        };

        environment.DISPLAY = ":0"; # For XWayland

        binds = with config.lib.niri.actions; {
          "Mod+q".action = quit;
          "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
          "Mod+o".action = toggle-overview;
          "Mod+k".action = show-hotkey-overlay;

          # Navigation
          "Mod+Space".action = switch-focus-between-floating-and-tiling;
          "Mod+Tab".action = focus-window-previous;
          "Mod+m".action = focus-monitor-previous;

          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-or-workspace-down;
          "Mod+Up".action = focus-window-or-workspace-up;
          "Mod+Right".action = focus-column-right;
          "Mod+Home".action = focus-column-first;
          "Mod+End".action = focus-column-last;

          # Window movement
          "Mod+w".action = close-window;
          "Mod+f".action = fullscreen-window;
          "Mod+l".action = switch-layout "next";
          "Mod+Shift+Space".action = toggle-window-floating;
          "Mod+Shift+m".action = move-window-to-monitor-previous;

          "Mod+Shift+Left".action = consume-or-expel-window-left;
          "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;
          "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
          "Mod+Shift+Right".action = consume-or-expel-window-right;

          # Column movement
          "Mod+t".action = toggle-column-tabbed-display;
          "Mod+Ctrl+f".action = maximize-column;
          "Mod+u".action = consume-window-into-column;
          "Mod+x".action = expel-window-from-column;
          "Mod+Ctrl+Shift+m".action = move-column-to-monitor-previous;

          "Mod+Ctrl+Shift+Left".action = move-column-left;
          "Mod+Ctrl+Shift+Down".action = move-column-to-workspace-down { focus = true; };
          "Mod+Ctrl+Shift+Up".action = move-column-to-workspace-up { focus = true; };
          "Mod+Ctrl+Shift+Right".action = move-column-right;
          "Mod+Ctrl+Shift+Home".action = move-column-to-first;
          "Mod+Ctrl+Shift+End".action = move-column-to-last;

          # Media
          XF86AudioMute = {
            action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
            allow-when-locked = true;
          };
          XF86AudioLowerVolume = {
            action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
            allow-when-locked = true;
          };
          XF86AudioRaiseVolume = {
            action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+";
            allow-when-locked = true;
          };
          XF86AudioMicMute = {
            action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
            allow-when-locked = true;
          };
          Print.action = screenshot;
          "Shift+Print".action = screenshot-window;
        };

        window-rules = [
          {
            open-fullscreen = true;
            matches = [
              { title = "Waydroid"; }
            ];
          }
          # Pseudotiling
          {
            default-column-width.fixed = 370;
            default-window-height.fixed = 370;
            matches = [
              { title = "KDE Connect"; }
              { app-id = "org\\.gnome\\.Solanum"; }
            ];
          }
          # Bottom right notifications
          {
            default-floating-position = {
              x = 10;
              y = 10;
              relative-to = "bottom-right";
            };
            matches = [
              {
                app-id = "steam";
                title = "^notificationtoasts_\\d+_desktop$";
              }
            ];
          }
        ];
      };
    };
  };
}
