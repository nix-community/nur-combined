{ config, lib, ... }:
let
  cfg = config.my.home.libreoffice;
in
{
  options.my.home.libreoffice = with lib; {
    enable = mkEnableOption "LibreOffice configuration";

    package = mkPackageOption pkgs "libreoffice" { };
  };

  config = lib.mkIf cfg.enable {
    programs.libreoffice = {
      enable = true;

      inherit (cfg) package;
    };
  };
}
