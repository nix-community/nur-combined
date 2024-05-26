{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.my.services.forgejo;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";

  forgejoUser = "git";
in {
  options.my.services.forgejo = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Personal Git hosting with Forgejo";

    privatePort = mkOption {
      type = types.port;
      default = 8082;
      example = 8082;
      description = "Port to serve the app";
    };
  };

  config = mkIf cfg.enable {
    # use git as user to have `git clone git@git.domain`
    users.users.${forgejoUser} = {
      description = "Forgejo Service";
      home = config.services.forgejo.stateDir;
      useDefaultShell = true;
      group = forgejoUser;

      # the systemd service for the forgejo module seems to hardcode the group as
      # forgejo, so, uh, just in case?
      extraGroups = ["forgejo"];

      isSystemUser = true;
    };
    users.groups.${forgejoUser} = {};

    services.forgejo = {
      enable = true;
      user = forgejoUser;
      group = config.users.users.${forgejoUser}.group;
      stateDir = "/var/lib/${forgejoUser}";

      lfs.enable = true;

      settings = {
        server = {
          ROOT_URL = "https://git.${domain}/";
          DOMAIN = "git.${domain}";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = cfg.privatePort;
        };
        log.LEVEL = "Warn"; # [ "Trace" "Debug" "Info" "Warn" "Error" "Critical" ]
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          DEFAULT_BRANCH = "main";
        };

        # NOTE: temporarily remove this for initial setup
        service.DISABLE_REGISTRATION = true;

        # only send cookies via HTTPS
        session.COOKIE_SECURE = true;

        DEFAULT.APP_NAME = "Personal Forge";
      };

      # NixOS module uses `forgejo dump` to backup repositories and the database,
      # but it produces a single .zip file that's not very restic friendly.
      # I configure my backup system manually below.
      dump.enable = false;

      database = {
        type = "postgres";
        # user needs to be the same as forgejo user
        user = forgejoUser;
        name = forgejoUser;
      };
    };

    # FIXME: Borg *could* be backing up files while they're being edited by
    # forgejo, so it may produce corrupt files in the snapshot if I push stuff
    # around midnight. I'm not sure how `forgejo dump` handles this either,
    # though.
    my.services.restic-backup = {
      paths = [
        config.services.forgejo.lfs.contentDir
        config.services.forgejo.repositoryRoot
      ];
    };

    # NOTE: no need to use postgresql.ensureDatabases because the forgejo module
    # takes care of this automatically
    services.postgresqlBackup = {
      databases = [config.services.forgejo.database.name];
    };

    services.nginx = {
      virtualHosts = {
        "git.${domain}" = {
          forceSSL = true;
          useACMEHost = fqdn;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.privatePort}";
          };
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["git.${domain}"];

    systemd.services.forgejo.preStart = "${pkgs.coreutils}/bin/ln -sfT ${./templates} ${config.services.forgejo.stateDir}/custom/templates";
  };
}
