{ pkgs, ... }:
{
  sane.programs.nmcli = {
    packageUnwrapped = pkgs.networkmanager-split.nmcli;
    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [
      "system"
    ];
  };
}
