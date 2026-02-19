{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.trgui;
in
{
  options.my.home.trgui = with lib; {
    enable = mkEnableOption "Transmission GUI onfiguration";

    package = mkPackageOption pkgs "TrguiNG" { default = "trgui-ng"; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.package
    ];
  };
}
