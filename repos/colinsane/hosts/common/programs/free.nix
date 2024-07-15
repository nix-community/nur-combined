{ pkgs, ... }:
{
  sane.programs.free = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.procps "bin/free";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}

