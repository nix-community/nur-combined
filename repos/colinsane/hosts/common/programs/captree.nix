{ pkgs, ... }:
{
  sane.programs.captree = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.libcap-with-captree "captree";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
