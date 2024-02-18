{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.juicity;
in
{
  disabledModules = [ "services/networking/juicity.nix" ];
  options.services.juicity = {
    instances = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption { type = types.str; };
          package = mkPackageOption pkgs "juicity" { };
          credentials = mkOption { type = types.listOf types.str; default = [ ]; };
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
      });
      default = [ ];
    };
  };

  config =
    mkIf (cfg.instances != [ ])
      {

        environment.systemPackages = lib.unique (lib.foldr
          (s: acc: acc ++ [ s.package ]) [ ]
          cfg.instances);


        networking.firewall =
          (lib.foldr
            (s: acc: acc // {
              allowedUDPPorts = mkIf s.serve.enable [ s.serve.port ];
            })
            { }
            cfg.instances);

        systemd.services = lib.foldr
          (s: acc: acc // {
            "juicity-${s.name}" = {
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              description = "juicity daemon";
              serviceConfig =
                let binSuffix = if s.serve.enable then "server" else "client"; in {
                  Type = "simple";
                  DynamicUser = true;
                  ExecStart = "${s.package}/bin/juicity-${binSuffix} run -c $\{CREDENTIALS_DIRECTORY}/config";
                  LoadCredential = [ "config:${s.configFile}" ] ++ s.credentials;
                  AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
                  Restart = "on-failure";
                };
            };
          })
          { }
          cfg.instances;
      };
}
