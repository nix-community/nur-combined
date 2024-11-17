{ config, lib, ... }:
let
  cfg = config.sane.programs.swaylock;
in
{
  sane.programs.swaylock = {
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

    # packageUnwrapped = pkgs.swaylock.overrideAttrs (upstream: {
    #   nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
    #     pkgs.copyDesktopItems
    #   ];
    #   desktopItems = (upstream.desktopItems or []) ++ [
    #     (pkgs.makeDesktopItem {
    #       name = "swaylock";
    #       exec = "swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
    #       desktopName = "Sway session locker";
    #     })
    #   ];
    # });

    sandbox.extraPaths = [
      # N.B.: we need to be able to follow /etc/shadow to wherever it's symlinked.
      # swaylock seems (?) to offload password checking to pam's `unix_chkpwd`,
      # which needs read access to /etc/shadow. that can be either via suid bit (default; incompatible with sandbox)
      # or by making /etc/shadow readable by the user (which is what i do -- check the activationScript)
      "/etc/shadow"
    ];
    sandbox.whitelistWayland = true;

    services.swaylock = {
      description = "swaylock screen locker";
      command = "swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
      restartCondition = "on-failure";
    };
  };

  sane.programs.swayidle.config = lib.mkIf (cfg.enabled && cfg.config.autolock) {
    actions.lock.service = "swaylock";
  };

  security.pam.services = lib.mkIf cfg.enabled {
    swaylock = {};
  };
}
