{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    nameValuePair
    mkEnableOption
    mapAttrs'
    optional
    mkIf
    ;
  cfg = config.services.shadow-tls;
in
{
  meta = {
    maintainers = with lib.maintainers; [ oluceps ];
  };

  options.services.shadow-tls = {
    instances = mkOption {
      description = "list of shadow-tls instance";
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "enable this shadow-tls instance";
            package = mkPackageOption pkgs "shadow-tls" { };
            credentials = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                Load extra credentials.
                Could be written as systemd `LoadCredentials` format e.g.
                `["key:/etc/shadow-tls-key"]` and access in config with
                `/run/credentials/shadow-tls-$\{name}.service/key`
              '';
            };
            openFirewall = mkOption {
              type = with types; nullOr port;
              default = null;
              description = "Open firewall port";
            };
            serve = mkEnableOption "using `shadow-tls-server` instead of `shadow-tls-client`";
            configFile = mkOption {
              type = types.str;
              default = "/etc/shadow-tls/server.json";
              description = "Config file location, absolute path";
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf (cfg.instances != { }) {
    environment.systemPackages = lib.unique (
      lib.foldr (s: acc: acc ++ (optional s.enable s.package)) [ ] (builtins.attrValues cfg.instances)
    );

    # only allow udp port since shadow-tls based on tcp
    networking.firewall.allowedTCPPorts = lib.unique (
      lib.foldr (
        s: acc: acc ++ (lib.optional (s.enable && (s.openFirewall != null)) s.openFirewall)
      ) [ ] (builtins.attrValues cfg.instances)
    );

    systemd.services = mapAttrs' (
      name: opts:
      nameValuePair "shadow-tls-${name}" {
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "nss-lookup.target"
        ];
        wants = [
          "network-online.target"
          "nss-lookup.target"
        ];
        description = "shadow-tls daemon";
        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          ExecStart = "${opts.package}/bin/shadow-tls config -c $\{CREDENTIALS_DIRECTORY}/config";
          LoadCredential = [ "config:${opts.configFile}" ] ++ opts.credentials;
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
            "CAP_NET_RAW"
          ];
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
            "CAP_NET_RAW"
          ];
          LimitNPROC = 512;
          LimitNOFILE = "infinity";
          Restart = "always";
        };
      }
    ) (lib.filterAttrs (_: v: v.enable) cfg.instances);
  };
}
