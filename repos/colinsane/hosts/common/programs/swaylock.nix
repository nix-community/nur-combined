{ config, lib, ... }:
let
  cfg = config.sane.programs.swaylock;
in
{
  sane.programs.swaylock = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraPaths = [
      # N.B.: we need to be able to follow /etc/shadow to wherever it's symlinked.
      # swaylock seems (?) to offload password checking to pam's `unix_chkpwd`,
      # which needs read access to /etc/shadow. that can be either via suid bit (default; incompatible with sandbox)
      # or by making /etc/shadow readable by the user (which is what i do -- check the activationScript)
      "/etc/shadow"
    ];
    sandbox.whitelistWayland = true;
  };

  security.pam.services = lib.mkIf cfg.enabled {
    swaylock = {};
  };
}
