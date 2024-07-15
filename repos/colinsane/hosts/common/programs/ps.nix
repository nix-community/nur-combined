{ pkgs, ... }:
{
  sane.programs.ps = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.procps "bin/ps";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
