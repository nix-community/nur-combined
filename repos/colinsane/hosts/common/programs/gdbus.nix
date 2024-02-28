{ pkgs, ... }:
{
  sane.programs.gdbus = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.glib "bin/gdbus";

    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistDbus = [ "user" ];  #< XXX: maybe future users will also want system access
  };
}

