{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gaming;
in {
  options.programs.gaming = {
    enable = mkEnableOption "gaming support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris wine steamPackages.steam-fhsenv-without-steam.run
    ];
    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = true;
  };
}
