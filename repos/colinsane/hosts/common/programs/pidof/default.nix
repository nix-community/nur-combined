{ pkgs, ... }:
{
  sane.programs.pidof = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "pidof";
    sandbox.keepPidsAndProc = true;
  };
}
