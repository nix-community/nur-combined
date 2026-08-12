# by-name/to/toshy/hm-module.nix
#
# Home Manager module for Toshy.
#
# Automates what upstream still requires running by hand:
#   setup_toshy.py install-user-files
# That installer is interactive (config backup/merge, DE probes, GNOME/KDE
# tweaks). This module installs the deterministic pieces instead:
#   - runtime link (XDG_STATE_HOME/toshy/runtime)
#   - user file tree at ~/.config/toshy (Toshy hardcodes this path)
#   - terminal commands in ~/.local/bin
#   - desktop entries + icons
#   - systemd user services + login autostart
#   - KWin notify script files (optional enable via kwriteconfig if present)
#
# Mutable on purpose (not store-linked):
#   ~/.config/toshy/toshy_config.py
#   ~/.config/toshy/toshy_user_preferences.sqlite
# The default config is seeded only if the file is missing.
#
# Not automated (DE-specific / interactive):
#   apply-tweaks (GNOME overlay-key, Plasma modifiers, Cinnamon, fancy-pants)
#   GNOME Shell extensions required on GNOME+Wayland
# Those can still be applied after switch:
#   ~/.local/state/toshy/runtime/bin/python ~/.config/toshy/setup_toshy.py apply-tweaks
#
# The NixOS module (modules.toshy) is required for the keymapper to open
# input devices unless you already set uinput + udev + the "input" group.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.toshy;
  homeDir = config.home.homeDirectory;
  userFiles = "${cfg.package}/share/toshy";

  stateHomeRel =
    let
      state = config.xdg.stateHome;
    in
    if lib.hasPrefix "${homeDir}/" state then lib.removePrefix "${homeDir}/" state else ".local/state";

  defaultConfig =
    if cfg.barebonesConfig then
      "${userFiles}/toshy_config_barebones.py.default"
    else
      "${userFiles}/toshy_config.py.default";

  binCommands = {
    toshy-share = "toshy-share.sh";
    toshy-systemd-setup = "toshy-systemd-setup.sh";
    toshy-systemd-remove = "toshy-systemd-remove.sh";
    toshy-services-status = "toshy-services-status.sh";
    toshy-services-disable = "toshy-services-disable.sh";
    toshy-services-enable = "toshy-services-enable.sh";
    toshy-services-restart = "toshy-services-restart.sh";
    toshy-services-start = "toshy-services-start.sh";
    toshy-services-stop = "toshy-services-stop.sh";
    toshy-services-log = "toshy-services-log.sh";
    toshy-config-start = "toshy-config-start.sh";
    toshy-config-stop = "toshy-config-stop.sh";
    toshy-config-restart = "toshy-config-restart.sh";
    toshy-debug = "toshy-config-start-verbose.sh";
    toshy-tray = "toshy-tray.sh";
    toshy-gui = "toshy-gui.sh";
    toshy-terminal-menu = "toshy-terminal-menu.sh";
    toshy-env = "toshy-env.sh";
    toshy-venv = "toshy-venv.sh";
    toshy-fnmode = "toshy-fnmode.sh";
    toshy-devices = "toshy-devices.sh";
    toshy-keycheck = "toshy-keycheck.sh";
    toshy-libinput = "toshy-libinput.sh";
    toshy-versions = "toshy-versions.sh";
    toshy-reinstall = "toshy-reinstall.sh";
    toshy-xkb-check = "toshy-xkb-check.sh";
    toshy-machine-id = "toshy-machine-id.sh";
    toshy-kblayout-check = "toshy-kblayout-check.sh";
    toshy-detector-check = "toshy-detector-check.sh";
    toshy-kwin-dbus-service = "toshy-kwin-dbus-service.sh";
    toshy-cosmic-dbus-service = "toshy-cosmic-dbus-service.sh";
    toshy-wlroots-dbus-service = "toshy-wlroots-dbus-service.sh";
  };

  mkDesktop =
    {
      name,
      exec,
      comment,
      extraLines ? [ ],
    }:
    ''
      [Desktop Entry]
      Type=Application
      Name=${name}
      Exec=${exec}
      Terminal=false
      Icon=toshy_app_icon_rainbow
      Comment=${comment}
      Categories=Utility;
      ${lib.concatStringsSep "\n" extraLines}
    '';

  configTreeDirs = [
    "assets"
    "cinnamon-extension"
    "cosmic-dbus-service"
    "default-toshy-config"
    "desktop"
    "kwin-dbus-service"
    "kwin-script"
    "scripts"
    "systemd-user-service-units"
    "toshy_common"
    "toshy_gui"
    "wlroots-dbus-service"
    "wlroots-dev"
  ];

  configTreeFiles = [
    "toshy_layout_selector.py"
    "toshy_tray.py"
    "setup_toshy.py"
  ];
