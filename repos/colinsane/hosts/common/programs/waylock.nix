# waylock: <https://codeberg.org/ifreund/waylock>
# also documented in berbiche NUR: <https://github.com/nix-community/nur-combined/blob/master/repos/berbiche/README.md>
{ config, lib, ... }:
let
  cfg = config.sane.programs.waylock;
in
{
  sane.programs.waylock = {
    sandbox.extraPaths = [
      # N.B.: we need to be able to follow /etc/shadow to wherever it's symlinked.
      # waylock seems (?) to offload password checking to pam's `unix_chkpwd`,
      # which needs read access to /etc/shadow. that can be either via suid bit (default; incompatible with sandbox)
      # or by making /etc/shadow readable by the user (which is what i do -- check the activationScript)
      "/etc/shadow"
    ];
    sandbox.whitelistWayland = true;
  };

  # without a /etc/pam.d/waylock entry, you may lock but you may never *unlock* ;-)
  security.pam.services = lib.mkIf cfg.enabled {
    waylock.unixAuth = true;
  };
}
