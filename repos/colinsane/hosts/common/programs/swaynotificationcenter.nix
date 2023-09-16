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
      pkgs.procps  # for pkill
      cfg.package
    ];
    text = ''
      # if in Do Not Disturb, don't do any feedback
      # TODO: better solution is to actually make use of feedbackd profiles.
      #       i.e. set profile to `quiet` when in DnD mode
      if [ "$SWAYNC_URGENCY" != "Critical" ] && [ "$(swaync-client --get-dnd)" = "true" ]; then
        exit
      fi

      # kill children if killed, to allow that killing this parent process will end the real fbcli call
      cleanup() {
        echo "aborting fbcli notification (PID $child)"
        pkill -P "$child"
        exit 0  # exit cleanly to avoid swaync alerting a script failure
      }
      trap cleanup SIGINT SIGQUIT SIGTERM

      # feedbackd stops playback when the caller exits
      # and fbcli will exit immediately if it has no stdin.
      # so spoof a stdin:
      /bin/sh -c "true | fbcli $*" &
      child=$!
      wait
    '';
  };
  fbcli = "${fbcli-wrapper}/bin/swaync-fbcli";

  # we do this because swaync's exec naively splits the command on space to produce its argv, rather than parsing the shell.
  # [ "pkill" "-f" "fbcli" "--event" ... ]  -> breaks pkill
  # [ "pkill" "-f" "fbcli --event ..." ]    -> is what we want
  fbcli-stop-wrapper = pkgs.writeShellApplication {
    name = "fbcli-stop";
    runtimeInputs = [
      pkgs.procps  # for pkill
    ];
    text = ''
      pkill -e -f "${fbcli} $*"
    '';
  };
  fbcli-stop = "${fbcli-stop-wrapper}/bin/fbcli-stop";

  systemctl-toggle = pkgs.writeShellApplication {
    name = "systemctl-toggle";
    runtimeInputs = [
      pkgs.systemd
    ];
    text = ''
      if systemctl is-active "$@"; then
        systemctl stop "$@"
      else
        systemctl start "$@"
      fi
    '';
  };
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
    package = pkgs.rmDbusServices (pkgs.swaynotificationcenter.overrideAttrs (upstream: {
      # allow toggle buttons:
      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/ErikReider/SwayNotificationCenter/pull/304.patch";
          name = "Add toggle button";
          hash = "sha256-bove2EXc5FZ5nN1X1FYOn3czCgHG03ibIAupJNoctiM=";
        })
        (pkgs.fetchpatch {
          url = "https://git.uninsane.org/colin/SwayNotificationCenter/commit/f5d9405e040fc42ea98dc4d37202c85728d0d4fd.patch";
          name = "toggleButton: change active field to be a command";
          hash = "sha256-Y8fiZbAP9yGOVU3rOkZKO8TnPPlrGpINWYGaqeeNzF0=";
        })
      ];
    }));
    suggestedPrograms = [ "feedbackd" ];
    fs.".config/swaync/style.css".symlink.text = ''
      /* avoid black-on-black text that the default style ships */
      window {
        color: rgb(255, 255, 255);
      }

      button {
        color: rgb(128, 128, 128);
      }
      button.active {
        color: rgb(255, 255, 255);
        background-color: rgb(0, 110, 190);
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
        # a script can match regex on these fields. only fired if all listed fields match:
        # - app-name
        # - desktop-entry
        # - summary
        # - body
        # - urgency (Low/Normal/Critical)
        # - category
        # additionally, the script can be run either on receipt or action:
        # - run-on = "receive" or "action"
        # when script is run, these env vars are available:
        # - SWAYNC_BODY
        # - SWAYNC_DESKTOP_ENTRY
        # - SWAYNC_URGENCY
        # - SWAYNC_TIME
        # - SWAYNC_APP_NAME
        # - SWAYNC_CATEGORY
        # - SWAYNC_REPLACES_ID
        # - SWAYNC_ID
        # - SWAYNC_SUMMARY
        sound-im = {
          # trigger notification sound on behalf of these IM clients.
          exec = "${fbcli} --event proxied-message-new-instant";
          app-name = "(Chats|Dino|discord|Element)";
          body = "^(?!Incoming call).*$";  #< don't match Dino Incoming calls
        };
        sound-call = {
          exec = "${fbcli} --event phone-incoming-call -t 20";
          app-name = "Dino";
          body = "^Incoming call$";
        };
        sound-call-end = {
          # pkill will kill all processes matching -- not just the first
          exec = "${fbcli-stop} --event phone-incoming-call -t 20";
          app-name = "Dino";
          body = "^Incoming call$";
          run-on = "action";
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
          actions = [
            # {
            #   type = "toggle";
            #   label = "feedbackd";
            #   command = "${systemctl-toggle}/bin/systemctl-toggle --user feedbackd";
            #   active = "${pkgs.systemd}/bin/systemctl is-active --user feedbackd.service";
            # }
            {
              type = "toggle";
              label = "gps";
              command = "/run/wrappers/bin/sudo ${systemctl-toggle}/bin/systemctl-toggle eg25-control-gps";
              active = "${pkgs.systemd}/bin/systemctl is-active eg25-control-gps.service";
            }
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
