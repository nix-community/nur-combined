{ pkgs, ... }:
{
  sane.programs.captree = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.libcap-with-captree "captree";
    sandbox.method = "bunpen";
    sandbox.isolatePids = false;
    sandbox.extraPaths = [ "/proc" ];
  };
}
