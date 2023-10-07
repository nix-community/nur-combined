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
#
# outstanding bugs:
# - mic is sometimes disabled at call start despite presenting as enabled
#   - fix is to toggle it off -> on in the Dino UI
# - once per 1-2 minutes dino will temporarily drop mic input:
#   - `rtp-WRNING: plugin.vala:148: Warning in pipeline: Can't record audio fast enough
#   - this was *partially* fixed by bumping the pipewire mic buffer to 2048 samples (from ~512)
#   - that fix can't extend to Dino itself except by patching its code (perhaps)
#   - patching every `info.rate / 100` -> `info.rate / 50` in Dino to double the buffer size *seems* to have no effect
#   - possible the 10ms buffer constant is inside `webrtc` itself
#   - it's using gstreamer, so maybe other ways to introspect that/fix it
#
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
      # note that debug logging during calls produces so much journal spam that it pegs the CPU and causes dropped audio
      # environment.G_MESSAGES_DEBUG = "all";
    };
  };
}
