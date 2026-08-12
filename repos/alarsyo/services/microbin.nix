{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.my.services.microbin;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.microbin = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "MicroBin file sharing app";

    privatePort = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 8080;
      description = "Port to serve the app";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "See NixOS module description";
    };
  };

  config = mkIf cfg.enable {
    services.microbin = {
      enable = true;
      settings = {
        MICROBIN_PORT = cfg.privatePort;
        MICROBIN_BIND = "127.0.0.1";
        MICROBIN_PUBLIC_PATH = "https://drop.${domain}/";
        MICROBIN_READONLY = true;
        MICROBIN_ENABLE_BURN_AFTER = true;
        MICROBIN_ENABLE_READONLY = true;
        MICROBIN_HIGHLIGHTSYNTAX = true;
        MICROBIN_PRIVATE = true;
        MICROBIN_THREADS = 2;
        MICROBIN_GC_DAYS = 0; # turn off GC
        MICROBIN_QR = true;
        MICROBIN_ETERNAL_PASTA = true;
        MICROBIN_DEFAULT_EXPIRY = "1week";
        MICROBIN_DISABLE_TELEMETRY = true;
      };
      passwordFile = cfg.passwordFile;
    };

    my.services.restic-backup = {
      paths = [
        config.services.microbin.dataDir
      ];
    };

    services.nginx = {
      virtualHosts = {
        "drop.${domain}" = {
          forceSSL = true;
          useACMEHost = fqdn;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.privatePort}";
          };
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["drop.${domain}"];
  };
}
