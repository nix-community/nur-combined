{ config, vaculib, ... }:
let
  uds_dir = "/var/lib/syncthing-uds";
  uds_path = "${uds_dir}/socket";
  the_path = "/propdata/syncthing";
in
{
  systemd.tmpfiles.settings.whatever = {
    ${uds_dir}.d = {
      mode = vaculib.accessModeStr {
        user = "all";
        group = "all";
      };
      user = config.services.syncthing.user;
      group = config.services.caddy.group;
    };
    ${the_path}.d = {
      mode = vaculib.accessModeStr { user = "all"; };
      user = config.services.syncthing.user;
      group = config.services.syncthing.group;
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = uds_path;
    overrideDevices = false;
    overrideFolders = false;
    settings.gui = {
      unixSocketPermissions = "0777";
      insecureAdminAccess = true;
      insecureSkipHostcheck = true;
    };
    settings.options = {
      autoUpgradeIntervalH = 0;
      crashReportingEnabled = false;
      urAccepted = -1;
    };
    settings."defaults/folder".path = "/propdata/syncthing";
  };

  services.caddy.virtualHosts."syncthing.shelvacu.com".vacu.hsts = "preload";

  vacu.oauthProxy.instances.syncthing = {
    enable = true;
    displayName = "syncthing";
    appDomain = "syncthing.shelvacu.com";
    requireOauth = true;
    kanidmMembers = [ "shelvacu" ];
    caddyConfig = ''
      reverse_proxy unix/${uds_path} {
        header_up Host {upstream_hostport}
      }
    '';
  };
}
