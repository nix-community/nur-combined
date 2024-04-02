# A low-ressource, full-featured git forge.
{ config, lib, ... }:
let
  cfg = config.my.services.forgejo;
in
{
  options.my.services.forgejo = with lib; {
    enable = mkEnableOption "Forgejo";
    port = mkOption {
      type = types.port;
      default = 3042;
      example = 8080;
      description = "Internal port";
    };
    mail = {
      enable = mkEnableOption {
        description = "mailer configuration";
      };
      host = mkOption {
        type = types.str;
        example = "smtp.example.com";
        description = "Host for the mail account";
      };
      port = mkOption {
        type = types.port;
        default = 465;
        example = 587;
        description = "Port for the mail account";
      };
      user = mkOption {
        type = types.str;
        example = "forgejo@example.com";
        description = "User for the mail account";
      };
      passwordFile = mkOption {
        type = types.str;
        example = "/run/secrets/forgejo-mail-password.txt";
        description = "Password for the mail account";
      };
      protocol = mkOption {
        type = types.str;
        default = "smtps";
        example = "smtp";
        description = "Protocol for connection";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> !config.my.services.gitea.enable;
        message = ''
          `config.my.services.forgejo` is incompatible with
          `config.my.services.gitea`.
        '';
      }
    ];

    services.forgejo =
      let
        inherit (config.networking) domain;
        forgejoDomain = "git.${domain}";
      in
      {
        enable = true;

        user = "git";
        group = "git";

        lfs.enable = true;

        useWizard = false;

        database = {
          type = "postgres"; # Automatic setup
          user = "git"; # User needs to be the same as forgejo user
          name = "git"; # Name must be the same as user for `ensureDBOwnership`
        };

        # NixOS module uses `forgejo dump` to backup repositories and the database,
        # but it produces a single .zip file that's not very backup friendly.
        # I configure my backup system manually below.
        dump.enable = false;

        mailerPasswordFile = lib.mkIf cfg.mail.enable cfg.mail.passwordFile;

        settings = {
          DEFAULT = {
            APP_NAME = "Ambroisie's forge";
          };

          server = {
            HTTP_PORT = cfg.port;
            DOMAIN = forgejoDomain;
            ROOT_URL = "https://${forgejoDomain}";
          };

          mailer = lib.mkIf cfg.mail.enable {
            ENABLED = true;
            SMTP_ADDR = cfg.mail.host;
            SMTP_PORT = cfg.mail.port;
            FROM = "Forgejo <${cfg.mail.user}>";
            USER = cfg.mail.user;
            PROTOCOL = cfg.mail.protocol;
          };

          service = {
            DISABLE_REGISTRATION = true;
          };

          session = {
            # only send cookies via HTTPS
            COOKIE_SECURE = true;
          };
        };
      };

    users.users.git = {
      description = "Forgejo Service";
      home = config.services.forgejo.stateDir;
      useDefaultShell = true;
      group = "git";
      isSystemUser = true;
    };
    users.groups.git = { };

    my.services.nginx.virtualHosts = {
      # Proxy to Forgejo
      git = {
        inherit (cfg) port;
      };
      # Redirect `forgejo.` to actual forge subdomain
      forgejo = {
        redirect = config.services.forgejo.settings.server.ROOT_URL;
      };
    };

    my.services.backup = {
      paths = [
        config.services.forgejo.lfs.contentDir
        config.services.forgejo.repositoryRoot
      ];
    };

    services.fail2ban.jails = {
      forgejo = ''
        enabled = true
        filter = forgejo
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/forgejo.conf".text = ''
        [Definition]
        failregex = ^.*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>$
        journalmatch = _SYSTEMD_UNIT=forgejo.service
      '';
    };
  };
}
