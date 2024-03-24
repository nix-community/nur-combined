# limitations:
# - schlock fails open (pkill it and the wayland session is left unprotected)
# - schlock does not accept keyboard input; hence, unusable without a touchscreen
# - pin is not synchronized with PAM.
#   - generate a hashed pin with: `mkpin`
# - does not seem to render in landscape mode

{ config, lib, ... }:
let
  cfg = config.sane.programs.schlock;
in
{
  sane.programs.schlock = {
    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;

    secrets.".config/schlock/schlock.pin" = ../../../secrets/common/schlock.pin.bin;
  };

  sane.programs.swayidle.config = lib.mkIf cfg.enabled {
    actions.schlock.desktop = "schlock.desktop";
    actions.schlock.delay = 1800;
  };
}
