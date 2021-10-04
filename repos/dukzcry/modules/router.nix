{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.router;
in {
  options.services.router = {
    enable = mkEnableOption ''
      Router support
    '';
  };

  config = mkIf cfg.enable {
    fileSystems."/data" = {
      device = "robocat:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };
    environment = {
      systemPackages = with pkgs; [
        picocom        
      ];
    };
  };
}
