{
  reIf,
  lib,
  config,
  utils,
  pkgs,
  ...
}:
reIf (
  let
    s3 = {
      bucket = "synapse";
      endpoint_url = "https://s3.nyaw.xyz";
    };
    caBundleEnv = "AWS_CA_BUNDLE=${lib.data.ca_cert.root_file}";
    inherit (config.services.matrix-synapse.settings) media_store_path;
  in
  {
    services.matrix-synapse = {
      enable = true;
      withJemalloc = true;
      plugins = with config.services.matrix-synapse.package.plugins; [
        matrix-synapse-s3-storage-provider
      ];
      settings = {
        server_name = "nyaw.xyz";
        public_baseurl = "https://matrix.nyaw.xyz";
        enable_authenticated_media = true;
        enable_metrics = true;
        dynamic_thumbnails = true;
        allow_public_rooms_over_federation = true;

        enable_registration = true;
        registration_requires_token = true;

        media_storage_providers = [
          {
            module = "s3_storage_provider.S3StorageProviderBackend";
            store_local = true;
            store_remote = true;
            store_synchronous = true;
            config = {
              inherit (s3) bucket endpoint_url;
            };
          }
        ];
        oidc_providers = [
          {
            client_id = "7eac9a65-1ebb-4185-a8ec-17c3b614d6cd";
            client_secret_path = config.vaultix.secrets.synapse-oidc.path;
            idp_id = "pocket_id";
            idp_name = "Pocket ID";
            issuer = "https://oidc.nyaw.xyz/";

            allow_existing_users = true;
            backchannel_logout_enabled = true;

            scopes = [
              "openid"
              "profile"
            ];
            user_mapping_provider = {
              config = {
                display_name_template = "{{ user.name }}";
                localpart_template = "{{ user.preferred_username }}";
              };
            };
          }
        ];

        listeners = [
          {
            port = 9031;
            type = "metrics";
            bind_addresses = [ "::1" ];
            tls = false;
            resources = [ ];
          }
          {
            bind_addresses = [ "fdcc::3" ];
            port = 8196;
            tls = false;
            type = "http";
            x_forwarded = true;
            resources = [
              {
                compress = true;
                names = [
                  "client"
                  "federation"
                ];
              }
            ];
          }
        ];

        media_retention = {
          remote_media_lifetime = "14d";
        };

        experimental_features = {
          # Room summary api
          msc3266_enabled = true;
          # Removing account data
          msc3391_enabled = true;
          # Thread notifications
          msc3773_enabled = true;
          # Remotely toggle push notifications for another client
          msc3881_enabled = true;
          # Remotely silence local notifications
          msc3890_enabled = true;
          # Remove legacy mentions
          msc4210_enabled = true;
        };

        rc_admin_redaction = {
          per_second = 1000;
          burst_count = 10000;
        };
      };
    };

    systemd.timers.matrix-synapse-s3-upload = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        FixedRandomDelay = true;
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "4h";
      };
    };

    systemd.services.matrix-synapse-s3-upload.serviceConfig = {
      Type = "oneshot";
      inherit (config.systemd.services.matrix-synapse.serviceConfig) User Group;
      Environment = [ caBundleEnv ];
      EnvironmentFile = [ config.vaultix.secrets.synapse-s3.path ];
      RuntimeDirectory = [ "matrix-synapse-s3-upload" ];
      WorkingDirectory = "%t/matrix-synapse-s3-upload";
      BindReadOnlyPaths = [
        "${
          (pkgs.formats.yaml { }).generate "database.yaml" {
            postgres = {
              inherit (config.services.matrix-synapse.settings.database.args) database;
            };
          }
        }:%t/matrix-synapse-s3-upload/database.yaml"
      ];
      ExecStart = with config.services.matrix-synapse.package.plugins; [
        (utils.escapeSystemdExecArgs [
          (lib.getExe matrix-synapse-s3-storage-provider)
          "--no-progress"
          "update"
          # KeyError: 'password'
          # "--homeserver-config-path"
          # config.services.matrix-synapse.configFile
          media_store_path
          "1h"
        ])
        (utils.escapeSystemdExecArgs [
          (lib.getExe matrix-synapse-s3-storage-provider)
          "--no-progress"
          "upload"
          "--delete"
          "--endpoint-url"
          s3.endpoint_url
          media_store_path
          s3.bucket
        ])
      ];
    };

    systemd.services.matrix-synapse.serviceConfig = {
      Environment = [
        "AWS_REQUEST_CHECKSUM_CALCULATION=when_required"
        "AWS_RESPONSE_CHECKSUM_VALIDATION=when_required"
        caBundleEnv
      ];
      EnvironmentFile = [
        config.vaultix.secrets.synapse-s3.path
      ];
    };

  }
)
