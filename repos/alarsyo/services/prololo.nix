{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.prololo;
  my = config.my;
  domain = config.networking.domain;
  prololoPkg =
    let
      flake = builtins.getFlake "github:prologin/prololo?rev=d7cde3e18a1be9a3a78dca875c542b5d0701b4a5";
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
              "RUST_LOG=rocket=info,prololo=trace"
            ];
            ExecStart = "${prololoPkg}/bin/prololo --config ${configFile}";
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
