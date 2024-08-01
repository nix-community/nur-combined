{ pkgs, ... }:
{
  sane.programs.free = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "free";
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;
  };
}

