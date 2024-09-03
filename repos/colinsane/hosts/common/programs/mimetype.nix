{ pkgs, ... }:
{
  sane.programs.mimetype = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.perlPackages.FileMimeInfo "mimetype";
    sandbox.method = "bunpen";
    sandbox.autodetectCliPaths = "existing";
  };
}
