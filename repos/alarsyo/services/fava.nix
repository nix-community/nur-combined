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

  cfg = config.my.services.fava;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";

  secrets = config.my.secrets;
in {
  options.my.services.fava = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Fava";

    home = mkOption {
      type = types.str;
      default = "/var/lib/fava";
      example = "/var/lib/fava";
      description = "Home for the fava service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Fava";
    };

    filePath = mkOption {
      type = types.str;
      example = "my_dir/money.beancount";
      description = "File to load in Fava";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.fava = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Environment = [];
        ExecStart = "${pkgs.fava}/bin/fava -H 127.0.0.1 -p ${toString cfg.port} ${cfg.home}/${cfg.filePath}";
        WorkingDirectory = cfg.home;
        User = "fava";
        Group = "fava";
      };
    };

    users.users.fava = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "fava";
    };
    users.groups.fava = {};

    services.nginx.virtualHosts = {
      "fava.${domain}" = {
        forceSSL = true;
        useACMEHost = fqdn;

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
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["fava.${domain}"];
  };
}
