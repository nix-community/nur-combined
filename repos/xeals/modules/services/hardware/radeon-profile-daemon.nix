{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.radeon-profile-daemon;

in

{
  options.services.radeon-profile-daemon = {
    enable = mkEnableOption "radeon-profile-daemon";
  };

  config = mkIf cfg.enable {
    systemd.services = {
      radeon-profile-daemon = {
        description = "radeon-profile daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "enable-manual-amdgpu-fan.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.radeon-profile-daemon}/bin/radeon-profile-daemon";
        };
      };
    };
  };
}
