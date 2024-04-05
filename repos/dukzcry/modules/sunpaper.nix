{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.sunpaper;
in {
  options.programs.sunpaper = {
    enable = mkEnableOption "Sunpaper dynamic wallpaper";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nur.repos.dukzcry.sunpaper ];
    environment.pathsToLink = [ "/share/sunpaper" ];
  };
}
