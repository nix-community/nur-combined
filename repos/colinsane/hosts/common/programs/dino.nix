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
# - default mic gain is WAY TOO MUCH (heavily distorted)
# - TODO: dino should have more optimal niceness/priority to ensure it can process its buffers
#   - possibly this is solved by enabling RealtimeKit (rtkit)
# - TODO: see if Dino calls work better with `echo full > /sys/kernel/debug/sched/preempt`
#
# probably fixed:
# - once per 1-2 minutes dino will temporarily drop mic input:
#   - `rtp-WRNING: plugin.vala:148: Warning in pipeline: Can't record audio fast enough
#   - this was *partially* fixed by bumping the pipewire mic buffer to 2048 samples (from ~512)
#   - this was further fixed by setting PULSE_LATENCY_MSEC=20.
#   - possibly Dino should be updated internally: `info.rate / 100` -> `info.rate / 50`.
#     - i think that affects the batching for echo cancellation, adaptive gain control, etc.
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
          default = true;
        };
      };
    };

    persist.byStore.private = [ ".local/share/dino" ];

    services.dino = {
      description = "dino XMPP client";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/dino";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };

      # audio buffering; see: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/FAQ#pipewire-buffering-explained>
      # dino defaults to 10ms mic buffer, which causes underruns, which Dino handles *very* poorly
      # as in, the other end of the call will just not receive sound from us for a couple seconds.
      # pipewire uses power-of-two buffering for the mic itself. that would put us at 21.33 ms, but this env var supports only whole numbers (21ms ends up not power-of-two).
      # also, Dino's likely still doing things in 10ms batches internally anyway.
      environment.PULSE_LATENCY_MSEC = "20";

      # note that debug logging during calls produces so much journal spam that it pegs the CPU and causes dropped audio
      # environment.G_MESSAGES_DEBUG = "all";
    };
  };
}
