{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.paperless;
  my = config.my;
  domain = config.networking.domain;
in
{
  options.my.services.paperless = {
    enable = lib.mkEnableOption "Paperless";

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Paperless service";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      "paperless.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;

        listen = [
          # FIXME: hardcoded tailscale IP
          {
            addr = "100.80.61.67";
            port = 443;
            ssl = true;
          }
          {
            addr = "100.80.61.67";
            port = 80;
            ssl = false;
          }
        ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
