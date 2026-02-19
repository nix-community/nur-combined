{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.calibre;
in
{
  options.my.home.calibre = with lib; {
    enable = mkEnableOption "calibre configuration";

    package = mkPackageOption pkgs "calibre" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.package
    ];
  };
}
