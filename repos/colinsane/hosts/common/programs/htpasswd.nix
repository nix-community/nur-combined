{ pkgs, ... }:
{
  sane.programs.htpasswd = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.apacheHttpd "htpasswd";
    sandbox.autodetectCliPaths = "existingFileOrParent";  # for -c; creating passwd files
  };
}
