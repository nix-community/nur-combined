{ pkgs, ... }:
{
  sane.programs.ps = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "ps";
    sandbox.keepPidsAndProc = true;
  };
}
