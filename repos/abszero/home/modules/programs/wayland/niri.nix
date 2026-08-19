{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.niri;
in

{
  options.abszero.programs.niri.enable = mkEnableOption "scrolling wayland compositor";

  config.wayland.windowManager.niri = mkIf cfg.enable {
    enable = true;

    settings = {
      clipboard.disable-primary = { }; # Disable the clipboard containing last mouse selection
      hotkey-overlay.skip-at-startup = { };
      prefer-no-csd = { };
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

      input = {
        keyboard = {
          repeat-delay = 200;
          repeat-rate = 50;
        };
        touchpad = {
          dwt = { };
          drag-lock = { };
        };
      };

      layout.empty-workspace-above-first = { };

      recent-windows.binds = {
        "Mod+Tab".next-window = { };
        "Mod+Shift+Tab".previous-window = { };
        "Mod+Ctrl+Tab".next-window._props.filter = "app-id";
        "Mod+Ctrl+Shift+Tab".previous-window._props.filter = "app-id";
      };

      binds = {
        "Mod+q".quit = { };
        "Mod+Escape".toggle-keyboard-shortcuts-inhibit = { };
        "Mod+o".toggle-overview = { };
        "Mod+k".show-hotkey-overlay = { };

        # Navigation
        "Mod+Space".switch-focus-between-floating-and-tiling = { };
        "Mod+m".focus-monitor-previous = { };

        "Mod+Left".focus-column-left = { };
        "Mod+Down".focus-window-or-workspace-down = { };
        "Mod+Up".focus-window-or-workspace-up = { };
        "Mod+Right".focus-column-right = { };
        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };

        # Column manipulation
        "Mod+t".toggle-column-tabbed-display = { };
        "Mod+f".maximize-column = { };
        "Mod+h".switch-preset-column-width = { };
        "Mod+Shift+h".expand-column-to-available-width = { };
        "Mod+c".consume-window-into-column = { };
        "Mod+Shift+c".expel-window-from-column = { };
        "Mod+Shift+m".move-column-to-monitor-previous = { };

        "Mod+Shift+Left".move-column-left = { };
        "Mod+Shift+Down".move-column-to-workspace-down._props.focus = true;
        "Mod+Shift+Up".move-column-to-workspace-up._props.focus = true;
        "Mod+Shift+Right".move-column-right = { };
        "Mod+Shift+Home".move-column-to-first = { };
        "Mod+Shift+End".move-column-to-last = { };

        # Window manipulation
        "Mod+w".close-window = { };
        "Mod+Shift+Space".toggle-window-floating = { };
        "Mod+Ctrl+f".fullscreen-window = { };
        "Mod+v".switch-preset-window-height = { };
        "Mod+Shift+v".reset-window-height = { };
        "Mod+Ctrl+Shift+m".move-window-to-monitor-previous = { };

        "Mod+Ctrl+Shift+Left".consume-or-expel-window-left = { };
        "Mod+Ctrl+Shift+Down".move-window-down-or-to-workspace-down = { };
        "Mod+Ctrl+Shift+Up".move-window-up-or-to-workspace-up = { };
        "Mod+Ctrl+Shift+Right".consume-or-expel-window-right = { };

        # Media
        XF86AudioMute = {
          _props.allow-when-locked = true;
          spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
        };
        XF86AudioLowerVolume = {
          _props.allow-when-locked = true;
          spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%-"
          ];
        };
        XF86AudioRaiseVolume = {
          _props.allow-when-locked = true;
          spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%+"
          ];
        };
        XF86AudioMicMute = {
          _props.allow-when-locked = true;
          spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];
        };
        Print.screenshot = { };
        "Shift+Print".screenshot-screen = { };
        "Ctrl+Print".screenshot-window = { };
      };

      _children = [
        # Fullscreen
        {
          window-rule = {
            match._props.title = "Waydroid";
            open-fullscreen = true;
          };
        }
        # Pseudotiling
        {
          window-rule = {
            _children = [
              { match._props.title = "Buzz"; }
              { match._props.title = "KDE Connect"; }
              { match._props.app-id = "org\\.gnome\\.Solanum"; }
            ];
            default-column-width.fixed = 370;
            default-window-height.fixed = 370;
          };
        }
        # Floating
        {
          window-rule = {
            _children = [
              { match._props.app-id = "org\\.kde\\.polkit-kde-authentication-agent-1"; }
              { match._props.app-id = "it\\.mijorus\\.smile"; }
              {
                match._props = {
                  app-id = "Vial";
                  title = "Enter an arbitrary keycode";
                };
              }
            ];
            open-floating = true;
          };
        }
        # Float up and down
        {
          window-rule = {
            match._props.app-id = "org\\.kde\\.polkit-kde-authentication-agent-1";
            baba-is-float = true;
          };
        }
        # Overlay
        {
          window-rule = {
            match._props.title = "AIRI";
            open-floating = true;
            focus-ring.off = { };
            shadow.on = { };
          };
        }
        # Fix to bottom right
        {
          window-rule = {
            _children = [
              {
                match._props = {
                  app-id = "steam";
                  title = "^notificationtoasts_\\d+_desktop$";
                };
              }
              { match._props.title = "AIRI"; }
            ];
            default-floating-position._props = {
              x = 20;
              y = 0;
              relative-to = "bottom-right";
            };
          };
        }
      ];
    };
  };
}
