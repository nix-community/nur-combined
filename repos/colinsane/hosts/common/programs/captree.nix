{ pkgs, ... }:
{
  sane.programs.captree = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.libcap-with-captree "captree";
    sandbox.keepPidsAndProc = true;
  };
}
