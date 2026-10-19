{
  config,
  lib,
  ...
}:
let
  service = "niks3";
  hl = config.homelab;
  cfg = hl.services.${service};
  port = 5751;

  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}, a self-hosted S3-backed Nix binary cache";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where niks3 actually runs, if not this machine";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "cache.${hl.baseDomainName}";
      description = "Domain to serve niks3 on";
    };

    s3 = {
      endpoint = lib.mkOption {
        type = lib.types.str;
        description = "S3 endpoint host, e.g. \"<account-id>.r2.cloudflarestorage.com\" for R2";
      };
      bucket = lib.mkOption {
        type = lib.types.str;
        description = "S3 bucket name";
      };
      region = lib.mkOption {
        type = lib.types.str;
        default = "auto";
        description = "S3 region; R2 always uses \"auto\"";
      };
      accessKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to a file containing the S3 access key (no trailing newline)";
      };
      secretKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to a file containing the S3 secret key (no trailing newline)";
      };
    };

    apiTokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the niks3 API token (>=36 chars, no trailing newline)";
    };

    signKeyFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Paths to Ed25519 signing key files ("name:base64-key" format) used to
        sign narinfos. Multiple entries allow key rotation.
      '';
    };

    maxNarSize = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "2G";
      description = "Maximum uncompressed NAR size accepted for upload; null means unlimited";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        # Chunks themselves live in the configured S3 bucket, not here --
        # this is niks3's local metadata catalog (postgres) plus state dir.
        postgres = "niks3";
        files = [ "/var/lib/niks3" ];
      };
      description = "What to back up for niks3; see homelab/services/restic";
    };

    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Niks3";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        services.niks3 = {
          enable = true;
          readProxy = {
            enable = true;
            redirectTTL = "24h";
          };
          httpAddr = "127.0.0.1:${toString port}";

          s3 = {
            endpoint = cfg.s3.endpoint;
            bucket = cfg.s3.bucket;
            region = cfg.s3.region;
            accessKeyFile = cfg.s3.accessKeyFile;
            secretKeyFile = cfg.s3.secretKeyFile;
          };

          oidc.providers = {
            github = {
              issuer = "https://token.actions.githubusercontent.com";
              audience = "https://${cfg.url}";
              boundClaims = {
                repository_owner = [ "avycado13" ];
              };
              boundSubject = [ "repo:avycado13/*:*" ];
              # scopes = [ "write" ]; or rules = [ { boundSubject = [ ... ]; scopes = [ ... ]; } ];
            };
            # GCP Workload Identity Federation: e.g. GitHub Actions
            # impersonates this service account and mints a Google ID token
            # (iss=accounts.google.com) instead of presenting the GitHub
            # token directly. Replace the placeholder email below with the
            # actual federated service account before this does anything.
            gcp = {
              issuer = "https://accounts.google.com";
              audience = "https://${cfg.url}";
              boundClaims = {
                email = [ "CHANGEME@CHANGEME.iam.gserviceaccount.com" ];
              };
              scopes = [ "write" ];
            };
          };

          inherit (cfg) apiTokenFile;
          inherit (cfg) signKeyFiles;

          cacheUrl = "https://${cfg.url}";
          serverUrl = "https://${cfg.url}";
          inherit (cfg) maxNarSize;
          gc = {
            enable = true; # Default: true
            olderThan = "336h"; # 14 days
            failedUploadsOlderThan = "6h"; # 6 hours (default)
            schedule = "daily"; # Run at midnight daily (default)
            randomizedDelaySec = 1800; # Add 0–30 minimum random delay (default)
          };
        };

        systemd.services.${service}.unitConfig.OnFailure = lib.mkIf (
          hl.notifications.ntfySecretsFile != null
        ) "notify-failure@%n.service";

        # First-boot initdb can outrun systemd's default 90s TimeoutStartSec
        # on slow SD-card-backed boards (e.g. apollo1), which fails
        # postgresql.service and cascades into "dependency failed" for
        # niks3 (Requires=postgresql.service). Give it more room.
        systemd.services.postgresql.serviceConfig.TimeoutStartSec = "600s";

        services.nix-cache-beacon = {
          # Announce cache to the local network
          advert = {
            enable = true;
            inherit port;
          };

          # Enable local binary cache using discovered caches on the local network
          cache.enable = true;
        };

        # mDNS may not be ready yet at boot, and nix-cache-beacon panics instead
        # of retrying internally when it can't resolve *.local; wait for avahi.
        systemd.services.nix-cache-beacon-cache = {
          after = [ "avahi-daemon.service" ];
          wants = [ "avahi-daemon.service" ];
        };
      })
      (lib.mkIf hl.services.enable {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:${toString port}
            request_body {
              max_size 0
            }
          '';
        };
      })
    ]
  );
}
