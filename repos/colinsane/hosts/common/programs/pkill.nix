{ pkgs, ... }:
{
  sane.programs.pkill = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.procps "bin/pkill";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
