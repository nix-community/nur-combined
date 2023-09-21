# usage:
# - start a DM with a rando via
#   - '+' -> 'start conversation'
# - add a user to your roster via
#   - '+' -> 'start conversation' -> '+'  (opens the "add contact" dialog)
#   - this triggers a popup on the remote side asking them for confirmation
#   - after the remote's confirmation there will be a local popup for you to allow them to add you to their roster
# - to make a call:
#   - ensure the other party is in your roster
#   - open a DM with the party
#   - click the phone icon at top (only visible if other party is in your roster)
#
# dino can be autostarted on login -- useful to ensure that i always receive calls and notifications --
# but at present it has no "start in tray" type of option: it must render a window.
{ config, lib, ... }:
let
  cfg = config.sane.programs.dino;
in
{
  sane.programs.dino = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    persist.private = [ ".local/share/dino" ];

    services.dino = {
      description = "auto-start and maintain dino XMPP connection";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/dino";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      environment.G_MESSAGES_DEBUG = "all";
    };
  };
}
