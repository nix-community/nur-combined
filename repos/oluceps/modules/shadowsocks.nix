{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.shadowsocks;
in
{
  disabledModules = [ "services/networking/shadowsocks.nix" ];
  options.services.shadowsocks = {
    instances = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            package = mkPackageOption pkgs "shadowsocks-rust" { };
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
            openPort = mkOption { type = types.port; };
          };
        }
      );
      default = [ ];
    };
  };

  config = mkIf (cfg.instances != [ ]) {

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
        "shadowsocks-${s.name}" = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          description = "shadowsocks-rust";
          serviceConfig =
            let
              binSuffix = if s.serve.enable then "server" else "local";
            in
            {
              Type = "simple";
              DynamicUser = true;
              LoadCredential = [ "config:${s.configFile}" ] ++ s.credentials;
              ExecStart = "${s.package}/bin/ss${binSuffix} -c $\{CREDENTIALS_DIRECTORY}/config";
              AmbientCapabilities = [
                "CAP_NET_ADMIN"
                "CAP_NET_BIND_SERVICE"
              ];
              Restart = "on-failure";
            };
        };
      }
    ) { } cfg.instances;
  };
}
