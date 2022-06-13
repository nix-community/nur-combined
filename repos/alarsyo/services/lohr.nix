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

  cfg = config.my.services.lohr;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";

  secrets = config.my.secrets;
  lohrPkg = let
    flake = builtins.getFlake "github:alarsyo/lohr?rev=58503cc8b95c8b627f6ae7e56740609e91f323cd";
  in
    flake.defaultPackage."x86_64-linux"; # FIXME: use correct system
in {
  options.my.services.lohr = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Lohr Mirroring Daemon";

    home = mkOption {
      type = types.str;
      default = "/var/lib/lohr";
      example = "/var/lib/lohr";
      description = "Home for the lohr service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Lohr daemon";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lohr = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Environment = [
          "ROCKET_PORT=${toString cfg.port}"
          "ROCKET_LOG_LEVEL=normal"
          "LOHR_HOME=${cfg.home}"
        ];
        EnvironmentFile = config.age.secrets."lohr/shared-secret".path;
        ExecStart = "${lohrPkg}/bin/lohr";
        StateDirectory = "lohr";
        WorkingDirectory = "/var/lib/lohr";
        User = "lohr";
        Group = "lohr";
      };
      path = [
        pkgs.git
        pkgs.openssh
      ];
    };

    users.users.lohr = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "lohr";
    };
    users.groups.lohr = {};

    services.nginx.virtualHosts = {
      "lohr.${domain}" = {
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["lohr.${domain}"];
  };
}
