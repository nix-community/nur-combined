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
  fbcli-wrapper = pkgs.writeShellApplication {
    name = "swaync-fbcli";
    runtimeInputs = [
      config.sane.programs.feedbackd.package
      cfg.package
    ];
    text = ''
      # if in Do Not Disturb, don't do any feedback
      # TODO: better solution is to actually make use of feedbackd profiles.
      #       i.e. set profile to `quiet` when in DnD mode
      if [ "$(swaync-client --get-dnd)" = "true" ]; then
        exit
      fi

      # feedbackd stops playback when the caller exits
      # and fbcli will exit immediately if it has no stdin.
      # so spoof a stdin:
      true | fbcli "$@"
    '';
  };
  fbcli = "${fbcli-wrapper}/bin/swaync-fbcli";
in
{
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
    package = pkgs.rmDbusServices pkgs.swaynotificationcenter;
    suggestedPrograms = [ "feedbackd" ];
    fs.".config/swaync/style.css".symlink.text = ''
      /* avoid black-on-black text that the default style ships */
      window {
        color: rgb(255, 255, 255);
      }
    '';
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
      control-center-width = 400;
      control-center-height = 600;
      notification-window-width = 400;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 100;
      hide-on-clear = true;  #< hide control center when clicking "clear all"
      hide-on-action = true;
      script-fail-notify = true;
      scripts = {
        sound-im = {
          # trigger notification sound on behalf of these IM clients.
          # TODO: dispatch calls separately!
          exec = "${fbcli} --event proxied-message-new-instant";
          app-name = "(Chats|Dino|discord|Element)";
        };
      };
      notification-visibility = {
        # match incoming notifications and decide if they should be visible.
        # map of rule-name => { criteria and effect };
        # keys:
        # - `state`: "ignored"|"muted"|"transient"|"enabled"
        #   => which visibility to apply to matched notifications
        #   => "ignored" behaves as if the notification was never sent.
        #   => "muted" adds it to the sidebar & sets the notif indicator but doesn't display it on main display
        # - `override-urgency`: "unset"|"low"|"normal"|"critical"
        #   => which urgency to apply to matched notifs
        # critera: each key is optional, value is regex; rule applies if *all* specified are matched
        # - `app-name`: string
        # - `desktop-entry`: string
        # - `summary`: string
        # - `body`: string
        # - `urgency`: "Low"|"Normal"|"Critical"
        # - `category`: string
        #
        # test rules by using `notify-send` (libnotify)
        sxmo-extraneous = {
          state = "ignored";
          summary = "(sxmo_hook_lisgd|Autorotate) (Stopped|Started)";
        };
      };
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
        dnd = {
          text = "Do Not Disturb";
        };
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        mpris = {
          image-size = 64;
          image-radius = 8;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        volume = {
          label = " ";
        };
      };
    };
    services.swaync = {
      # swaync ships its own service, but i want to add `environment` variables and flags for easier debugging.
      # seems that's not possible without defining an entire nix-native service (i.e. this).
      description = "Swaync desktop notification daemon";
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${cfg.package}/bin/swaync";
      serviceConfig.Type = "simple";
      # serviceConfig.BusName = "org.freedesktop.Notifications";
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";
      environment.G_MESSAGES_DEBUG = "all";
    };
  };

  sane.programs.feedbackd.config = lib.mkIf cfg.enabled {
    # claim control over feedbackd: we'll proxy the sounds we want on behalf of notifying programs
    proxied = true;
  };
}
