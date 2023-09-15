{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.feedbackd;
in
{
  sane.programs.feedbackd = {
    package = pkgs.rmDbusServices pkgs.feedbackd;

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

    # N.B.: feedbackd will load ~/.config/feedbackd/themes/default.json by default
    # - but using that would forbid `parent-theme = "default"`
    fs.".config/feedbackd/themes/proxied.json".symlink.text = builtins.toJSON {
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
          ];
        }
      ];
    };

    services.feedbackd = {
      description = "feedbackd audio/vibration/led controller";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/libexec/feedbackd";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      environment = lib.mkIf cfg.config.proxied {
        FEEDBACK_THEME = "/home/colin/.config/feedbackd/themes/proxied.json";
      };
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
