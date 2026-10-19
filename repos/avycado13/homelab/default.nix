{
  lib,
  config,
  ...
}:
let
  cfg = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };
    timeZone = lib.mkOption {
      default = "America/Los_Angeles";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
    baseDomainName = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };
    cloudflare.dnsCredentialsFile = lib.mkOption {
      type = lib.types.path;
      example = ''
        CF_DNS_API_TOKEN=verybigsecret
        CF_API_EMAIL=foo@bar.com
      '';
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Email address used for ACME certificate registration and other notifications";
    };

    notifications.ntfySecretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a secret file containing NTFY_TOPIC=<url> (e.g. a sops secret).
        When set, a notify-failure@ systemd template unit is created that
        POSTs to that topic whenever a monitored service fails.
        Example URL: https://ntfy.example.com/my-alerts
      '';
    };
  };
  imports = [
    ./services
    ./fail2ban-cloudflare
    ./motd
  ];
  config = lib.mkIf cfg.enable {
    # users = {
    #   groups.${cfg.group} = {
    #   };
    #   users.${cfg.user} = {
    #     isSystemUser = true;
    #     group = cfg.group;
    #   };
    # };
  };
}
