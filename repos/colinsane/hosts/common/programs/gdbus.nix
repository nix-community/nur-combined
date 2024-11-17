{ pkgs, ... }:
{
  sane.programs.gdbus = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.glib "gdbus";

    sandbox.whitelistDbus = [ "user" ];  #< XXX: maybe future users will also want system access
  };
}
