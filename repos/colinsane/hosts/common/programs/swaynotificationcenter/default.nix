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
# - view document tree: `GTK_DEBUG=interactive swaync`  (`systemctl stop swaync` first)
# - examples:
#   - thread: <https://github.com/ErikReider/SwayNotificationCenter/discussions/183>
#   - buttons-grid and menubar: <https://gist.github.com/JannisPetschenka/fb00eec3efea9c7fff8c38a01ce5d507>
#
# limitations:
# - brightness slider always reports correct value, but can only *change* the brightness under systemd logind.
#   - <repo:ErikReider/SwayNotificationCenter:src/controlCenter/widgets/backlight/backlightUtil.vala>
#   - could be made to work, by writing to /sys/class/backlight/... (the file it reads)
#
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
        "systemdMinimal"
      ];
    };
    sandbox.whitelistSystemctl = true;
    sandbox.keepPidsAndProc = true;  #< XXX: not sure why, but swaync segfaults under load without this!

    suggestedPrograms = [
      "systemctl"
    ];
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
    sandbox.whitelistDbus = [ "user" ];
    sandbox.keepPidsAndProc = true;  # `swaync-fbcli stop` needs to be able to find the corresponding `swaync-fbcli start` process
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
          enableBacklight = mkEnableOption "include a backlight slider in the swaync dropdown (requires an active session with systemd-logind)";
          enableMpris = (mkEnableOption "show the currently playing media in the swaync dropdown, and navigation buttons") // { default = true; };
        };
      };
      default = {};
    };

    # prevent dbus from automatically activating swaync so i can manage it as a service instead
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

      postPatch = (upstream.postPatch or "") + ''
        # Gtk3 by default won't pack more than 7 items into one row of a FlowBox.
        # but i want tighter control over my icon placement than that:
        substituteInPlace src/controlCenter/widgets/buttonsGrid/buttonsGrid.vala --replace-fail \
          'container.set_selection_mode' \
          'container.max_children_per_line = 8; container.set_selection_mode'
        '';
    }));

    suggestedPrograms = [
      "feedbackd"
      "swaync-fbcli"  #< used to sound ringer
      "swaync-service-dispatcher"  #< used when toggling buttons
    ];

    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [
      "user"  # mpris; portal
      "system"  # backlight
    ];
    sandbox.whitelistSystemctl = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      "/sys/class/backlight"
      "/sys/devices"
    ];

    # glib/gio applications support many notification backends ("portal", "gtk", "freedesktop", ...).
    # swaync implements only the `org.freedesktop.Notifications` dbus interface ("freedesktop"/fdo).
    # however gio applications may be tricked into using one of the other backends, particularly
    # if xdg-desktop-portal-gtk is installed and GIO_USE_PORTALS=1.
    # so, explicitly specify the desired backend.
    # the glib code which consumes this is `g_notification_backend_new_default`, calling into `_g_io_module_get_default_type`.
    env.GNOTIFICATION_BACKEND = "freedesktop";

    fs.".config/swaync/style.css".symlink.target = ./style.css;
    fs.".config/swaync/config.json".symlink.target = pkgs.writers.writeJSON "config.json" {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      control-center-height = 600;
      control-center-layer = "top";
      control-center-margin-bottom = 0;
      control-center-margin-left = 0;
      control-center-margin-right = 0;
      control-center-margin-top = 0;
      # control-center-width:
      # pinephone native display is 720 x 1440
      # - for compositor scale=2.0 => 360
      # - for compositor scale=1.8 => 400
      # - for compositor scale=1.6 => 450
      # if it's set to something wider than the screen, then it overflows and items aren't visible.
      control-center-width = 360;
      cssPriority = "user";  # "application"|"user". "user" in order to override the system gtk theme.
      fit-to-screen = true;  #< have notification center take full vertical screen space
      hide-on-action = true;
      hide-on-clear = true;  #< hide control center when clicking "clear all"
      image-visibility = "when-available";
      keyboard-shortcuts = true;
      layer = "overlay";
      layer-shell = true;
      notification-2fa-action = true;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-icon-size = 64;
      notification-inline-replies = false;
      notification-window-width = 360;
      positionX = "right";
      positionY = "top";
      script-fail-notify = true;
      timeout = 30;
      timeout-critical = 0;
      timeout-low = 5;
      transition-time = 100;

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
      ] ++ lib.optionals cfg.config.enableBacklight [
        "backlight"
      ] ++ [
        "volume"
      ] ++ lib.optionals cfg.config.enableMpris [
        "mpris"
      ] ++ [
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
          ] ++ lib.optionals config.sane.programs.calls.config.autostart [
            buttons.gnome-calls
          ] ++ lib.optionals config.sane.programs.dino.enabled [
            buttons.dino
          ] ++ lib.optionals config.sane.programs.fractal.enabled [
            buttons.fractal
          # ] ++ lib.optionals config.sane.programs.abaddon.enabled [
          #   # XXX: disabled in favor of dissent: abaddon has troubles auto-connecting at start
          #   buttons.abaddon
          ] ++ lib.optionals config.sane.programs.dissent.enabled [
            buttons.dissent
          ] ++ lib.optionals config.sane.programs.signal-desktop.enabled [
            buttons.signal-desktop
          ] ++ lib.optionals config.sane.programs.geary.enabled [
            buttons.geary
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

      # N.B.: G_MESSAGES_DEBUG=all breaks DND mode:
      #       messages are still hidden, but are not silent!
      # command = "env G_MESSAGES_DEBUG=all SWAYNC_DEBUG=1 swaync";
      command = "swaync";
      readiness.waitDbus = "org.freedesktop.Notifications";
    };
  };

  sane.programs.feedbackd.config = lib.mkIf cfg.enabled {
    # claim control over feedbackd: we'll proxy the sounds we want on behalf of notifying programs
    proxied = true;
  };
}
