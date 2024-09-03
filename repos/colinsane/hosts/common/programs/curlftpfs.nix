{ pkgs, ... }:
{
  sane.programs.curlftpfs = {
    packageUnwrapped = pkgs.curlftpfs-sane;
    sandbox.method = "bunpen";
    sandbox.net = "all";
    sandbox.autodetectCliPaths = "existing";
    sandbox.isolatePids = false;
  };
}
