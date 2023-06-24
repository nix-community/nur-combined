{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.calibre;
in
{
  options.my.home.calibre = with lib; {
    enable = mkEnableOption "calibre configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      calibre # NOTE: relies on my overlay to add necessary plug-in dependencies
    ];
  };
}
