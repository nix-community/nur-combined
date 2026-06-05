{ pkgs, ... }:
{
  sane.programs.lddtree = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.pax-utils "lddtree";
    sandbox.autodetectCliPaths = "existingFile";
  };
}
