{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let cfg = config.module.essential.multimedia;
in {
  options.module.essential.multimedia = {
    enable = mkEnableOption "Essential multimedia tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      evince
      imagemagickBig
      jpegoptim
      optipng
      pdftk
      poppler_utils
    ];
  };
}
