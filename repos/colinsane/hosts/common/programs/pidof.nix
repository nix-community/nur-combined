{ pkgs, ... }:
{
  sane.programs.pidof = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "pidof";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
