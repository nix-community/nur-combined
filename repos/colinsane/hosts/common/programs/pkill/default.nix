{ pkgs, ... }:
{
  sane.programs.pkill = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "pkill";
    sandbox.keepPidsAndProc = true;
  };
}
