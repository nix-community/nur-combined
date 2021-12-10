{ config, lib, pkgs, ... }:

with lib;
let
  nur = import ../.. { inherit pkgs; };
  cfg = config.hardware.argonone;
in {
  options.hardware.argonone = {
    enable = mkEnableOption "the driver for Argon One Raspberry Pi case fan and power button";
    package = mkOption {
      type = types.package;
      default = nur.argononed;
      defaultText = "nur.argononed";
      description = ''
        The package implementing the Argon One driver
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.i2c.enable = true;
    hardware.deviceTree.overlays = [
      {
        name = "argononed";
        dtboFile = "${cfg.package}/boot/overlays/argonone.dtbo";
      }
      # Seems to be absolutely needed for pi4
      {
          name = "i2c0";
          dtsText = ''
    /dts-v1/;
          /plugin/;
          /{
              compatible = "raspberrypi,4-model-b";
              fragment@1 {
                  target = <&i2c1>;
                  __overlay__ {
                      status = "okay";
                  };
              };
          };
          '';
      }
    ];
    environment.systemPackages = [ cfg.package ];
    systemd.services.argononed = {
      description = "Argon One Fan and Button Daemon Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${cfg.package}/bin/argononed";
        PIDFile = "/run/argononed.pid";
        Restart = "on-failure";
      };
    };
  };

}
