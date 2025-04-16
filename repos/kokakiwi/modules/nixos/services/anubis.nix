{ config, pkgs, lib, ... }:
let
  cfg = config.services.anubis;

  json = pkgs.formats.json { };
in {
  options.services.anubis = with lib; {
    package = mkPackageOption pkgs "anubis" { };

    servers = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enable = mkEnableOption "anubis server - ${name}" // { default = true; };

          target = mkOption {
            type = types.str;
          };

          persistentKey = mkOption {
            type = types.bool;
            default = false;
          };

          botPolicies = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                action = mkOption {
                  type = types.enum [ "ALLOW" "DENY" "CHALLENGE" ];
                };

                userAgentRegex = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                pathRegex = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                remoteAddresses = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };

                challenge = {
                  difficulty = mkOption {
                    type = types.nullOr types.ints.unsigned;
                    default = null;
                  };
                  reportAs = mkOption {
                    type = types.nullOr types.ints.unsigned;
                    default = null;
                  };
                  algorithm = mkOption {
                    type = types.nullOr (types.enum [ "fast" "slow" ]);
                    default = null;
                  };
                };
              };
            });
            default = { };
          };

          environment = mkOption {
            type = types.attrsOf types.str;
            default = { };
          };
          environmentFile = mkOption {
            type = types.nullOr types.path;
            default = null;
          };

          extraGroups = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };

        config = {
          environment = {
            BIND_NETWORK = mkDefault "unix";
            BIND = mkDefault "/run/anubis/${name}/anubis.sock";

            METRICS_BIND_NETWORK = mkDefault "unix";
            METRICS_BIND = mkDefault "/run/anubis/${name}/metrics.sock";

            SOCKET_MODE = mkDefault "0776";
          };
        };
      }));
      default = { };
    };
  };

  config = {
    systemd.services = lib.mapAttrs' (name: server: let
      policy = lib.mapAttrsToList (name: policy: lib.filterAttrs (_: value: value != null) {
        inherit name;
        inherit (policy) action;

        user_agent_regex = policy.userAgentRegex;
        path_regex = policy.pathRegex;
        remote_addresses = policy.remoteAddresses;

        challenge = lib.filterAttrs (_: value: value != null) {
          inherit (policy.challenge) difficulty algorithm;
          report_as = policy.challenge.reportAs;
        };
      }) server.botPolicies;
      policyFile = json.generate "botPolicies-${name}.json" {
        bots = policy;
      };
    in lib.nameValuePair "anubis-${name}" {
      description = "anubis - ${name}";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = server.environment
      // {
        TARGET = server.target;
      }
      // lib.optionalAttrs (server.botPolicies != { }) {
        POLICY_FNAME = toString policyFile;
      }
      // lib.optionalAttrs server.persistentKey {
        ED25519_PRIVATE_KEY_HEX_FILE = "%S/anubis/${name}/private-key";
      };

      preStart = lib.mkIf server.persistentKey ''
        if [[ ! -f "$ED25519_PRIVATE_KEY_HEX_FILE" ]]; then
          ${pkgs.openssl}/bin/openssl rand -hex 32 >"$ED25519_PRIVATE_KEY_HEX_FILE"
          chmod 0600 "$ED25519_PRIVATE_KEY_HEX_FILE"
        fi
      '';

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;

        DynamicUser = "yes";
        SupplementaryGroups = server.extraGroups;

        Restart = "always";
        RestartSec = "30s";

        LimitNOFILE = "infinity";

        RuntimeDirectory = "anubis/${name}";
        RuntimeDirectoryMode = "0755";
      }
      // lib.optionalAttrs (server.environmentFile != null) {
        EnvironmentFile = server.environmentFile;
      }
      // lib.optionalAttrs server.persistentKey {
        StateDirectory = "anubis/${name}";
      };
    }) (lib.filterAttrs (name: server: server.enable) cfg.servers);
  };
}
