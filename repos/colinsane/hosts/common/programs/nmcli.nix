{ pkgs, ... }:
{
  sane.programs.nmcli = {
    packageUnwrapped = pkgs.networkmanager-split.nmcli;
    sandbox.whitelistDbus.system = true;
  };
}
