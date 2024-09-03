{ pkgs, ... }:
{
  sane.programs.pkill = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "pkill";
    sandbox.method = "bunpen";
    sandbox.isolatePids = false;
    sandbox.extraPaths = [ "/proc" ];
  };
}
