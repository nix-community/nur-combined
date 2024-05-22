{ pkgs, ... }:

let
  inherit (pkgs) zstd;
in
{
  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

  services.logrotate.settings.header = {
    compress = true;
    compressext = ".zst";
    compresscmd = "${zstd}/bin/zstd";
    compressoptions = "--long";
    uncompresscmd = "${zstd}/bin/unzstd";
  };
}
