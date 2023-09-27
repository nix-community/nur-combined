# notification system, used especially to remotely wake moby
# source: <https://github.com/binwiederhier/ntfy>
# docs: <https://docs.ntfy.sh/>
#
# send a test notification with:
# - `ntfy pub "https://ntfy.uninsane.org/$(cat ~/.config/ntfy-sh/topic)" test`
{ config, lib, ... }:
let
  cfg = config.sane.programs.ntfy-sh;
in
{
  sane.programs.ntfy-sh = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    secrets.".config/ntfy-sh/topic" = ../../../secrets/common/ntfy-sh-topic.bin;

    services.ntfy-sub = {
      description = "listen for push-notifications";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      path = [ cfg.package ];
      script = ''
        topic=$(cat ~/.config/ntfy-sh/topic)
        ntfy sub "https://ntfy.uninsane.org:2587/$topic"
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
    };
  };
}
