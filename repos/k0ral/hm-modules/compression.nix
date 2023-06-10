{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let cfg = config.module.utilities.compression;
in
{
  options.module.utilities.compression = {
    enable = mkEnableOption "Archiving & compression tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ libarchive ouch p7zip unrar unzip zip ];
  };
}
