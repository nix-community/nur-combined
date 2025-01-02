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
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autolock = mkOption {
          type = types.bool;
          default = true;
          description = ''
            integrate with things like `swayidle` to auto-lock when appropriate.
          '';
        };
      };
    };

    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/schlock/mesa";

    secrets.".config/schlock/schlock.pin" = ../../../secrets/common/schlock.pin.bin;

    services.schlock = {
      description = "schlock mobile-friendly screen locker";
      command = ''schlock -p "''${HOME}/.config/schlock/schlock.pin"'';
      restartCondition = "on-failure";
    };
  };

  sane.programs.swayidle.config = lib.mkIf (cfg.enabled && cfg.config.autolock) {
    actions.lock.service = "schlock";
  };
}
