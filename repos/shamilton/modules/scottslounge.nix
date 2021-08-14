{ config, lib, pkgs, options, modulesPath
, specialArgs}:
with lib;
let
  cfg = config.services.scottslounge;
in {
  options.services.scottslounge = {
    enable = mkEnableOption "Thelounge scott's server";
    port = mkOption {
      type = types.port;
      default = 9000;
      description = "TCP port to listen on for http connections.";
    };
  };
  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
    services.thelounge = {
      enable = true;
      port = cfg.port;
    };
  };
}

