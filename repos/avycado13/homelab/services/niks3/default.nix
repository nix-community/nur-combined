{
  config,
  lib,
  ...
}:
let
  hl = config.homelab;
  cfg = hl.services.niks3;
  port = 5751;

  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.niks3 = {
    enable = lib.mkEnableOption "Enable niks3, a self-hosted S3-backed Nix binary cache";

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

  config = lib.mkIf (cfg.enable && hl.services.enable) {
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = hl.baseDomainName;
      extraConfig = ''
        reverse_proxy http://${cfg.host}:${toString port}
        request_body {
          max_size 0
        }
      '';
    };
  };
}
