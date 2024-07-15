# test with e.g.
# - `fbcli --event proxied-message-new-instant`

{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.feedbackd;
in
{
  sane.programs.feedbackd = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.feedbackd;

    configOption = with lib; mkOption {
      type = types.submodule {
        options.proxied = mkOption {
          type = types.bool;
          default = false;
          description = ''
          whether to use a sound theme in which common application events are muted
          with the intent that a proxy (notification daemon) with knowledge of this
          modification will "speak" on behalf of all applications.
          '';
        };
      };
      default = {};
    };

    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [ "user" ];
    sandbox.whitelistAudio = true;

    # N.B.: feedbackd will load ~/.config/feedbackd/themes/default.json by default
    # - but using that would forbid `parent-theme = "default"`
    # the default theme ships support for these events:
    # - alarm-clock-elapsed
    # - battery-caution
    # - bell-terminal
    # - button-pressed
    # - button-released
    # - camera-focus
    # - camera-shutter
    # - message-missed-email
    # - message-missed-instant
    # - message-missed-notification
    # - message-missed-sms
    # - message-new-email
    # - message-new-instant
    # - message-new-sms
    # - message-sent-instant
    # - phone-failure
    # - phone-hangup
    # - phone-incoming-call
    # - phone-missed-call
    # - phone-outgoing-busy
    # - screen-capture
    # - theme-demo
    # - timeout-completed
    # - window-close
    fs.".config/feedbackd/themes/proxied.json".symlink.target = pkgs.writers.writeJSON "proxied.json" {
      name = "proxied";
      parent-theme = "default";
      profiles = [
        {
          name = "full";
          feedbacks = [
            # forcibly disable normal events which we'd prefer for the notification daemon (e.g. swaync) to handle
            {
              event-name = "message-new-instant";
              type = "Dummy";
            }
            {
              event-name = "proxied-message-new-instant";
              type = "Sound";
              effect = "message-new-instant";
            }
            # re-define sounds from the default theme which we'd like to pass through w/o proxying.
            # i guess this means i'm not inheriting the default theme :|
            {
              event-name = "phone-incoming-call";
              type = "Sound";
              effect = "phone-incoming-call";
            }
            {
              event-name = "alarm-clock-elapsed";
              type = "Sound";
              effect = "alarm-clock-elapsed";
            }
            {
              event-name = "timeout-completed";
              type = "Sound";
              effect = "complete";
            }
          ];
        }
      ];
    };

    services.feedbackd = {
      description = "feedbackd audio/vibration/led controller";
      depends = [ "sound" ];
      partOf = [ "default" ];
      command = lib.concatStringsSep " " ([
        "env"
        "G_MESSAGES_DEBUG=all"
      ] ++ lib.optionals cfg.config.proxied [
        "FEEDBACK_THEME=$HOME/.config/feedbackd/themes/proxied.json"
      ] ++ [
        "${cfg.package}/libexec/feedbackd"
      ]);
    };
  };

  services.udev.packages = lib.mkIf cfg.enabled [
    # ships udev rules for `feedbackd` group to be able to control vibrator and LEDs
    cfg.package
  ];
  users.groups = lib.mkIf cfg.enabled {
    feedbackd = {};
  };
}
