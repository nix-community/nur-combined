{ pkgs, ... }:
{
  sane.programs.nmcli = {
    packageUnwrapped = pkgs.networkmanager-split.nmcli;
    sandbox.method = "bunpen";
    sandbox.whitelistDbus = [
      "system"
    ];
  };
}
