{ config, lib, ... }:
let
  cfg = config.my.services.pyload;
in
{
  options.my.services.pyload = with lib; {
    enable = mkEnableOption "pyload download manager";

    credentialsFile = mkOption {
      type = types.path;
      example = "/run/secrets/pyload-credentials.env";
      description = "pyload credentials";
    };

    downloadDirectory = mkOption {
      type = types.str;
      default = "/data/downloads/pyload";
      example = "/var/lib/pyload/download";
      description = "Download directory";
    };

    port = mkOption {
      type = types.port;
      default = 9093;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pyload = {
      enable = true;

      # Listening on `localhost` leads to 502 with the reverse proxy...
      listenAddress = "127.0.0.1";

      inherit (cfg)
        credentialsFile
        downloadDirectory
        port
        ;
    };

    # Use pyload user/media group when downloading files
    systemd.services.pyload = {
      serviceConfig = {
        User = lib.mkForce "pyload";
        Group = lib.mkForce "media";
        DynamicUser = lib.mkForce false;
      };
    };

    # And make sure the download directory has the correct owners
    systemd.tmpfiles.settings.pyload = {
      ${cfg.downloadDirectory}.d = {
        user = "pyload";
        group = "media";
      };
    };

    # Set-up pyload user and media group
    users.users.pyload = {
      isSystemUser = true;
      group = "media";
    };

    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      pyload = {
        inherit (cfg) port;
      };
    };

    # FIXME: fail2ban
  };
}
