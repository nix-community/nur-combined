{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    ;

  cfg = config.my.services.transmission;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
  webuiDomain = "transmission.${domain}";

  transmissionRpcPort = 9091;
  transmissionPeerPort = 30251;

  downloadBase = "/media/torrents/";
in {
  options.my.services.transmission = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Transmission torrent client";

    username = mkOption {
      type = types.str;
      default = "alarsyo";
      example = "username";
      description = "Name of the transmission RPC user";
    };

    secretConfigFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/var/run/secrets/transmission-secrets";
      description = "Path to secrets file to append to configuration";
    };
  };

  config = mkIf cfg.enable {
    services.transmission =
      {
        enable = true;
        group = "media";

        settings = {
          download-dir = "${downloadBase}/complete";
          incomplete-dir = "${downloadBase}/incomplete";

          peer-port = transmissionPeerPort;

          rpc-enabled = true;
          rpc-port = transmissionRpcPort;
          rpc-authentication-required = false;

          rpc-whitelist-enabled = true;
          rpc-whitelist = "127.0.0.1";

          rpc-host-whitelist-enabled = true;
          rpc-host-whitelist = webuiDomain;
        };

        # automatically allow transmission.settings.peer-port
        openPeerPorts = true;
      }
      // (optionalAttrs (cfg.secretConfigFile != null) {
        credentialsFile = cfg.secretConfigFile;
      });

    services.nginx.virtualHosts."${webuiDomain}" = {
      forceSSL = true;
      useACMEHost = fqdn;

      locations."/".proxyPass = "http://127.0.0.1:${toString transmissionRpcPort}";

      listen = [
        # FIXME: hardcoded tailscale IP
        {
          addr = "100.115.172.44";
          port = 443;
          ssl = true;
        }
        {
          addr = "100.115.172.44";
          port = 80;
          ssl = false;
        }
      ];
    };

    security.acme.certs.${fqdn}.extraDomainNames = [webuiDomain];
  };
}
