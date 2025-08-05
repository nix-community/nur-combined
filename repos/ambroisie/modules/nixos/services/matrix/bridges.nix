# Matrix bridges for some services I use
{ config, lib, ... }:
let
  cfg = config.my.services.matrix.bridges;
  synapseCfg = config.services.matrix-synapse;

  domain = config.networking.domain;
  serverName = synapseCfg.settings.server_name;

  mkBridgeOption = n: lib.mkEnableOption "${n} bridge" // { default = cfg.enable; };
  mkPortOption = n: default: lib.mkOption {
    type = lib.types.port;
    inherit default;
    example = 8080;
    description = "${n} bridge port";
  };
  mkEnvironmentFileOption = n: lib.mkOption {
    type = lib.types.str;
    example = "/run/secret/matrix/${lib.toLower n}-bridge-secrets.env";
    description = ''
      Path to a file which should contain the secret values for ${n} bridge.

      Using through the following format:

      ```
      MATRIX_APPSERVICE_AS_TOKEN=<the_as_value>
      MATRIX_APPSERVICE_HS_TOKEN=<the_hs_value>
      ```

      Each bridge should use a different set of secrets, as they each register
      their own independent double-puppetting appservice.
    '';
  };
in
{
  options.my.services.matrix.bridges = with lib; {
    enable = mkEnableOption "bridges configuration";

    admin = mkOption {
      type = types.str;
      default = "ambroisie";
      example = "admin";
      description = "Local username for the admin";
    };

    facebook = {
      enable = mkBridgeOption "Facebook";

      port = mkPortOption "Facebook" 29321;

      environmentFile = mkEnvironmentFileOption "Facebook";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.facebook.enable {
      services.mautrix-meta.instances.facebook = {
        enable = true;
        # Automatically register the bridge with synapse
        registerToSynapse = true;

        # Provide `AS_TOKEN`, `HS_TOKEN`
        inherit (cfg.facebook) environmentFile;

        settings = {
          homeserver = {
            domain = serverName;
            address = "http://localhost:${toString config.my.services.matrix.port}";
          };

          appservice = {
            hostname = "localhost";
            inherit (cfg.facebook) port;
            address = "http://localhost:${toString cfg.facebook.port}";
            public_address = "https://facebook-bridge.${domain}";

            as_token = "$MATRIX_APPSERVICE_AS_TOKEN";
            hs_token = "$MATRIX_APPSERVICE_HS_TOKEN";

            bot = {
              username = "fbbot";
            };
          };

          backfill = {
            enabled = true;
          };

          bridge = {
            delivery_receipts = true;
            permissions = {
              "*" = "relay";
              ${serverName} = "user";
              "@${cfg.admin}:${serverName}" = "admin";
            };
          };

          database = {
            type = "postgres";
            uri = "postgres:///mautrix-meta-facebook?host=/var/run/postgresql/";
          };

          double_puppet = {
            secrets = {
              ${serverName} = "as_token:$MATRIX_APPSERVICE_AS_TOKEN";
            };
          };

          network = {
            # Don't be picky on Facebook/Messenger
            allow_messenger_com_on_fb = true;
            displayname_template = ''{{or .DisplayName .Username "Unknown user"}} (FB)'';
          };

          provisioning = {
            shared_secret = "disable";
          };
        };
      };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ "mautrix-meta-facebook" ];
        ensureUsers = [{
          name = "mautrix-meta-facebook";
          ensureDBOwnership = true;
        }];
      };

      systemd.services.mautrix-meta-facebook = {
        wants = [ "postgres.service" ];
        after = [ "postgres.service" ];
      };

      my.services.nginx.virtualHosts = {
        # Proxy to the bridge
        "facebook-bridge" = {
          inherit (cfg.facebook) port;
        };
      };
    })
  ];
}
