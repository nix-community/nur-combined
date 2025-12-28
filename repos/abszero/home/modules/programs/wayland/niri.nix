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

        layout.empty-workspace-above-first = true;

        environment.DISPLAY = ":0"; # For XWayland

        binds = with config.lib.niri.actions; {
          "Mod+q".action = quit;
          "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
          "Mod+o".action = toggle-overview;
          "Mod+k".action = show-hotkey-overlay;

          # Navigation
          "Mod+Space".action = switch-focus-between-floating-and-tiling;
          "Mod+m".action = focus-monitor-previous;

          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-or-workspace-down;
          "Mod+Up".action = focus-window-or-workspace-up;
          "Mod+Right".action = focus-column-right;
          "Mod+Home".action = focus-column-first;
          "Mod+End".action = focus-column-last;

          # Column manipulation
          "Mod+t".action = toggle-column-tabbed-display;
          "Mod+f".action = maximize-column;
          "Mod+h".action = switch-preset-column-width;
          "Mod+Shift+h".action = expand-column-to-available-width;
          "Mod+c".action = consume-window-into-column;
          "Mod+Shift+c".action = expel-window-from-column;
          "Mod+Shift+m".action = move-column-to-monitor-previous;

          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Down".action = move-column-to-workspace-down { focus = true; };
          "Mod+Shift+Up".action = move-column-to-workspace-up { focus = true; };
          "Mod+Shift+Right".action = move-column-right;
          "Mod+Shift+Home".action = move-column-to-first;
          "Mod+Shift+End".action = move-column-to-last;

          # Window manipulation
          "Mod+w".action = close-window;
          "Mod+Shift+Space".action = toggle-window-floating;
          "Mod+Ctrl+f".action = fullscreen-window;
          "Mod+v".action = switch-preset-window-height;
          "Mod+Shift+v".action = reset-window-height;
          "Mod+Ctrl+Shift+m".action = move-window-to-monitor-previous;

          "Mod+Ctrl+Shift+Left".action = consume-or-expel-window-left;
          "Mod+Ctrl+Shift+Down".action = move-window-down-or-to-workspace-down;
          "Mod+Ctrl+Shift+Up".action = move-window-up-or-to-workspace-up;
          "Mod+Ctrl+Shift+Right".action = consume-or-expel-window-right;

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
          "Shift+Print".action.screenshot-screen = [ ];
          "Ctrl+Print".action = screenshot-window;
        };

        layer-rules = [
          {
            place-within-backdrop = true;
            matches = [
              { namespace = "^pandora$"; }
            ];
          }
        ];

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
              { title = "Buzz"; }
              { title = "KDE Connect"; }
              { app-id = "org\\.gnome\\.Solanum"; }
            ];
          }
          {
            open-floating = true;
            matches = [
              { app-id = "org\\.kde\\.polkit-kde-authentication-agent-1"; }
              { app-id = "it\\.mijorus\\.smile"; }
            ];
          }
          # Float up and down
          {
            baba-is-float = true;
            matches = [
              { app-id = "org\\.kde\\.polkit-kde-authentication-agent-1"; }
            ];
          }
          # Overlay
          {
            open-floating = true;
            focus-ring.enable = false;
            shadow.enable = false;
            matches = [
              { title = "AIRI"; }
            ];
          }
          # Fix to bottom right
          {
            default-floating-position = {
              x = 20;
              y = 0;
              relative-to = "bottom-right";
            };
            matches = [
              {
                app-id = "steam";
                title = "^notificationtoasts_\\d+_desktop$";
              }
              {
                title = "AIRI";
              }
            ];
          }
        ];
      };
    };
  };
}
