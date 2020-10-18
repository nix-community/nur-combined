{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.radeon-profile-daemon;

in

{
  options.services.radeon-profile-daemon = {
    enable = mkEnableOption "radeon-profile-daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.radeon-profile-daemon or (import ../../.. { inherit pkgs; }).radeon-profile-daemon;
      defaultText = "pkgs.radeon-profile-daemon";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      radeon-profile-daemon = {
        description = "radeon-profile daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "amdgpu-pwm.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${package}/bin/radeon-profile-daemon";
        };
      };
    };
  };
}
