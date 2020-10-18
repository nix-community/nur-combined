{ config, lib, pkgs, ... }:

with lib;

let

  acfg = config.services.amdgpu;
  cfg = config.services.amdgpu.fan;

in

{
  options.services.amdgpu.fan = {
    enable = mkEnableOption "amdgpu-fan";

    package = mkOption {
      type = types.package;
      default = pkgs.amdgpu-fan or (import ../../.. { inherit pkgs; }).amdgpu-fan;
      defaultText = "pkgs.amdgpu-fan";
    };

    speedMatrix = mkOption {
      type = with types; listOf (listOf int);
      # Translated from upstream default config. Since it tries to write the
      # config if it's not found, we want some kind of default.
      default = [
        [ 0 0 ]
        [ 30 33 ]
        [ 45 50 ]
        [ 60 66 ]
        [ 65 69 ]
        [ 70 75 ]
        [ 75 89 ]
        [ 80 100 ]
      ];
      example = literalExample ''
        [
          [ 0 0 ]
          [ 40 30 ]
          [ 60 50 ]
          [ 80 100 ]
        ]
      '';
      description = ''
        A list of temperature-fan speed pairs. The temperature is specified in
        degrees celcius, and speed is specified in %.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = all (speeds: length speeds == 2) cfg.speedMatrix;
      message = "services.amdgpu.fan.speedMatrix must be a list of paired lists";
    };

    environment.etc."amdgpu-fan.yml".text = builtins.toJSON {
      speed_matrix = cfg.speedMatrix;
      cards = acfg.cards;
    };

    powerManagement.resumeCommands = "${pkgs.systemd}/bin/systemctl try-restart amdgpu-fan";

    # Translated from the upstream service file.
    systemd.services = {
      amdgpu-fan = {
        description = "amdgpu fan controller";
        wantedBy = [ "default.target" ];
        after = [ "amdgpu-pwm.service" ];
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/amdgpu-fan";
          Restart = "always";
        };
      };
    };
  };
}
