# A low-ressource, full-featured git forge.
{ config, lib, ... }:
let
  cfg = config.my.services.gitea;
  domain = config.networking.domain;
  giteaDomain = "gitea.${config.networking.domain}";
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
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;

      appName = "Ambroisie's forge";
      httpPort = cfg.port;
      domain = giteaDomain;
      rootUrl = "https://${giteaDomain}";

      user = "git";
      lfs.enable = true;

      useWizard = false;
      disableRegistration = true;

      # only send cookies via HTTPS
      cookieSecure = true;

      database = {
        type = "postgres"; # Automatic setup
        user = "git"; # User needs to be the same as gitea user
      };

      # NixOS module uses `gitea dump` to backup repositories and the database,
      # but it produces a single .zip file that's not very backup friendly.
      # I configure my backup system manually below.
      dump.enable = false;
    };

    users.users.git = {
      description = "Gitea Service";
      home = config.services.gitea.stateDir;
      useDefaultShell = true;
      group = "git";

      # The service for gitea seems to hardcode the group as
      # gitea, so, uh, just in case?
      extraGroups = [ "gitea" ];

      isSystemUser = true;
    };
    users.groups.git = { };

    # Proxy to Gitea
    services.nginx.virtualHosts."${giteaDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}/";
    };

    my.services.backup = {
      paths = [
        config.services.gitea.lfs.contentDir
        config.services.gitea.repositoryRoot
      ];
    };
  };
}
