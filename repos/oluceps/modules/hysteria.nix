{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.hysteria;
in
{
  options.services.hysteria = {
    instances = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            package = mkPackageOption pkgs "hysteria" { };
            credentials = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            serve = mkOption {
              type = types.submodule {
                options = {
                  enable = mkEnableOption (lib.mdDoc "server");
                  port = mkOption { type = types.port; };
                };
              };
              default = {
                enable = false;
                port = 0;
              };
            };
            configFile = mkOption {
              type = types.str;
              default = "/none";
            };
          };
        }
      );
      default = [ ];
    };
  };
  config =
    mkIf (cfg.instances != [ ])

      {

        environment.systemPackages = lib.unique (
          lib.foldr (s: acc: acc ++ [ s.package ]) [ ] cfg.instances
        );

        networking.firewall = (
          lib.foldr (
            s: acc: acc // { allowedUDPPorts = mkIf s.serve.enable [ s.serve.port ]; }
          ) { } cfg.instances
        );

        systemd.services = lib.foldr (
          s: acc:
          acc
          // {
            "hysteria-${s.name}" = {
              wantedBy = [ "multi-user.target" ];
              after = [
                "network-online.target"
                "nss-lookup.target"
              ];
              wants = [ "network-online.target" ];
              description = "hysteria daemon";
              serviceConfig =
                let
                  binSuffix = if s.serve.enable then "server" else "client";
                in
                {
                  DynamicUser = true;
                  ExecStart = "${lib.getExe' s.package "hysteria"} ${binSuffix} --disable-update-check -c $\{CREDENTIALS_DIRECTORY}/config.yaml";
                  LoadCredential = [ "config.yaml:${s.configFile}" ] ++ s.credentials;
                  CapabilityBoundingSet = [
                    "CAP_NET_ADMIN"
                    "CAP_NET_BIND_SERVICE"
                    "CAP_NET_RAW"
                  ];

                  AmbientCapabilities = [
                    "CAP_NET_ADMIN"
                    "CAP_NET_BIND_SERVICE"
                    "CAP_NET_RAW"
                  ];
                  NoNewPrivileges = true;
                  Restart = "on-failure";
                  RestartSec="5s";
                };
            };
          }
        ) { } cfg.instances;
      };
}
