{ pkgs, ... }:
{
  sane.programs.ps = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "ps";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
