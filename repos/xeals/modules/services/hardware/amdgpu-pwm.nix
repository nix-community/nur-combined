{ config, lib, ... }:

with lib;

let

  acfg = config.services.amdgpu;
  cfg = config.services.amdgpu.pwm;

in

{
  options.services.amdgpu.pwm = {
    enable = mkEnableOption "amdgpu-pwm";
  };

  config = mkIf cfg.enable {
    systemd.services.amdgpu-pwm = {
      description = "enable manual configuration of AMDGPU fans";
      wantedBy = [ "default.target" ];
      script =
        let
          enablePwm = card: "echo 1 > /sys/class/drm/${card}/device/hwmon/hwmon1/pwm1_enable";
        in
        lib.concatStringsSep "\n" (map enablePwm acfg.cards);
      serviceConfig.Type = "oneshot";
    };
  };
}
