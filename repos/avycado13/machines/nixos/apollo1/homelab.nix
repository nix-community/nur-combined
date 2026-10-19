{ config, ... }:
{
  # niks3 runs here; pi1 reverse-proxies to it over tailscale (see
  # machines/nixos/pi1/homelab.nix) since that's where Caddy/ACME live.
  sops.secrets = {
    cloudflare-dns-credentials = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "cloudflare/dns_credentials";
    };
    cloudflare-fail2ban-apikey = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "cloudflare/fail2ban_apikey";
    };
    ntfy_topic = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "ntfy_topic";
    };
    niks3-s3-access-key = {
      sopsFile = ../../../secrets/services.yaml;
      key = "niks3/s3_access_key";
      mode = "0444";
    };
    niks3-s3-secret-key = {
      sopsFile = ../../../secrets/services.yaml;
      key = "niks3/s3_secret_key";
      mode = "0444";
    };
    niks3-signing-key = {
      sopsFile = ../../../secrets/services.yaml;
      key = "niks3/signing_key";
      mode = "0444";
    };
    niks3-server-api-token = {
      sopsFile = ../../../secrets/services.yaml;
      key = "niks3/api_token";
      mode = "0444";
    };
  };

  homelab = {
    enable = true;
    baseDomainName = "avyay.in";
    email = "avycado13@icloud.com";
    cloudflare.dnsCredentialsFile = config.sops.secrets.cloudflare-dns-credentials.path;

    motd.enable = true;
    notifications.ntfySecretsFile = config.sops.secrets.ntfy_topic.path;

    services = {
      enable = true;
      navidrome = {
        enable = true;
        # Bind all interfaces so startup doesn't depend on Tailscale's IP being ready.
        # Port 4533 is opened only on tailscale0 (in default.nix).
        listenAddress = "0.0.0.0";
      };

      niks3 = {
        enable = true;
        url = "cache.avyay.in";
        s3 = {
          endpoint = "9de2baa272a57af74da84d8e6bd95a77.r2.cloudflarestorage.com";
          bucket = "nixcache";
          accessKeyFile = config.sops.secrets.niks3-s3-access-key.path;
          secretKeyFile = config.sops.secrets.niks3-s3-secret-key.path;
        };
        apiTokenFile = config.sops.secrets.niks3-server-api-token.path;
        signKeyFiles = [ config.sops.secrets.niks3-signing-key.path ];
      };
    };
  };
}
