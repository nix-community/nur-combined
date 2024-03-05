# A low-ressource, full-featured git forge.
{ config, lib, ... }:
let
  cfg = config.my.services.gitea;
in
{
  options.my.services.gitea = with lib; {
    enable = mkEnableOption "Gitea";
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
        example = "gitea@example.com";
        description = "User for the mail account";
      };
      passwordFile = mkOption {
        type = types.str;
        example = "/run/secrets/gitea-mail-password.txt";
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
    services.gitea =
      let
        inherit (config.networking) domain;
        giteaDomain = "git.${domain}";
      in
      {
        enable = true;

        appName = "Ambroisie's forge";

        user = "git";
        group = "git";

        lfs.enable = true;

        useWizard = false;

        database = {
          type = "postgres"; # Automatic setup
          user = "git"; # User needs to be the same as gitea user
          name = "git"; # Name must be the same as user for `ensureDBOwnership`
        };

        # NixOS module uses `gitea dump` to backup repositories and the database,
        # but it produces a single .zip file that's not very backup friendly.
        # I configure my backup system manually below.
        dump.enable = false;

        mailerPasswordFile = lib.mkIf cfg.mail.enable cfg.mail.passwordFile;

        settings = {
          server = {
            HTTP_PORT = cfg.port;
            DOMAIN = giteaDomain;
            ROOT_URL = "https://${giteaDomain}";
          };

          mailer = lib.mkIf cfg.mail.enable {
            ENABLED = true;
            SMTP_ADDR = cfg.mail.host;
            SMTP_PORT = cfg.mail.port;
            FROM = "Gitea <${cfg.mail.user}>";
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
      description = "Gitea Service";
      home = config.services.gitea.stateDir;
      useDefaultShell = true;
      group = "git";
      isSystemUser = true;
    };
    users.groups.git = { };

    my.services.nginx.virtualHosts = {
      # Proxy to Gitea
      git = {
        inherit (cfg) port;
      };
      # Redirect `gitea.` to actual forge subdomain
      gitea = {
        redirect = config.services.gitea.settings.server.ROOT_URL;
      };
    };

    my.services.backup = {
      paths = [
        config.services.gitea.lfs.contentDir
        config.services.gitea.repositoryRoot
      ];
    };

    services.fail2ban.jails = {
      gitea = ''
        enabled = true
        filter = gitea
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/gitea.conf".text = ''
        [Definition]
        failregex = ^.*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>$
        journalmatch = _SYSTEMD_UNIT=gitea.service
      '';
    };
  };
}
