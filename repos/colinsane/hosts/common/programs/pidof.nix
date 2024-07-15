{ pkgs, ... }:
{
  sane.programs.pidof = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.procps "bin/pidof";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}
