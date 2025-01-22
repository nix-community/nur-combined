{ pkgs, ... }:
{
  sane.programs.captree = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.libcap "captree";
    sandbox.keepPidsAndProc = true;
  };
}
