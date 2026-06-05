{ ... }:
{
  sane.programs.nix-prefetch-git = {
    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
  };
}
