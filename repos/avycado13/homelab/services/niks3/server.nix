# Imported only by hosts running the niks3 server (not reverse-proxy-only hosts).
{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.homelab.services.niks3;
  hl = config.homelab;
  port = 5751;
in
{
  imports = [
    inputs.nix-cache-beacon.nixosModules.default
    inputs.niks3.nixosModules.niks3
  ];

  config = lib.mkIf (cfg.enable && cfg.host == "127.0.0.1") {
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
          boundClaims.repository_owner = [ "avycado13" ];
          boundSubject = [ "repo:avycado13/*:*" ];
        };
        # Replace this placeholder with the federated GCP service account.
        gcp = {
          issuer = "https://accounts.google.com";
          audience = "https://${cfg.url}";
          boundClaims.email = [ "CHANGEME@CHANGEME.iam.gserviceaccount.com" ];
          scopes = [ "write" ];
        };
      };

      inherit (cfg) apiTokenFile signKeyFiles maxNarSize;
      cacheUrl = "https://${cfg.url}";
      serverUrl = "https://${cfg.url}";
      gc = {
        enable = true;
        olderThan = "336h";
        failedUploadsOlderThan = "6h";
        schedule = "daily";
        randomizedDelaySec = 1800;
      };
    };

    systemd.services.niks3.unitConfig.OnFailure = lib.mkIf (
      hl.notifications.ntfySecretsFile != null
    ) "notify-failure@%n.service";

    # Slow SD-card initdb can exceed systemd's default startup timeout.
    systemd.services.postgresql.serviceConfig.TimeoutStartSec = "600s";

    services.nix-cache-beacon = {
      advert = {
        enable = true;
        inherit port;
      };
      cache.enable = true;
    };

    # Wait for mDNS before cache discovery (beacon does not retry internally).
    systemd.services.nix-cache-beacon-cache = {
      after = [ "avahi-daemon.service" ];
      wants = [ "avahi-daemon.service" ];
    };
  };
}
