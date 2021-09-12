{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.prololo;
  my = config.my;
  domain = config.networking.domain;
  prololoPkg =
    let
      flake = builtins.getFlake "github:alarsyo/prololo-reborn?rev=40da010f5782bc760c83ac9883716970fcee40ff";
    in
      flake.defaultPackage."x86_64-linux"; # FIXME: use correct system
  settingsFormat = pkgs.formats.yaml {};
in
{
  options.my.services.prololo = {
    enable = lib.mkEnableOption "Prololo Matrix bot";

    home = mkOption {
      type = types.str;
      default = "/var/lib/prololo";
      example = "/var/lib/prololo";
      description = "Home for the prololo service, where data will be stored";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Prololo Rocket server";
    };

    settings = mkOption {
      type = settingsFormat.type;
      default = {};
    };
  };

  config =
    let
      configFile = settingsFormat.generate "config.yaml" cfg.settings;
    in mkIf cfg.enable
      {
        systemd.services.prololo = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Environment = [
              "ROCKET_PORT=${toString cfg.port}"
              "ROCKET_LOG_LEVEL=normal"
              "RUST_LOG=rocket=info,prololo_reborn=trace"
            ];
            ExecStart = "${prololoPkg}/bin/prololo-reborn --config ${configFile}";
            StateDirectory = "prololo";
            WorkingDirectory = cfg.home;
            User = "prololo";
            Group = "prololo";
          };
        };

        users.users.prololo = {
          isSystemUser = true;
          home = cfg.home;
          createHome = true;
          group = "prololo";
        };
        users.groups.prololo = { };

        services.nginx.virtualHosts = {
          "prololo.${domain}" = {
            forceSSL = true;
            useACMEHost = domain;

            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.port}";
            };
          };
        };
      };
}
