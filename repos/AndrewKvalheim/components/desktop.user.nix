{ config, lib, pkgs, ... }:

let
  inherit (builtins) ceil toFile;
  inherit (config) system;
  inherit (config.programs) dux-shell kitty niri;
  inherit (lib) concatLines escapeShellArg genAttrs getExe mkOption trim;
  inherit (lib.hm.generators) toKDL;
  inherit (lib.types) attrs listOf str submodule;
  inherit (pkgs) formats writeShellApplication writeText;

  dmsSettingsFormat = formats.json { };
  character = 7.5 /* px */;
  hour = 60 * minute;
  minute = 60 /* s */;

  aside = writeShellApplication {
    name = "aside";
    runtimeInputs = with pkgs; [ ddcutil jq kitty.package uutils-coreutils-noprefix ];
    text = ''
      brightness_percent='4'
      id=${escapeShellArg system.host.displays.aside.name}

      [[ "$(niri msg --json outputs | jq --arg 'id' "$id" 'has($id)')" == 'true' ]] || exit

      bus_path="$(readlink --canonicalize-existing "/sys/class/drm/card1-$id/ddc")"
      ddcutil --bus "''${bus_path#*-}" setvcp '0x10' "$brightness_percent"

      exec kitty --app-id='local.aside' --hold journalctl --follow
    '';
  };

  process-clipboard = writeShellApplication {
    name = "process-clipboard";
    runtimeInputs = with pkgs; [ kitty.package libnotify wl-clipboard ];
    text = let inherit (config.programs.process-clipboard) handlers; in ''
      replace_with() { local text="$1"
        wl-copy --type 'TEXT' "$text"
        notify-send --icon 'edit-copy-symbolic' --transient 'Updated clipboard' "$text"
      }

      soft_fail() { local message="$1"
        notify-send --icon 'dialog-error-symbolic' --transient "$message"
      }

      main() {
        local text
        if text="$(wl-paste --no-newline --type 'text')"; then
          ${concatLines (map ({action, condition}: "if ${trim condition}; then ${trim action}; return 0; fi") handlers)}
          soft_fail 'Failed to parse clipboard'
        else
          soft_fail 'Failed to read clipboard'
        fi
      }

      main
    '';
  };
