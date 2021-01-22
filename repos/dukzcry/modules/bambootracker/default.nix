{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.bambootracker;
in {
  options.programs.bambootracker = {
    enable = mkEnableOption ''
      BambooTracker program
    '';
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [ bambootracker ];
      pathsToLink = [ "/share/BambooTracker" ];
    };
  };
}
