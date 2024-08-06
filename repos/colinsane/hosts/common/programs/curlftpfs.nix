{ pkgs, ... }:
{
  sane.programs.curlftpfs = {
    packageUnwrapped = pkgs.curlftpfs-sane;
    sandbox.method = "bwrap";
    sandbox.net = "all";
  };
}
