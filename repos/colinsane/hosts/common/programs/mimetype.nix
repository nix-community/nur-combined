{ pkgs, ... }:
{
  sane.programs.mimetype = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.perlPackages.FileMimeInfo "bin/mimetype";
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = "existing";
  };
}
