{ lib, pkgs, ... }:

let
  inherit (lib) getExe getExe';
  inherit (pkgs) zstd;
in
{
  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

  services.logrotate.settings.header = {
    compress = true;
    compressext = ".zst";
    compresscmd = getExe zstd;
    compressoptions = "--long";
    uncompresscmd = getExe' zstd "unzstd";
  };
}
