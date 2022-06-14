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

  cfg = config.my.services.gitea;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";

  giteaUser = "git";
in {
  options.my.services.gitea = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Personal Git hosting with Gitea";

    privatePort = mkOption {
      type = types.port;
      default = 8082;
      example = 8082;
      description = "Port to serve the app";
    };
  };

  config = mkIf cfg.enable {
    # use git as user to have `git clone git@git.domain`
    users.users.${giteaUser} = {
      description = "Gitea Service";
      home = config.services.gitea.stateDir;
      useDefaultShell = true;
      group = giteaUser;

      # the systemd service for the gitea module seems to hardcode the group as
      # gitea, so, uh, just in case?
      extraGroups = ["gitea"];

      isSystemUser = true;
    };
    users.groups.${giteaUser} = {};

    services.gitea = {
      enable = true;
      user = giteaUser;
      domain = "git.${domain}";
      appName = "Personal Forge";
      rootUrl = "https://git.${domain}/";
      httpAddress = "127.0.0.1";
      httpPort = cfg.privatePort;
      log.level = "Warn"; # [ "Trace" "Debug" "Info" "Warn" "Error" "Critical" ]
      lfs.enable = true;

      # NOTE: temporarily remove this for initial setup
      disableRegistration = true;

      # only send cookies via HTTPS
      cookieSecure = true;

      settings = {
        other.SHOW_FOOTER_VERSION = false;
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          DEFAULT_BRANCH = "main";
        };
      };

      # NixOS module uses `gitea dump` to backup repositories and the database,
      # but it produces a single .zip file that's not very restic friendly.
      # I configure my backup system manually below.
      dump.enable = false;

      database = {
        type = "postgres";
        # user needs to be the same as gitea user
        user = giteaUser;
      };
    };

    # FIXME: Borg *could* be backing up files while they're being edited by
    # gitea, so it may produce corrupt files in the snapshot if I push stuff
    # around midnight. I'm not sure how `gitea dump` handles this either,
    # though.
    my.services.restic-backup = {
      paths = [
        config.services.gitea.lfs.contentDir
        config.services.gitea.repositoryRoot
      ];
    };

    # NOTE: no need to use postgresql.ensureDatabases because the gitea module
    # takes care of this automatically
    services.postgresqlBackup = {
      databases = ["gitea"];
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

    systemd.services.gitea.preStart = "${pkgs.coreutils}/bin/ln -sfT ${./templates} ${config.services.gitea.stateDir}/custom/templates";
  };
}
