{ pkgs, ... }:
{
  sane.programs.free = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "free";
    sandbox.extraPaths = [ "/proc/meminfo" ];
  };
}
