{ simplehaproxy, rpi-fan-serve }:
{ config, lib, pkgs, specialArgs, options, modulesPath }:
let
  cfg = config.services.rpi-fan-serve;
  hostAddress = "192.168.100.18";
  containerAddress = "192.168.100.19";
  containerLogsDir = "/logs";
  containerSocketsDir = "/run/rpi-fan-serve";
  hostSocketsDir = "/run/rpi-fan-serve";
in
with lib; {
  imports = [ simplehaproxy ];
  options.services.rpi-fan-serve = {
    enable = mkEnableOption "";
    port = mkOption {
      type = types.port;
      default = 8085;
      description = "Port for rpi-fan-serve to listen";
    };
    logBaseFileDir = mkOption {
      type = types.str;
      example = "/var/log/rpi-fan";
      description = "The directory where the base log file to analyze and serve is";
    };
    logBaseFileName = mkOption {
      type = types.str;
      example = "rpi-fan.log";
      description = "The filename of the base log file to analyze and serve";
    };
    maxJobs = mkOption {
      type = types.ints.unsigned;
      default = 4;
      description = "Max number of threads to use";
    };
  };
  config = mkIf cfg.enable {
    services.dbus.packages = [ rpi-fan-serve ];
    users.groups.rpi-fan-serve = {};
    environment.systemPackages = [ rpi-fan-serve ];
    services.simplehaproxy = {
      enable = true;
      proxies.rpi-fan-serve = {
        listenPort = cfg.port;
        backendPort = cfg.port;
        backendAddress = containerAddress;
      };
    };
    containers.rpi-fan-serve = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = hostAddress;
      localAddress = containerAddress;
      bindMounts = {
        "${containerLogsDir}" = {
          hostPath = cfg.logBaseFileDir;
        };
        "${containerSocketsDir}" = {
          hostPath = hostSocketsDir;
          forceHostPath = true;
          isReadOnly = false;
        };
      };
      config =
        { config, pkgs, ... }:
        {
          system.stateVersion = "24.05";
          services.journald.extraConfig = ''
            SystemMaxUse=20M
          '';
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ cfg.port ];
          };
          systemd.services.rpi-fan-serve = {
            description = "A web service to access rpi-fan data";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${rpi-fan-serve}/bin/rpi-fan-serve -p ${toString cfg.port} -l ${containerLogsDir}/${cfg.logBaseFileName} -j ${toString cfg.maxJobs}";
            };
          };
        };
    };
  };
}
