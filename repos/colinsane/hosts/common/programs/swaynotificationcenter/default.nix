# <https://github.com/ErikReider/SwayNotificationCenter>
# sway notification daemon
# alternative to mako, dunst, etc
#
# debugging:
# - `journalctl --user -u swaync`
# - `G_MESSAGES_DEBUG=all swaync`
# - reveal notification center: `swaync-client -t -sw`
#
# configuration:
# - defaults: /run/current-system/etc/profiles/per-user/colin/etc/xdg/swaync/
# - `man 5 swaync`
# - view document tree: `GTK_DEBUG=interactive swaync`  (`systemctl stop --user swaync` first)
# - examples:
#   - thread: <https://github.com/ErikReider/SwayNotificationCenter/discussions/183>
#   - buttons-grid and menubar: <https://gist.github.com/JannisPetschenka/fb00eec3efea9c7fff8c38a01ce5d507>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.swaynotificationcenter;
  buttons = import ./buttons.nix { inherit pkgs; };
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  sane.programs.swaync-service-dispatcher = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "swaync-service-dispatcher";
      srcRoot = ./.;
      pkgs = [
        "s6"
        "s6-rc"
        "systemd"
      ];
    };
  };

  sane.programs.swaync-fbcli = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "swaync-fbcli";
      srcRoot = ./.;
      pkgs = [
        "feedbackd"
        "procps"
        "swaynotificationcenter"
        "util-linux"
      ];
    };
  };

  sane.programs.swaynotificationcenter = {
    configOption = with lib; mkOption {
      type = types.submodule {
        options = {
          backlight = mkOption {
            type = types.str;
            default = "intel_backlight";
            description = ''
              name of entry in /sys/class/backlight which indicates the primary backlight.
            '';
          };
        };
      };
      default = {};
    };

    # prevent dbus from automatically activating swaync so i can manage it as a systemd service instead
    packageUnwrapped = pkgs.rmDbusServices (pkgs.swaynotificationcenter.overrideAttrs (upstream: {
      version = "0.10.1-unstable-2024-04-16";
      # toggling the panel on 0.10.1 sometimes causes toggle-buttons to toggle.
      # this is fixed post-0.10.1.
      # see: <https://github.com/ErikReider/SwayNotificationCenter/issues/405>
      src = lib.warnIf (lib.versionOlder "0.10.1" upstream.version) "swaync: safe to unpin" pkgs.fetchFromGitHub {
        owner = "ErikReider";
        repo = "SwayNotificationCenter";
        rev = "8cb9be59708bb051616d7e14d9fa0b87b86985af";
        hash = "sha256-UAegyzqutGulp6H7KplEfwHV0MfFfOHgYNNu+AQHx3g=";
      };
    }));

    suggestedPrograms = [
      "feedbackd"
      "swaync-fbcli"  #< used to sound ringer
      "swaync-service-dispatcher"  #< used when toggling buttons
    ];

    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [
      "user"  # mpris; portal
      "system"  # backlight
    ];
    sandbox.whitelistS6 = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      "/sys/class/backlight"
      "/sys/devices"
    ];
    sandbox.extraRuntimePaths = [
      # systemd/private allows one to `systemctl --user {status,start,stop,...}`
      # notably, it does *not* allow for `systemd-run` (that's dbus: org.freedesktop.systemd1.Manager.StartTransientUnit).
      # that doesn't necessarily mean this is entirely safe against privilege escalation though.
      # TODO: audit the safety of this systemd sandboxing.
      # few alternatives:
      # - superd
      # - simply `xdg-open app://dino`, etc. `pkill` to stop, `pgrep` to query.
      # - more robust: `xdg-open sane-service://start?service=dino`
      #   - still need `pgrep` to query if it's running, or have the service mark a pid file
      # - dbus activation for each app
      "systemd/private"
    ];
    sandbox.extraConfig = [
      # systemctl calls seem to require same pid namespace
      "--sane-sandbox-keep-namespace" "pid"
    ];

    # glib/gio applications support many notification backends ("portal", "gtk", "freedesktop", ...).
    # swaync implements only the `org.freedesktop.Notifications` dbus interface ("freedesktop"/fdo).
    # however gio applications may be tricked into using one of the other backends, particularly
    # if xdg-desktop-portal-gtk is installed and GIO_USE_PORTALS=1.
    # so, explicitly specify the desired backend.
    # the glib code which consumes this is `g_notification_backend_new_default`, calling into `_g_io_module_get_default_type`.
    env.GNOTIFICATION_BACKEND = "freedesktop";

    fs.".config/swaync/style.css".symlink.target = ./style.css;
    fs.".config/swaync/config.json".symlink.text = builtins.toJSON {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "user";  # "application"|"user". "user" in order to override the system gtk theme.
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 30;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;  #< have notification center take full vertical screen space
      # control-center-width:
      # pinephone native display is 720 x 1440
      # - for compositor scale=2.0 => 360
      # - for compositor scale=1.8 => 400
      # - for compositor scale=1.6 => 450
      # if it's set to something wider than the screen, then it overflows and items aren't visible.
      control-center-width = 360;
      control-center-height = 600;
      notification-window-width = 360;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 100;
      hide-on-clear = true;  #< hide control center when clicking "clear all"
      hide-on-action = true;
      script-fail-notify = true;
      inherit scripts;
      widgets = [
        # what to show in the notification center (and in which order).
        # these are configurable further via `widget-config`.
        # besides these listed, there are general-purpose UI tools:
        # - label (show some text)
        # - buttons-grid (labels which trigger actions when clicked)
        # - menubar (tree of labels/actions)
        "title"
        "dnd"
        "inhibitors"
        "buttons-grid"
        "backlight"
        "volume"
        "mpris"
        "notifications"
      ];
      widget-config = {
        backlight = {
          label = "󰃝 ";
          device = cfg.config.backlight;
        };
        buttons-grid = {
          actions =
          lib.optionals config.sane.programs.eg25-control.enabled [
            buttons.gps
            buttons.cell-modem
          ] ++ lib.optionals false [
            buttons.vpn
          ] ++ lib.optionals config.sane.programs.calls.config.autostart [
            buttons.gnome-calls
          ] ++ lib.optionals config.sane.programs."gnome.geary".enabled [
            buttons.geary
          # ] ++ lib.optionals config.sane.programs.abaddon.enabled [
          #   # XXX: disabled in favor of dissent: abaddon has troubles auto-connecting at start
          #   buttons.abaddon
          ] ++ lib.optionals config.sane.programs.dissent.enabled [
            buttons.dissent
          ] ++ lib.optionals config.sane.programs.signal-desktop.enabled [
            buttons.signal-desktop
          ] ++ lib.optionals config.sane.programs.dino.enabled [
            buttons.dino
          ] ++ lib.optionals config.sane.programs.fractal.enabled [
            buttons.fractal
          ];
        };
        dnd = {
          text = "Do Not Disturb";
        };
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        mpris = {
          image-size = 48;
          image-radius = 8;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        volume = {
          label = " ";
          # show-per-app: adds a drop-down, which when clicked allows control per app
          show-per-app = true;
          animation-duration = 130;
        };
      };
    };
    services.swaync = {
      # swaync ships its own service, but i want to add `environment` variables and flags for easier debugging.
      # seems that's not possible without defining an entire nix-native service (i.e. this).
      description = "swaynotificationcenter (swaync) desktop notification daemon";
      depends = [ "sound" ]; #< TODO: else it will NEVER see the pulse socket in its sandbox
      partOf = [ "graphical-session" ];

      command = "env G_MESSAGES_DEBUG=all swaync";
      readiness.waitDbus = "org.freedesktop.Notifications";
    };
  };

  sane.programs.feedbackd.config = lib.mkIf cfg.enabled {
    # claim control over feedbackd: we'll proxy the sounds we want on behalf of notifying programs
    proxied = true;
  };
}
