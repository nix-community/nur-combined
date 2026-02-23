{
  pkgs,
  lib,
  config,
  homelab,
  ...
}:
let
  inherit (config.networking) hostName;
in
{
  config = lib.mkIf config.services.nextcloud.enable {
    networking.firewall = {
      allowedTCPPorts = [ config.services.collabora-online.port ];
      allowedUDPPorts = [ config.services.collabora-online.port ];
    };
    services = {
      nextcloud = {
        hostName = "nextcloud.diekvoss.net";
        config = {
          adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
          adminuser = config.userPresets.toyvo.name;
          dbtype = "pgsql";
        };
        database.createLocally = true;
        package = pkgs.nextcloud32;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps)
            news
            contacts
            calendar
            tasks
            richdocuments
            bookmarks
            music
            mail
            notes
            cookbook
            ;
        };
        extraAppsEnable = true;
      };
      collabora-online = {
        enable = true;
        port = homelab.${hostName}.services.collabora.port;
        settings = {
          server_name = "collabora.diekvoss.net";
          storage.wopi = {
            "@allow" = true;
            host = [ "nextcloud.diekvoss.net" ];
          };
          net = {
            listen = "0.0.0.0";
            post_allow.host = [ "0.0.0.0" ];
          };
          ssl = {
            enable = false;
            termination = true;
          };
        };
      };
    };
    sops.secrets.nextcloud_admin_password.owner = "nextcloud";
    systemd.services.nextcloud-config-collabora =
      let
        inherit (config.services.nextcloud) occ;

        wopi_url = "http://0.0.0.0:${toString config.services.collabora-online.port}";
        public_wopi_url = "https://collabora.diekvoss.net";
        wopi_allowlist = lib.concatStringsSep "," [
          "0.0.0.0/0"
        ];
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = [
          "nextcloud-setup.service"
          "coolwsd.service"
        ];
        requires = [ "coolwsd.service" ];
        script = ''
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
          ${occ}/bin/nextcloud-occ richdocuments:setup
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
  };
}
