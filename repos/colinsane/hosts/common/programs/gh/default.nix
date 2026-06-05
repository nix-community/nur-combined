# first-time setup:
# 1. `gh auth` ...
# 2. `cd ~/nixpkgs; gh repo set-default` ...
{ ... }:
{
  sane.programs.gh = {
    # MS GitHub stores auth token in .config
    # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
    persist.byStore.private = [ ".config/gh" ];
    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
    sandbox.whitelistPortal = [
      "OpenURI"  # for auth
    ];
  };
}

