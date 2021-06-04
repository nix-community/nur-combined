{ config, lib, ... }:
let
  cfg = config.my.services.transmission;

  domain = config.networking.domain;
  webuiDomain = "transmission.${domain}";

  transmissionRpcPort = 9091;
  transmissionPeerPort = 30251;

  downloadBase = "/media/torrents/";
in
{
  options.my.services.transmission = with lib; {
    enable = mkEnableOption "Transmission torrent client";

    username = mkOption {
      type = types.str;
      default = "alarsyo";
      example = "username";
      description = "Name of the transmission RPC user";
    };

    password = mkOption {
      type = types.str;
      example = "password";
      description = "Password of the transmission RPC user";
    };
  };

  config = lib.mkIf cfg.enable {
    services.transmission = {
      enable = true;
      group = "media";

      settings = {
        download-dir = "${downloadBase}/complete";
        incomplete-dir = "${downloadBase}/incomplete";

        peer-port = transmissionPeerPort;

        rpc-enabled = true;
        rpc-port = transmissionRpcPort;
        rpc-authentication-required = true;

        rpc-username = cfg.username;
        rpc-password = cfg.password;

        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1";
      };

      # automatically allow transmission.settings.peer-port
      openFirewall = true;
    };

    services.nginx.virtualHosts."${webuiDomain}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://127.0.0.1:${toString transmissionRpcPort}";
    };
  };
}
