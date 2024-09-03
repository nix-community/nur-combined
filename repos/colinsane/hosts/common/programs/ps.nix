{ pkgs, ... }:
{
  sane.programs.ps = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "ps";
    sandbox.method = "bunpen";
    sandbox.isolatePids = false;
    sandbox.extraPaths = [ "/proc" ];
  };
}
