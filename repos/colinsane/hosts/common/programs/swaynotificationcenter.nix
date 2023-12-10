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

  mprisIconSize = 48;

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

  kill-singleton_ = pkgs.writeShellApplication {
    name = "kill-singleton";
    runtimeInputs = [
      pkgs.procps  # for pgrep
      pkgs.gnugrep
    ];
    text = ''
      pids=$(pgrep --full "$*" | tr '\n' ' ') || true
      # only act if there's exactly one pid
      if echo "$pids" | grep -Eq '^[0-9]+ ?$'; then
        kill "$pids"
      else
        echo "kill-singleton: skipping because multiple pids match: $pids"
      fi
    '';
  };
  kill-singleton = "${kill-singleton_}/bin/kill-singleton";

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
        # (pkgs.fetchpatch {
        #   url = "https://github.com/ErikReider/SwayNotificationCenter/pull/304.patch";
        #   name = "Add toggle button";
        #   hash = "sha256-bove2EXc5FZ5nN1X1FYOn3czCgHG03ibIAupJNoctiM=";
        # })
        (pkgs.fetchpatch {
          # import of <https://github.com/ErikReider/SwayNotificationCenter/pull/304>
          # as of 2023/11/08 the upstream patch has merge conflicts AND runtime issues (see wip-swaync-update nixos branch)
          url = "https://git.uninsane.org/colin/SwayNotificationCenter/commit/d9a0d938b88cbee65cfaef887af77a5a23d5fe89.patch";
          name = "Add toggle button";
          hash = "sha256-bove2EXc5FZ5nN1X1FYOn3czCgHG03ibIAupJNoctiM=";
        })
        (pkgs.fetchpatch {
          url = "https://git.uninsane.org/colin/SwayNotificationCenter/commit/f5d9405e040fc42ea98dc4d37202c85728d0d4fd.patch";
          name = "toggleButton: change active field to be a command";
          hash = "sha256-Y8fiZbAP9yGOVU3rOkZKO8TnPPlrGpINWYGaqeeNzF0=";
        })
      ];
      postPatch = (upstream.postPatch or "") + ''
        # XXX: this might actually be changing the DPI, not the scaling...
        # in that case, it might be possible to do this in CSS
        substituteInPlace src/controlCenter/widgets/mpris/mpris_player.ui \
          --replace '96' '${builtins.toString mprisIconSize}'
      '';
    }));
    suggestedPrograms = [ "feedbackd" ];
    fs.".config/swaync/style.css".symlink.text = ''
      /* these color definitions are used by the built-in style */
      /* noti-bg defaults `rgb(48, 48, 48)` and is the default button/slider/grid background */
      @define-color noti-bg rgb(36, 36, 36);
      @define-color noti-bg-darker rgb(24, 24, 24);

      /* avoid black-on-black text that the default style ships */
      window {
        color: rgb(255, 255, 255);
      }

      /* window behind entire control center. defaults to 25% opacity. */
      .blank-window {
        background: rgba(0, 0, 0, 0.5);
      }

      .widget-buttons-grid>flowbox>flowboxchild>button.toggle {
        /* text color for inactive buttons, and "Clear All" button.*/
        color: rgb(172, 172, 172);
        /* padding defaults to 16px; tighten, so i can squish it all onto one row */
        padding-left: 0px;
        padding-right: 0px;
      }
      .widget-buttons-grid>flowbox>flowboxchild>button.toggle.active {
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
      # control-center-width:
      # - for SXMO_SWAY_SCALE=1.8 => 400
      # - for SXMO_SWAY_SCALE=1.6 => 450
      # if it's set to something wider than the screen, then it overflows and items aren't visible.
      control-center-width = 450;
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

        # rules to use for testing. trigger with:
        # - `notify-send test test:message` (etc)
        # should also be possible to trigger via any messaging app
        fbcli-test-im = {
          body = "test:message";
          exec = "${fbcli} --event proxied-message-new-instant";
        };
        fbcli-test-call = {
          body = "test:call";
          exec = "${fbcli} --event phone-incoming-call -t 20";
        };
        fbcli-test-call-stop = {
          body = "test:call-stop";
          exec = "${fbcli-stop} --event phone-incoming-call -t 20";
        };
        fbcli-test-timer = {
          body = "test:timer";
          exec = "${fbcli} --event timeout-completed";
        };

        incoming-im-known-app-name = {
          # trigger notification sound on behalf of these IM clients.
          app-name = "(Chats|Dino|discord|Element|Fractal|gtkcord4)";
          body = "^(?!Incoming call).*$";  #< don't match Dino Incoming calls
          exec = "${fbcli} --event proxied-message-new-instant";
        };
        incoming-im-known-desktop-entry = {
          # trigger notification sound on behalf of these IM clients.
          # these clients don't have an app-name (listed as "<unknown>"), but do have a desktop-entry
          desktop-entry = "com.github.uowuo.abaddon";
          exec = "${fbcli} --event proxied-message-new-instant";
        };
        incoming-call = {
          app-name = "Dino";
          body = "^Incoming call$";
          exec = "${fbcli} --event phone-incoming-call -t 20";
        };
        incoming-call-acted-on = {
          # when the notification is clicked, stop sounding the ringer
          app-name = "Dino";
          body = "^Incoming call$";
          run-on = "action";
          exec = "${fbcli-stop} --event phone-incoming-call -t 20";
        };
        timer-done = {
          # sxmo_timer.sh fires off notifications like "Done with 10m" when a 10minute timer completes.
          # it sends such a notification every second until dismissed
          app-name = "notify-send";
          summary = "^Done with .*$";
          # XXX: could use alarm-clock-elapsed, but that's got a duration > 1s
          # which isn't great for sxmo's 1s repeat.
          # TODO: maybe better to have sxmo only notify once, and handle this like with Dino's incoming call
          exec = "${fbcli} --event timeout-completed";
        };
        timer-done-acted-on = {
          # when the notification is clicked, kill whichever sxmo process is sending it
          app-name = "notify-send";
          summary = "^Done with .*$";
          run-on = "action";
          # process tree looks like:
          # - foot -T <...> /nix/store/.../sh /nix/store/.../.sxmo_timer.sh-wrapped timerrun <duration>
          #   - /nix/store/.../sh /nix/store/.../.sxmo_timer.sh-wrapped timerrun duration
          # we want to match exactly one of those, reliably.
          # foot might not be foot, but alacritty, kitty, or any other terminal.
          exec = "${kill-singleton} ^[^ ]* ?[^ ]*sxmo_timer.sh(-wrapped)? timerrun";
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
        sxmo-extraneous-daemons = {
          app-name = "notify-send";
          summary = "(sxmo_hook_lisgd|Autorotate) (Stopped|Started)";
          state = "ignored";
        };
        sxmo-extraneous-warnings = {
          app-name = "notify-send";
          # "Modem crashed! 30s recovery.": happens on sxmo_hook_postwake.sh (i.e. unlock)
          summary = "^Modem crashed.*$";
          state = "ignored";
        };
        sxmo-timer = {
          # force timer announcements to bypass DND
          app-name = "notify-send";
          summary = "^Done with .*$";
          override-urgency = "critical";
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
          actions =
            # {
            #   type = "toggle";
            #   label = "feedbackd";
            #   command = "${systemctl-toggle}/bin/systemctl-toggle --user feedbackd";
            #   active = "${pkgs.systemd}/bin/systemctl is-active --user feedbackd.service";
            # }
          lib.optionals config.sane.programs.eg25-control.enabled [
            {
              type = "toggle";
              label = "";  # GPS services; other icons: gps, ⌖, 🛰, 🌎, 
              command = "/run/wrappers/bin/sudo ${systemctl-toggle}/bin/systemctl-toggle eg25-control-gps";
              active = "${pkgs.systemd}/bin/systemctl is-active eg25-control-gps.service";
            }
            {
              type = "toggle";
              label = "󰺐";  # icons: 5g, 📡, 📱, ᯤ, ⚡, , 🌐, 📶, 🗼, 󰀂, , 󰺐, 󰩯
              # modem and NetworkManager auto-establishes a connection when powered.
              # though some things like `wg-home` VPN tunnel will remain routed over the old interface.
              command = "/run/wrappers/bin/sudo ${systemctl-toggle}/bin/systemctl-toggle eg25-control-powered";
              active = "${pkgs.systemd}/bin/systemctl is-active eg25-control-powered.service";
            }
          ] ++ lib.optionals false [
            {
              type = "toggle";
              label = "vpn::hn";  # route all traffic through servo; useful to debug moby's networking
              command = "/run/wrappers/bin/sudo ${systemctl-toggle}/bin/systemctl-toggle wg-quick-vpn-servo";
              active = "${pkgs.systemd}/bin/systemctl is-active wg-quick-vpn-servo.service";
            }
          ] ++ lib.optionals config.sane.programs.calls.config.autostart [
            {
              type = "toggle";
              label = "SIP";
              command = "${systemctl-toggle}/bin/systemctl-toggle --user gnome-calls";
              active = "${pkgs.systemd}/bin/systemctl is-active --user gnome-calls";
            }
          ] ++ lib.optionals config.sane.programs."gnome.geary".enabled [
            {
              type = "toggle";
              label = "󰇮";  # email (Geary); other icons: ✉, [E], 📧, 󰇮
              command = "${systemctl-toggle}/bin/systemctl-toggle --user geary";
              active = "${pkgs.systemd}/bin/systemctl is-active --user geary";
            }
          # ] ++ lib.optionals config.sane.programs.abaddon.enabled [
          #   # XXX: disabled in favor of gtkcord4: abaddon has troubles auto-connecting at start
          #   {
          #     type = "toggle";
          #     label = "󰊴";  # Discord chat client; icons: 󰊴, 🎮
          #     command = "${systemctl-toggle}/bin/systemctl-toggle --user abaddon";
          #     active = "${pkgs.systemd}/bin/systemctl is-active --user abaddon";
          #   }
          ] ++ lib.optionals config.sane.programs.gtkcord4.enabled [
            {
              type = "toggle";
              label = "󰊴";  # Discord chat client; icons: 󰊴, 🎮
              command = "${systemctl-toggle}/bin/systemctl-toggle --user gtkcord4";
              active = "${pkgs.systemd}/bin/systemctl is-active --user gtkcord4";
            }
          ] ++ lib.optionals config.sane.programs.signal-desktop.enabled [
            {
              type = "toggle";
              label = "💬";  # Signal messenger; other icons: 󰍦
              command = "${systemctl-toggle}/bin/systemctl-toggle --user signal-desktop";
              active = "${pkgs.systemd}/bin/systemctl is-active --user signal-desktop";
            }
          ] ++ lib.optionals config.sane.programs.dino.enabled [
            {
              type = "toggle";
              label = "XMPP";  # XMPP calls (jingle)
              command = "${systemctl-toggle}/bin/systemctl-toggle --user dino";
              active = "${pkgs.systemd}/bin/systemctl is-active --user dino";
            }
          ] ++ lib.optionals config.sane.programs.fractal.enabled [
            {
              type = "toggle";
              label = "[m]";  # Matrix messages
              command = "${systemctl-toggle}/bin/systemctl-toggle --user fractal";
              active = "${pkgs.systemd}/bin/systemctl is-active --user fractal";
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
          image-size = mprisIconSize;
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
