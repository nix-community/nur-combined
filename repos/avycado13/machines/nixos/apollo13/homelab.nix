_: {
  #   sops.secrets = {
  #     cloudflare-dns-credentials = {
  #       sopsFile = ../../../secrets/secrets.yaml;
  #       key = "cloudflare/dns_credentials";
  #     };
  #     cloudflare-fail2ban-apikey = {
  #       sopsFile = ../../../secrets/secrets.yaml;
  #       key = "cloudflare/fail2ban_apikey";
  #     };
  #     ntfy_topic = {
  #       sopsFile = ../../../secrets/secrets.yaml;
  #       key = "ntfy_topic";
  #     };
  #   };

  #   homelab = {
  #     enable = false;
  #     baseDomainName = "avyay.in";
  #     email = "avycado13@icloud.com";
  #     cloudflare.dnsCredentialsFile = config.sops.secrets.cloudflare-dns-credentials.path;
  #   };
}
