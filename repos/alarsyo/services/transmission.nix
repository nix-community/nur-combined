{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
  ;

  cfg = config.my.services.transmission;

  domain = config.networking.domain;
  webuiDomain = "transmission.${domain}";

  transmissionRpcPort = 9091;
  transmissionPeerPort = 30251;

  downloadBase = "/media/torrents/";
in
{
  options.my.services.transmission = let inherit (lib) types; in {
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

  config = mkIf cfg.enable {
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
      useACMEHost = domain;

      locations."/".proxyPass = "http://127.0.0.1:${toString transmissionRpcPort}";
    };
  };
}
