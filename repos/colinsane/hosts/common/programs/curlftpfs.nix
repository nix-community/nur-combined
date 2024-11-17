{ pkgs, ... }:
{
  sane.programs.curlftpfs = {
    packageUnwrapped = pkgs.curlftpfs-sane;
    sandbox.net = "all";
    sandbox.autodetectCliPaths = "existing";
    sandbox.keepPids = true;
    sandbox.extraPaths = [ "/var/log/curlftpfs" ];
  };
}