in
{
  imports = [ ../library/dms-inhibit.user.nix ];

  options = {
    programs.dux-shell = {
      pluginSettings = mkOption { inherit (dmsSettingsFormat) type; };
      settings = mkOption { inherit (dmsSettingsFormat) type; };
    };

    programs.niri = {
      autoStart = mkOption { type = listOf (listOf str); default = [ ]; };
      settings = mkOption { type = attrs; };
      windowRules = mkOption {
        type = listOf (submodule { options = { apply = mkOption { type = attrs; }; to = mkOption { type = listOf attrs; }; }; });
        default = [ ];
      };
    };

    programs.process-clipboard = {
      handlers = mkOption {
        type = listOf (submodule { options = { action = mkOption { type = str; }; condition = mkOption { type = str; }; }; });
        default = [ ];
      };
    };
  };

  # TODO: Reintegrate or replace Stretch Break
  config = {
    # Packages
    home.packages = with pkgs; [
      pkgs."3mf-thumbnailer"
      adwaita-icon-theme
      aside
    ];

    # Niri
    programs.niri = {
      autoStart = [
        [ (getExe aside) ]
      ];
      settings = {
        binds = let dms = args: { spawn = [ "dms" "ipc" "call" ] ++ args; }; in {
          # System
          "XF86NotificationCenter" = dms [ "keybinds" "toggle" "niri" ];
          "Ctrl+Alt+Delete" = dms [ "powermenu" "toggle" ];
          "Mod+Escape".toggle-keyboard-shortcuts-inhibit = { };
          "Mod+L" = dms [ "lock" "lock" ];
          "Mod+Shift+E".quit = { };

          # Display
          "XF86HangupPhone".power-off-monitors = { };
          "XF86MonBrightnessDown" = dms [ "brightness" "decrement" "5" "" ] // { _props.allow-when-locked = true; };
          "XF86MonBrightnessUp" = dms [ "brightness" "increment" "5" "" ] // { _props.allow-when-locked = true; };

          # Volume
          "XF86AudioMute" = dms [ "audio" "mute" ] // { _props.allow-when-locked = true; };
          "XF86AudioLowerVolume" = dms [ "audio" "decrement" "3" ] // { _props.allow-when-locked = true; };
          "XF86AudioRaiseVolume" = dms [ "audio" "increment" "3" ] // { _props.allow-when-locked = true; };
          "XF86AudioMicMute" = dms [ "audio" "micmute" ];

          # Playback
          "XF86AudioPlay" = dms [ "mpris" "playPause" ];
          "XF86AudioPause" = dms [ "mpris" "playPause" ];
          "XF86AudioPrev" = dms [ "mpris" "previous" ];
          "XF86AudioNext" = dms [ "mpris" "next" ];

          # Screenshots
          "Print".screenshot = { };
          "Alt+Print".screenshot-window = { };
          "Ctrl+Print".screenshot-screen = { };

          # Applications
          "XF86Favorites".spawn = [ (getExe pkgs.emote) ];
          "Mod+Space" = dms [ "spotlight" "toggle" ];
          "Mod+C".spawn = [ (getExe process-clipboard) ];
          "Mod+N" = dms [ "notepad" "toggle" ];
          "Mod+T".spawn = [ (getExe kitty.package) ];
          "Mod+Shift+C" = dms [ "color-picker" "toggle" ];

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
        cursor.xcursor-theme = "Adwaita";
        environment.XDG_CURRENT_DESKTOP = "niri";
        gestures.hot-corners.off = { };
        hotkey-overlay.skip-at-startup = { };
        layout = {
          default-column-width.fixed = ceil (120 * character);
          preset-column-widths._children = map (p: { proportion = p; }) [ (1.0 / 3) (1.0 / 2) (2.0 / 3) 1.0 ];
        };
        recent-windows.binds = {
          "Alt+Tab".next-window._props.scope = "output";
          "Alt+Shift+Tab".previous-window._props.scope = "output";
        };
        screenshot-path = "~/Downloads/screenshot %Y-%m-%dT%H:%M:%S.png";
      };
      windowRules = [
        {
          apply = { default-column-width.fixed = ceil (100 * character); };
          to = [
            { app-id = "^appimagekit-joplin$"; }
            { app-id = "^local.result$"; }
            { app-id = "^org.gnome.SystemMonitor$"; }
            { app-id = "^signal$"; }
          ];
        }
        {
          apply = { open-floating = true; };
          to = [
            { app-id = "^firefox$"; title = "^Picture-in-Picture$"; }
            { app-id = "^qemu$"; }
            { app-id = "^Tor Browser$"; }
            { app-id = "^wev$"; }
            { app-id = "^xdg-desktop-portal$"; }
          ];
        }
        {
          apply = { open-fullscreen = true; open-on-output = system.host.displays.aside.name; };
          to = [{ app-id = "^local.aside$"; }];
        }
      ];
    };
    xdg.configFile."niri/config.kdl".source =
      let
        autostart._children = map (args: { spawn-at-startup = args; }) niri.autoStart;
        dms-override = {
          layout.focus-ring = {
            active-color = "#16161699";
            inactive-color = "#16161600";
          };
        };
        window-rules._children = map
          ({ apply, to }: { window-rule._children = (map (m: { match._props = m; }) to) ++ [ apply ]; })
          niri.windowRules;
      in
      writeText "niri-config" (toKDL { } {
        _children = [
          { include = "${writeText "settings.kdl" (toKDL { } niri.settings)}"; }
          { include = "${writeText "window-rules.kdl" (toKDL { } window-rules)}"; }
          { include = "${writeText "autostart.kdl" (toKDL { } autostart)}"; }

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
      });

    # Dux Modular Shell
    # TODO: theme
    # TODO: wallpaper
    # TODO: plugins
    programs.dux-shell = {
      settings = {
        # Appearance
        density = if system.host.metrics.displayWidth <= 1280 then "dense" else "compact";
        radiusStrength = 25;
        systemTrayIconTintMode = "monochrome";

        # Bar
        barConfigs = [
          {
            id = "default";
            attachToScreenEdge = true;
            centerWidgets = map (w: { enabled = true; } // w) [
              { id = "music"; }
              { id = "clock"; clockDateOrder = "dateFirst"; }
              { id = "notificationButton"; }
            ];
            enabled = true;
            fontScale = 1.28;
            gothCornersEnabled = true;
            iconScale = 1.28;
            innerPadding = -8;
            leftWidgets = map (w: { enabled = true; } // w) [
              { id = "workspaceSwitcher"; showOccupiedWorkspacesOnly = true; workspaceIndicatorCompact = true; workspaceIndicatorStyle = "dots"; }
            ];
            name = "Main Bar";
            noBackground = true;
            position = 0 /* top */;
            rightWidgets = map (w: { enabled = true; } // w) [
              { id = "systemTray"; }
              { id = "dankActions:utc"; }
              { id = "cpuUsage"; }
              { id = "memUsage"; }
              { id = "battery"; showBatteryPercentOnlyOnBattery = true; }
              { id = "controlCenterButton"; }
            ];
            screenPreferences = [{ inherit (system.host.displays.main) model name; }];
            showOnLastDisplay = true;
            surfaceColor = "custom";
            surfaceCustomColor = "#000000";
          }
        ];

        # Control center
        controlCenterWidgets = map (w: { enabled = true; } // w) (
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
          ])
        );

        # Dash
        dashCards = [{ id = "calendar"; col = 0; row = 0; w = 3; h = 3; }];
        dashOptions.overview = { panelRows = 3; panelColumns = 3; };
        dashTabs = map (id: { inherit id; enabled = false; })
          [ "overview" "media" "wallpaper" "weather" "wellbeing" "notifications" "settings" ];

        # Features
        builtInPluginSettings.dms_qr_generator.enabled = false;
        builtInPluginSettings.dms_clipboard_search.enabled = false;
        builtInPluginSettings.dms_vpn.enabled = false;
        desktopContextMenu = "off";
        launcherStyle = "spotlight";
        soundsEnabled = false;
        weatherEnabled = false;

        # Fonts
        fontFamily = "Roboto";
        monoFontFamily = "Iosevka Custom Mono";

        # Input
        mouseNaturalScroll = true;

        # Layout
        niriLayoutGapsOverride = 0;
        notificationCompactMode = true;
        notificationPopupPosition = -1 /* top center */;
        osdPosition = 0 /* top right */;
        screenPreferences = genAttrs [ "lockScreen" "notepad" "notifications" "osd" "toast" ]
          (s: [{ inherit (system.host.displays.main) model name; }]);
        showOnLastDisplay = { notepad = true; notifications = true; osd = true; toast = true; };

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
      pluginSettings = {
        dankActions = {
          enabled = true;
          variants = [
            {
              id = "utc";
              name = "UTC";
              showIcon = false;
              updateInterval = 60;
              displayCommand = "date --utc +'%HZ'";
              clickCommand = "dms ipc dash toggle overview";
            }
          ];
        };
      };
    };
    # FIXME: Changes not detected until `systemctl --user reload dms.service`
    xdg.configFile."dms/config.d/10-home-manager.json".source =
      dmsSettingsFormat.generate "dms-settings" dux-shell.settings;
    xdg.configFile."dms/plugin_settings.json".source =
      dmsSettingsFormat.generate "dms-settings" dux-shell.pluginSettings;

    # GDK
    dconf.settings."org/gnome/desktop/interface".accent-color = "orange";
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
