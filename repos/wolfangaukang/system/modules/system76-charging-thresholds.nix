{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkOption;
  cfg = config.services.system76-charging-threshold;
  command = "${lib.getExe pkgs.system76-power} charge-thresholds";

in
{
  options.services.system76-charging-threshold = {
    enable = lib.mkEnableOption (lib.mdDoc "system76 charging threshold");
    profile = mkOption {
      default = "full_charge";
      type = types.str;
      description = ''
        Charging profile to use (check `system76-power charge-thresholds --list-profiles`)
      '';
    };
    thresholds = {
      start = mkOption {
        default = 90;
        type = types.int;
        description = ''
          Battery level where the laptop will avoid charging when dropped below it. It will only work if `custom` profile is set.
        '';
      };
      end = mkOption {
        default = 100;
        type = types.int;
        description = ''
          Battery level where the laptop will stop charging after reaching it. It will only work if `custom` profile is set.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.thresholds.start < cfg.thresholds.end || cfg.hypridle.overrideConfig != "";
        message = "Start threshold must not be higher than the end threshold.";
      }
    ];
    systemd.services."system76-charging-threshold" = {
      description = "Set the charge threshold at startup";
      after = [ "default.target" ];

      script = ''
        [ ${cfg.profile} = 'custom' ] && ${command} ${toString cfg.thresholds.start} ${toString cfg.thresholds.end} || ${command} --profile ${cfg.profile}
      '';
      serviceConfig.Type = "simple";

      wantedBy = [ "default.target" ];
    };
  };
}
