# A self-hosted cloud.
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nextcloud;
in
{
  imports = [
    ./collabora.nix
  ];

  options.my.services.nextcloud = with lib; {
    enable = mkEnableOption "Nextcloud";
    maxSize = mkOption {
      type = types.str;
      default = "512M";
      example = "1G";
      description = "Maximum file upload size";
    };
    admin = mkOption {
      type = types.str;
      default = "Ambroisie";
      example = "admin";
      description = "Name of the admin user";
    };
    passwordFile = mkOption {
      type = types.str;
      example = "/var/lib/nextcloud/password.txt";
      description = ''
        Path to a file containing the admin's password, must be readable by
        'nextcloud' user.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      hostName = "nextcloud.${config.networking.domain}";
      home = "/var/lib/nextcloud";
      maxUploadSize = cfg.maxSize;
      configureRedis = true;
      config = {
        adminuser = cfg.admin;
        adminpassFile = cfg.passwordFile;
        dbtype = "pgsql";
      };

      https = true;

      # Automatic PostgreSQL provisioning
      database = {
        createLocally = true;
      };

      settings = {
        overwriteprotocol = "https"; # Nginx only allows SSL
      };

      notify_push = {
        enable = true;
        # Allow using the push service without hard-coding my IP in the configuration
        bendDomainToLocalhost = true;
      };
    };

    # The service above configures the domain, no need for my wrapper
    services.nginx.virtualHosts."nextcloud.${config.networking.domain}" = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
    };

    my.services.backup = {
      paths = [
        config.services.nextcloud.home
      ];
      exclude = [
        # image previews can take up a lot of space
        "${config.services.nextcloud.home}/data/appdata_*/preview"
      ];
    };

    services.fail2ban.jails = {
      nextcloud = ''
        enabled = true
        filter = nextcloud
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/nextcloud.conf".text = ''
        [Definition]
        _groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
        datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
        failregex = ^[^{]*\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
                    ^[^{]*\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
                    ^[^{]*\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Two-factor challenge failed:
        journalmatch = _SYSTEMD_UNIT=phpfpm-nextcloud.service
      '';
    };
  };
}
