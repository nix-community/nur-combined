{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.fw-fanctrl;
  settingsFile = pkgs.writeText "config.json" (builtins.toJSON config.services.fw-fanctrl.settings);
  fw-fanctrl = pkgs.fw-fanctrl or pkgs.callPackage ../../pkgs/fw-fanctrl {};
in {
  options.services.fw-fanctrl = with lib; {
    enable = mkEnableOption "fw-fanctrl";
    settings = mkOption {
      type = types.submodule {
        options = {
          defaultStrategy = mkOption {
            type = types.str;
          };
          strategyOnDischarging = lib.mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          batteryChargingStatusPath = mkOption {
            type = types.str;
            default = "/sys/class/power_supply/BAT1/status";
          };
          strategies = mkOption {
            type = types.attrsOf (
              types.submodule
              {
                options = {
                  fanSpeedUpdateFrequency = mkOption {type = types.int;};
                  movingAverageInterval = mkOption {type = types.int;};
                  speedCurve = mkOption {
                    type = types.listOf (types.submodule {
                      options = {
                        temp = mkOption {type = types.int;};
                        speed = mkOption {type = types.int;};
                      };
                    });
                  };
                };
              }
            );
            example = {
              lazy = {
                fanSpeedUpdateFrequency = 5;
                movingAverageInterval = 30;
                speedCurve = [
                  {
                    temp = 0;
                    speed = 15;
                  }
                  {
                    temp = 50;
                    speed = 15;
                  }
                  {
                    temp = 65;
                    speed = 25;
                  }
                  {
                    temp = 70;
                    speed = 35;
                  }
                  {
                    temp = 75;
                    speed = 50;
                  }
                  {
                    temp = 85;
                    speed = 100;
                  }
                ];
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.fw-fanctrl = {
      description = "Framework fan controller.";
      environment = {
        PYTHONUNBUFFERED = "1";
      };

      after = ["multi-user.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${fw-fanctrl}/bin/fanctrl.py --no-log --config ${settingsFile}";
        Type = "simple";
        ExecStopPost = "${pkgs.fw-ectool}/bin/ectool --interface=lpc autofanctrl";
      };
    };
  };
}
