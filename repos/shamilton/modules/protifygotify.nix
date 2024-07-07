{ simplehaproxy }:
{ config, lib, pkgs, specialArgs, options, modulesPath }:
let
  cfg = config.services.protifygotify;
  hostAddress = "192.168.100.14";
  containerAddress = "192.168.100.15";
in
with lib; {
  imports = [ simplehaproxy ];
  options.services.protifygotify = {
    enable = mkEnableOption "";
    port = mkOption {
      type = types.port;
      default = 61694;
      description = "Port for gotify to listen";
    };
  };
  config = mkIf cfg.enable {
    services.simplehaproxy = {
      enable = true;
      proxies.gotifyserver = {
        listenPort = cfg.port;
        backendPort = cfg.port;
        backendAddress = containerAddress;
      };
    };
    containers.gotifyserver = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = hostAddress;
      localAddress = containerAddress;
      config =
        { config, pkgs, ... }:
        {
          services.journald.extraConfig = ''
            SystemMaxUse=20M
          '';
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ cfg.port ];
          };
          services.gotify = {
            enable = true;
            port = cfg.port;
          };
        };
    };
  };
}
