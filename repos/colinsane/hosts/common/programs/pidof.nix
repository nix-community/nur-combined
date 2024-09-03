{ pkgs, ... }:
{
  sane.programs.pidof = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "pidof";
    sandbox.method = "bunpen";
    sandbox.isolatePids = false;
    sandbox.extraPaths = [ "/proc" ];
  };
}
