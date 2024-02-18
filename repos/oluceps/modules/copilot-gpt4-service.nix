{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.copilot-gpt4;
in
{

  options = {
    services.copilot-gpt4 = {
      enable = mkEnableOption (lib.mdDoc "copilot-gpt4");

      package = mkPackageOptionMD pkgs "copilot-gpt4-service" { };

      env = mkOption {
        type = with lib.types; listOf str;
        default = [
          "HOST=0.0.0.0"
          "PORT=8081"
          "CACHE=false"
        ];
      };

    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.copilot-gpt4 = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "copilot-gpt4 daemon";
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "copilot-gpt4";
        ExecStart = "${lib.getExe' cfg.package "copilot-gpt4-service"}";
        Restart = "on-failure";
        Environment = cfg.env;
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ oluceps ];
}
