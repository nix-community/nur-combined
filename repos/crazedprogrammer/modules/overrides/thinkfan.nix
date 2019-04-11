{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.thinkfan-override;
  configFile = pkgs.writeText "thinkfan.conf" ''
    ${cfg.fan}
    ${cfg.sensors}
    ${cfg.levels}
  '';

in {

  options = {

    services.thinkfan-override = {

      enable = mkOption {
        type = types.bool;
        default = false;
      };

      sensors = mkOption {
        type = types.lines;
        default = ''
          tp_thermal /proc/acpi/ibm/thermal (0,0,10)
        '';
      };

      fan = mkOption {
        type = types.str;
        default = "tp_fan /proc/acpi/ibm/fan";
      };

      levels = mkOption {
        type = types.lines;
        default = ''
          (0,     0,      55)
          (1,     48,     60)
          (2,     50,     61)
          (3,     52,     63)
          (6,     56,     65)
          (7,     60,     85)
          (127,   80,     32767)
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
      };

    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.thinkfan ];

    systemd.services.thinkfan = {
      description = "Thinkfan";
      after = [ "basic.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.thinkfan ];
      serviceConfig.ExecStart = "${pkgs.thinkfan}/bin/thinkfan -n ${toString cfg.extraArgs} -c ${configFile}";
    };

    boot.extraModprobeConfig = "options thinkpad_acpi fan_control=1";

  };

}

