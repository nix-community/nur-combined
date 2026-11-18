{ config, lib, pkgs, ... }:

let
  inherit (builtins) toFile;
  inherit (config) xdg;
  inherit (config.programs) dux-shell;
  inherit (lib) mkOption;
  inherit (lib.hm.generators) toKDL;
  inherit (pkgs) formats;

  dmsSettingsFormat = formats.json { };
  hour = 60 * minute;
  minute = 60;
in
{
  imports = [ ../library/dms-inhibit.user.nix ];

  # Pending nix-community/home-manager#9686
  options.programs.dux-shell.settings = mkOption { inherit (dmsSettingsFormat) type; };

  # TODO: Reintegrate or replace Stretch Break
  config = {
    # Packages
    home.packages = with pkgs; [
      pkgs."3mf-thumbnailer"
      adwaita-icon-theme
      emote
    ];

    # Niri
    xdg.configFile."niri/config.kdl".text =
      let
        dms-override = {
          layout.focus-ring = {
            active-color = "#16161699";
            inactive-color = "#16161600";
          };
        };
        settings = {
          binds = let dms = args: [ "dms" "ipc" "call" ] ++ args; in {
            # System
            "XF86NotificationCenter".spawn = dms [ "keybinds" "toggle" "niri" ];
            "Ctrl+Alt+Delete".spawn = dms [ "powermenu" "toggle" ];
            "Mod+Escape".toggle-keyboard-shortcuts-inhibit = { };
            "Mod+L".spawn = dms [ "lock" "lock" ];
            "Mod+Shift+E".quit = { };

            # Display
            "XF86HangupPhone".power-off-monitors = { };
            "XF86MonBrightnessDown" = { spawn = dms [ "brightness" "decrement" "5" "" ]; _props.allow-when-locked = true; };
            "XF86MonBrightnessUp" = { spawn = dms [ "brightness" "increment" "5" "" ]; _props.allow-when-locked = true; };

            # Volume
            "XF86AudioMute" = { spawn = dms [ "audio" "mute" ]; _props.allow-when-locked = true; };
            "XF86AudioLowerVolume" = { spawn = dms [ "audio" "decrement" "3" ]; _props.allow-when-locked = true; };
            "XF86AudioRaiseVolume" = { spawn = dms [ "audio" "increment" "3" ]; _props.allow-when-locked = true; };
            "XF86AudioMicMute".spawn = dms [ "audio" "micmute" ];

            # Playback
            "XF86AudioPlay".spawn = dms [ "mpris" "playPause" ];
            "XF86AudioPause".spawn = dms [ "mpris" "playPause" ];
            "XF86AudioPrev".spawn = dms [ "mpris" "previous" ];
            "XF86AudioNext".spawn = dms [ "mpris" "next" ];

            # Screenshots
            "Print".screenshot = { };
            "Alt+Print".screenshot-window = { };
            "Ctrl+Print".screenshot-screen = { };

            # Applications
            "XF86Favorites".spawn = [ "emote" ];
            "Mod+Space".spawn = dms [ "spotlight" "toggle" ];
            "Mod+C".spawn = [ "/home/ak/.local/bin/clipboard-auto-dispatch" ];
            "Mod+N".spawn = dms [ "notepad" "toggle" ];
            "Mod+T".spawn = [ "kitty" ];
            "Mod+Shift+C".spawn = dms [ "color-picker" "toggle" ];

            # Window status
            "F13".toggle-window-floating = { };
            "Alt+F4" = { _props.repeat = false; close-window = { }; };

            # Window size
            "Mod+Return".expand-column-to-available-width = { };
            "Mod+I".switch-preset-column-width-back = { };
            "Mod+E".switch-preset-column-width = { };
            "Mod+O".switch-preset-window-height = { };
            "Mod+A".reset-window-height = { };

            # Window motion
            "Mod+Left".focus-column-left = { };
            "MouseForward".focus-column-left = { };
            "Mod+Ctrl+Left".move-column-left = { };
            "Mod+Ctrl+Shift+Left".consume-or-expel-window-left = { };
            "Mod+Right".focus-column-right = { };
            "MouseBack".focus-column-right = { };
            "Mod+Ctrl+Right".move-column-right = { };
            "Mod+Ctrl+Shift+Right".consume-or-expel-window-right = { };
            "Mod+Down".focus-window-down = { };
            "Mod+Ctrl+Down".move-window-down = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Ctrl+Up".move-window-up = { };

            # Workspaces
            "F14".toggle-overview = { };
            "Mod+Page_Down".focus-workspace-down = { };
            "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
            "Mod+Page_Up".focus-workspace-up = { };
            "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };

            # Monitors
            "Mod+Alt+Left".focus-monitor-left = { };
            "Mod+Alt+Ctrl+Left".move-column-to-monitor-left = { };
            "Mod+Alt+Right".focus-monitor-right = { };
            "Mod+Alt+Ctrl+Right".move-column-to-monitor-right = { };
            "Mod+Alt+Down".focus-monitor-down = { };
            "Mod+Alt+Ctrl+Down".move-column-to-monitor-down = { };
            "Mod+Alt+Up".focus-monitor-up = { };
            "Mod+Alt+Ctrl+Up".move-column-to-monitor-up = { };
          };
          config-notification.disable-failed = { };
          environment.XDG_CURRENT_DESKTOP = "niri";
          gestures.hot-corners.off = { };
          hotkey-overlay.skip-at-startup = { };
          layout = {
            default-column-width.fixed = 900;
            preset-column-widths._children = map (p: { proportion = p; }) [ (1.0 / 3) (1.0 / 2) (2.0 / 3) 1.0 ];
          };
          prefer-no-csd = { };
          recent-windows.binds = {
            "Alt+Tab".next-window._props.scope = "output";
            "Alt+Shift+Tab".previous-window._props.scope = "output";
          };
          screenshot-path = "~/Downloads/screenshot %Y-%m-%dT%H:%M:%S.png";
        };
        window-rules._children = [
          {
            window-rule._children = [
              { match._props = { app-id = "^appimagekit-joplin$"; }; }
              { match._props = { app-id = "^org.gnome.SystemMonitor$"; }; }
              { default-column-width.fixed = 750; }
            ];
          }
          {
            window-rule._children = [
              { match._props = { app-id = "^firefox$"; title = "^Picture-in-Picture$"; }; }
              { match._props = { app-id = "^qemu$"; }; }
              { match._props = { app-id = "^Tor Browser$"; }; }
              { match._props = { app-id = "^wev$"; }; }
              { match._props = { app-id = "^xdg-desktop-portal$"; }; }
              { open-floating = true; }
            ];
          }
        ];
      in
      toKDL { } {
        _children = [
          { include = toFile "settings.kdl" (toKDL { } settings); }
          { include = toFile "window-rules.kdl" (toKDL { } window-rules); }

          # Generated by Dux Modular Shell
          { include = "dms/colors.kdl"; }
          { include = "dms/layout.kdl"; }
          { include = "dms/alttab.kdl"; }
          { include = "dms/binds.kdl"; }
          { include = "dms/outputs.kdl"; }
          { include = "dms/cursor.kdl"; }
          { include = "dms/input.kdl"; }
          { include = "dms/windowrules.kdl"; }

          { include = toFile "dms-override.kdl" (toKDL { } dms-override); }
        ];
      };

    # Dux Modular Shell
    # TODO: theme
    # TODO: barConfigs
    # TODO: plugins
    programs.dux-shell.settings = {
      # Appearance
      cursorSettings.theme = "Adwaita";
      density = "compact";
      desktopContextMenu = "off";
      radiusStrength = 25;
      systemTrayIconTintMode = "monochrome";

      # Control center
      controlCenterWidgets = map (w: { enabled = true; } // w)
        (map (w: (if w ? group then { } else { row = 0; }) // w) [
          { col = 0; w = 5; h = 1; id = "user"; background = false; badge = false; compositor = false; uptime = false; }
          { col = 5; w = 3; h = 1; small = true; id = "quickTiles"; background = false; instanceId = "top"; }
          { group = "top"; id = "edit"; }
          { group = "top"; id = "settings"; }
          { group = "top"; id = "lock"; }
          { group = "top"; id = "power"; }
        ]) ++ (map (w: (if w ? group then { } else { row = 1; }) // w) [
        { col = 0; w = 4; h = 1; small = true; id = "volumeSlider"; }
        { col = 4; w = 3; h = 1; small = true; id = "brightnessSlider"; }
        { col = 7; w = 1; h = 1; small = true; id = "quickTiles"; background = false; instanceId = "brightness"; }
        { group = "brightness"; id = "nightMode"; }
      ]) ++ (map (w: (if w ? group then { } else { row = 2; }) // w) [
        { col = 0; w = 4; h = 1; id = "audioOutput"; }
        { col = 4; w = 4; h = 1; id = "wifi"; }
      ]) ++ (map (w: (if w ? group then { } else { row = 3; }) // w) [
        { col = 0; w = 4; h = 1; id = "audioInput"; }
        { col = 4; w = 4; h = 1; id = "bluetooth"; }
      ]) ++ (map (w: (if w ? group then { } else { row = 4; }) // w) [
        { col = 4; w = 4; h = 1; id = "idleInhibitor"; }
      ]);

      # Dash
      dashCards = [{ id = "calendar"; col = 0; row = 0; w = 3; h = 3; }];
      dashOptions.overview = { panelRows = 3; panelColumns = 3; };
      dashTabs = map (id: { inherit id; enabled = false; })
        [ "overview" "media" "wallpaper" "weather" "wellbeing" "notifications" "settings" ];

      # Features
      builtInPluginSettings.dms_qr_generator.enabled = false;
      builtInPluginSettings.dms_clipboard_search.enabled = false;
      builtInPluginSettings.dms_vpn.enabled = false;
      launcherStyle = "spotlight";
      soundsEnabled = false;
      weatherEnabled = false;

      # Fonts
      fontFamily = "Roboto";
      monoFontFamily = "Iosevka Custom Mono";

      # Input
      mouseNaturalScroll = true;

      # Layout
      notificationCompactMode = true;
      notificationPopupPosition = -1 /* top center */;
      osdPosition = 0 /* top right */;

      # Locale
      clockFormat = "24h";
      clockDateFormat = "yyyy-MM-dd ddd";

      # Lock screen
      acLockTimeout = 30 * minute;
      batteryLockTimeout = 5 * minute;
      lockScreenShowPowerActions = true;
      lockScreenPowerOffMonitorsOnLock = true;

      # Power
      acMonitorTimeout = 10 * minute;
      batteryMonitorTimeout = 3 * minute;
      acSuspendTimeout = 0 /* ∞ */;
      batterySuspendTimeout = 2 * hour;
    };
    # FIXME: Changes not detected until `systemctl --user reload dms.service`
    xdg.configFile."dms/config.d/10-home-manager.json".source = dmsSettingsFormat.generate "dms-settings" dux-shell.settings;

    # GDK
    dconf.settings."org/gnome/desktop/interface".accent-color = "orange";
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
