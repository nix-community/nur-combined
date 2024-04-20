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
      # https://github.com/lutris/lutris/issues/5121
      wine wine64
      lutris steamPackages.steam-fhsenv-without-steam.run
    ];
    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = true;
  };
}
