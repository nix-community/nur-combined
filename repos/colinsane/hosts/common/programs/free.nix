{ pkgs, ... }:
{
  sane.programs.free = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "free";
    sandbox.method = "bunpen";
    sandbox.extraPaths = [ "/proc/meminfo" ];
  };
}
