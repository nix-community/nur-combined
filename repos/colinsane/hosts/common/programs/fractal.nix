# Fractal: GTK4 instant messenger client for the Matrix protocol
#
# very susceptible to state corruption during hard power-cycles.
# if it stalls while launching, especially with a brief message at bottom
# "unable to open store"
# then:
# - remove ~/.local/share/stable/*
#   - this might give I/O error, in which case remove the corresponding path under
#     /nix/persist/home/colin/private (which can be found by correlating timestamps/sizes with that in ~/private/.local/share/stable).
# - reboot (maybe necessary).
# - now you can send messages, and read messages in unencrypted rooms, but not read messages from encrypted rooms.
# to fix encrypted message receipt:
# - start from above (fractal closed, no ~/.local/share/stable/*)
# - in ~/.local/share/keyrings/Default_keyring.keyring:
#   - find the entry that says "display-name=Fractal: Matrix credentials for <mxid>"
#   - remove that entry and all associated entries (i.e. ones with same number but different :attributeN)
#   - REBOOT. otherwise keyring stuff seems to stay cached in RAM
#   - login to Fractal. give an hour to sync.
#   - it'll kick you back to a page asking you to cross-sign. open FluffyChat and do the emoji compare. success!
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.fractal;
in
{
  sane.programs.fractal = {
    package = pkgs.fractal-nixified.optimized;
    # package = pkgs.fractal-latest;
    # package = pkgs.fractal-next;

    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    persist.byStore.private = [
      # XXX by default fractal stores its state in ~/.local/share/<build-profile>/<UUID>.
      ".local/share/hack"    # for debug-like builds
      ".local/share/stable"  # for normal releases
      ".local/share/fractal" # for version 5+, i think?
    ];

    suggestedPrograms = [ "gnome-keyring" ];

    services.fractal = {
      description = "auto-start and maintain fractal Matrix connection";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/fractal";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      # environment.G_MESSAGES_DEBUG = "all";
    };
  };
}
