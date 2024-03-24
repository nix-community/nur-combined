{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.swaylock;
in
{
  sane.programs.swaylock = {
    packageUnwrapped = pkgs.swaylock.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.copyDesktopItems
      ];
      desktopItems = (upstream.desktopItems or []) ++ [
        (pkgs.makeDesktopItem {
          name = "swaylock";
          exec = "swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
          desktopName = "Sway session locker";
        })
      ];
    });

    sandbox.method = "bwrap";
    sandbox.extraPaths = [
      # N.B.: we need to be able to follow /etc/shadow to wherever it's symlinked.
      # swaylock seems (?) to offload password checking to pam's `unix_chkpwd`,
      # which needs read access to /etc/shadow. that can be either via suid bit (default; incompatible with sandbox)
      # or by making /etc/shadow readable by the user (which is what i do -- check the activationScript)
      "/etc/shadow"
    ];
    sandbox.whitelistWayland = true;
  };

  sane.programs.swayidle.config = lib.mkIf cfg.enabled {
    actions.swaylock.desktop = "swaylock.desktop";
    actions.swaylock.delay = 1800;
  };

  security.pam.services = lib.mkIf cfg.enabled {
    swaylock = {};
  };
}
