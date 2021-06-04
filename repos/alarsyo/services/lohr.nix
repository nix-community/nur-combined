{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.lohr;
  my = config.my;
  domain = config.networking.domain;
  secrets = config.my.secrets;
  lohrPkg =
    let
      flake = builtins.getFlake "github:alarsyo/lohr?rev=5f7d140b616c4e92318ea09f3438ee2dcc061236";
    in
    flake.defaultPackage."x86_64-linux"; # FIXME: use correct system
in
{
  options.my.services.lohr = {
    enable = lib.mkEnableOption "Lohr Mirroring Daemon";

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
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Environment = [
          "ROCKET_PORT=${toString cfg.port}"
          "ROCKET_LOG_LEVEL=normal"
          "LOHR_HOME=${cfg.home}"
          # NOTE: secret cannot contain a '%', it's interpreted by systemd
          "'LOHR_SECRET=${secrets.lohr-shared-secret}'"
        ];
        ExecStart = "${lohrPkg}/bin/lohr";
        StateDirectory = "lohr";
        WorkingDirectory = "/var/lib/lohr";
        User = "lohr";
        Group = "lohr";
      };
      path = with pkgs; [
        git
      ];
    };

    users.users.lohr = {
      isSystemUser = true;
      home = cfg.home;
      createHome = true;
      group = "lohr";
    };
    users.groups.lohr = { };

    services.nginx.virtualHosts = {
      "lohr.${domain}" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };
  };
}
