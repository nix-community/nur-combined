# A nice UI for various torrent clients
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.flood;

  domain = config.networking.domain;
  webuiDomain = "flood.${domain}";
in
{
  options.my.services.flood = with lib; {
    enable = mkEnableOption "Flood UI";

    port = mkOption {
      type = types.port;
      default = 9092;
      example = 3000;
      description = "Internal port for Flood UI";
    };

    stateDir = mkOption {
      type = types.str;
      default = "flood";
      example = "floodUI";
      description = "Directory under `/var/run` for storing Flood's files";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.flood = {
      description = "Flood torrent UI";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.flood}/bin/flood"
          "--port ${builtins.toString cfg.port}"
          "--rundir /var/lib/${cfg.stateDir}"
        ];
        DynamicUser = true;
        StateDirectory = cfg.stateDir;
        ReadWritePaths = "";
      };
    };

    services.nginx.virtualHosts."${webuiDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
    };
  };
}