in
{
  options.services.toshy = {
    enable = lib.mkEnableOption "Toshy (runtime link, user files, services, and launchers)";

    package = lib.mkPackageOption pkgs "toshy" { };

    barebonesConfig = lib.mkEnableOption "seeding a mostly empty Toshy config instead of the full default";

    autostartTray = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install an XDG autostart entry for the Toshy tray icon.";
    };

    systemd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install and enable Toshy systemd user services.";
    };

    installKwinScript = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install the Toshy KWin notify-active-window script under
        ~/.local/share/kwin/scripts and enable it with kwriteconfig if that
        tool is on PATH (no-op on non-Plasma systems).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge [
      {
        "${stateHomeRel}/toshy/runtime".source = cfg.package;
      }
      (lib.listToAttrs (
        map (name: {
          name = ".config/toshy/${name}";
          value.source = "${userFiles}/${name}";
        }) configTreeDirs
      ))
      (lib.listToAttrs (
        map (name: {
          name = ".config/toshy/${name}";
          value.source = "${userFiles}/${name}";
        }) configTreeFiles
      ))
      (lib.mapAttrs' (dest: src: {
        name = ".local/bin/${dest}";
        value = {
          source = "${userFiles}/scripts/bin/${src}";
          executable = true;
        };
      }) binCommands)
    ];

    xdg.dataFile = lib.mkMerge [
      {
        "applications/Toshy_Tray.desktop".text = mkDesktop {
          name = "Toshy Tray Icon";
          exec = "${homeDir}/.local/bin/toshy-tray";
          comment = "Tray Icon Menu for Toshy. Make Linux work like a 'Tosh!";
        };
        "applications/app.toshy.preferences.desktop".text = mkDesktop {
          name = "Toshy Preferences";
          exec = "${homeDir}/.local/bin/toshy-gui";
          comment = "Preferences GUI for Toshy. Make Linux work like a 'Tosh!";
          extraLines = [ "StartupWMClass=app.toshy.preferences" ];
        };
        "icons/hicolor/scalable/apps/toshy_app_icon_rainbow.svg".source =
          "${userFiles}/assets/toshy_app_icon_rainbow.svg";
        "icons/hicolor/scalable/apps/toshy_app_icon_rainbow_inverse.svg".source =
          "${userFiles}/assets/toshy_app_icon_rainbow_inverse.svg";
        "icons/hicolor/scalable/apps/toshy_app_icon_rainbow_inverse_grayscale.svg".source =
          "${userFiles}/assets/toshy_app_icon_rainbow_inverse_grayscale.svg";
      }
      (lib.mkIf cfg.installKwinScript {
        "kwin/scripts/toshy-dbus-notifyactivewindow".source =
          "${userFiles}/kwin-script/kde5_kde6_merged/toshy-dbus-notifyactivewindow";
      })
    ];

    xdg.configFile = lib.mkMerge [
      {
        "autostart/Toshy_Import_Vars.desktop".text = mkDesktop {
          name = "Toshy Import Vars";
          exec = "/bin/sh -c 'exec env sleep 3 && systemctl --user import-environment KDE_SESSION_VERSION XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP DESKTOP_SESSION DISPLAY WAYLAND_DISPLAY'";
          comment = "Environment importer for Toshy services";
        };
        "autostart/Toshy_Systemd_Service_Kickstart.desktop".text = mkDesktop {
          name = "Toshy Systemd Services Kickstart";
          exec = "/bin/sh -c 'sleep 5 && (ps -p 1 -o comm= | grep -q systemd) && systemctl --user is-enabled toshy-session-monitor.service &> /dev/null && (systemctl --user is-active toshy-session-monitor.service &> /dev/null || toshy-services-restart)'";
          comment = "Login kickstarter for Toshy Systemd Services";
        };
      }
      (lib.mkIf cfg.autostartTray {
        "autostart/Toshy_Tray.desktop".text = mkDesktop {
          name = "Toshy Tray Icon";
          exec = "${homeDir}/.local/bin/toshy-tray";
          comment = "Tray Icon Menu for Toshy. Make Linux work like a 'Tosh!";
        };
      })
    ];

    systemd.user.services = lib.mkIf cfg.systemd {
      toshy-config = {
        Unit = {
          Description = "Toshy Config Service";
          After = [ "default.target" ];
        };
        Service = {
          SyslogIdentifier = "toshy-config";
          Environment = [ "TERM=xterm" ];
          ExecStartPre = "%h/.config/toshy/scripts/toshy-service-config-execstartpre.sh";
          ExecStart = "%h/.config/toshy/scripts/tshysvc-config";
          Restart = "always";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
      toshy-session-monitor = {
        Unit = {
          Description = "Toshy Session Monitor";
          After = [ "default.target" ];
        };
        Service = {
          SyslogIdentifier = "toshy-sessmon";
          Environment = [ "TERM=xterm" ];
          ExecStart = "%h/.config/toshy/scripts/tshysvc-sessmon";
          Restart = "always";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
      toshy-kwin-dbus = {
        Unit = {
          Description = "Toshy KWin D-Bus Service";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 60;
        };
        Service = {
          SyslogIdentifier = "toshy-kwin-dbus";
          Environment = [ "TERM=xterm" ];
          ExecStartPre = ''/usr/bin/env bash -c 'if [ -z "$XDG_SESSION_TYPE" ]; then sleep 3; exit 1; fi' '';
          ExecStart = "%h/.config/toshy/scripts/bin/toshy-kwin-dbus-service.sh";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
      toshy-cosmic-dbus = {
        Unit = {
          Description = "Toshy COSMIC D-Bus Service";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 60;
        };
        Service = {
          SyslogIdentifier = "toshy-cosmic-dbus";
          Environment = [ "TERM=xterm" ];
          ExecStartPre = ''/usr/bin/env bash -c 'if [ -z "$XDG_SESSION_TYPE" ]; then sleep 3; exit 1; fi' '';
          ExecStart = "%h/.config/toshy/scripts/bin/toshy-cosmic-dbus-service.sh";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
      toshy-wlroots-dbus = {
        Unit = {
          Description = "Toshy Wlroots D-Bus Service";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 60;
        };
        Service = {
          SyslogIdentifier = "toshy-wlroots-dbus";
          Environment = [ "TERM=xterm" ];
          ExecStartPre = ''/usr/bin/env bash -c 'if [ -z "$XDG_SESSION_TYPE" ]; then sleep 3; exit 1; fi' '';
          ExecStart = "%h/.config/toshy/scripts/bin/toshy-wlroots-dbus-service.sh";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };

    home.activation.toshySeedConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dest="${homeDir}/.config/toshy/toshy_config.py"
      if [[ ! -e "$dest" ]]; then
        $DRY_RUN_CMD install -Dm644 ${lib.escapeShellArg defaultConfig} "$dest"
      fi
    '';

    home.activation.toshyEnableKwinScript = lib.mkIf cfg.installKwinScript (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if command -v kwriteconfig6 >/dev/null 2>&1; then
          $DRY_RUN_CMD kwriteconfig6 --file kwinrc --group Plugins --key toshy-dbus-notifyactivewindowEnabled true
        elif command -v kwriteconfig5 >/dev/null 2>&1; then
          $DRY_RUN_CMD kwriteconfig5 --file kwinrc --group Plugins --key toshy-dbus-notifyactivewindowEnabled true
        fi
      ''
    );
  };
}
