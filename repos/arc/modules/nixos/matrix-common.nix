{ lib, pkgs }: with lib; {
  registrationModule = { config, options, name, ... }: {
    options = {
      id = mkOption {
        type = types.str;
        default = name;
      };
      token = {
        homeserver = mkOption {
          type = types.str;
        };
        appservice = mkOption {
          type = types.str;
        };
      };
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      port = mkOption {
        type = types.port;
      };
      url = mkOption {
        type = types.str;
        default = "http://${config.host}:${toString config.port}";
      };
      senderLocalpart = mkOption {
        type = types.str;
      };
      rateLimited = mkOption {
        type = types.bool;
        default = false;
      };
      pushEphemeral = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      protocols = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      namespaces = let
        namespaceMatch = { config, ... }: {
          options = {
            exclusive = mkOption {
              type = types.bool;
              default = true;
            };
            regex = mkOption {
              type = types.str;
            };
            groupId = mkOption {
              type = with types; nullOr str;
              default = null;
            };
            out.json = mkOption {
              type = types.unspecified;
            };
          };
          config.out.json = {
            inherit (config) exclusive regex;
          } // optionalAttrs (config.groupId != null) {
            group_id = config.groupId;
          };
        };
      in {
        users = mkOption {
          type = with types; listOf (submodule namespaceMatch);
          default = [ ];
        };
        aliases = mkOption {
          type = with types; listOf (submodule namespaceMatch);
          default = [ ];
        };
        rooms = mkOption {
          type = with types; listOf (submodule namespaceMatch);
          default = [ ];
        };
      };
      configuration = mkOption {
        type = sensitive.type;
      };
      set = mkOption {
        type = types.unspecified;
      };
    };
    config = {
      configuration = {
        name = mkDefault name;
        format = "yaml";
        settings = {
          inherit (config) id;
          inherit (config) url protocols;
          rate_limited = config.rateLimited;
          sender_localpart = config.senderLocalpart;
          namespaces = mapAttrs (_: ns: map (ns: {
            inherit (ns) exclusive regex;
          }) ns) config.namespaces;
        } // optionalAttrs (config.pushEphemeral != null) {
          "de.sorunome.msc2409.push_ephemeral" = config.pushEphemeral;
          push_ephemeral = config.pushEphemeral;
        };
        sensitiveSettings = {
          hs_token = config.token.homeserver;
          as_token = config.token.appservice;
        };
        _module.args = {
          inherit pkgs;
        };
      };
      set = {
        token = {
          homeserver = mkIf (options.token.homeserver.isDefined) (mkDefault config.token.homeserver);
          appservice = mkIf (options.token.homeserver.isDefined) (mkDefault config.token.appservice);
        };
        host = mkDefault config.host;
        port = mkDefault config.port;
        senderLocalpart = mkDefault config.senderLocalpart;
        rateLimited = mkDefault config.rateLimited;
        protocols = mkDefault config.protocols;
        namespaces = let
          mapns = ns: mkDefault (map (ns: ns.out.json) ns);
        in {
          users = mapns config.namespaces.users;
          aliases = mapns config.namespaces.aliases;
          rooms = mapns config.namespaces.rooms;
        };
      } // optionalAttrs options.id.isDefined {
        id = mkDefault config.id;
      } // optionalAttrs config.configuration.hasSensitive {
        configuration.sensitivePath = mkDefault config.configuration.sensitivePath;
      };
    };
  };
}
