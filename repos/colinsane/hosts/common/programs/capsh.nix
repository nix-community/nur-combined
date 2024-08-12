{ pkgs, ... }:
{
  sane.programs.capsh = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.libcap "capsh";
    sandbox.enable = false;  #< i use `capsh` as a sandboxer.
  };
}
