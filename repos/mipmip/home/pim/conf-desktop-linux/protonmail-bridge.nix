{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.protonmail-bridge;
  #Still need to integrate more closely with the email management capabilities of home-manager
in
{
  ##### interface
  options = {
    services.protonmail-bridge = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Bridge.";
      };

      nonInteractive = mkOption {
        type = types.bool;
        default = false;
        description = "Start Bridge entirely noninteractively";
      };

      logLevel = mkOption {
        type = types.enum [ "panic" "fatal" "error" "warn" "info" "debug" "debug-client" "debug-server" ];
        default = "info";
        description = "The log level";
      };

    };
  };

  ##### implementation
  config = mkIf cfg.enable {

    home.packages = [ pkgs.protonmail-bridge ];

    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Protonmail Bridge";
        After = [ "network.target" ];
      };

      Service = {
        Restart = "always";
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --log-level ${cfg.logLevel}" + optionalString (cfg.nonInteractive) " --noninteractive";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
