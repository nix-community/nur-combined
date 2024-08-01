{ pkgs, ... }:
{
  sane.programs.pkill = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "pkill";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
