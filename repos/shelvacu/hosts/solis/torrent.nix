{
  config,
  pkgs,
  vacuModules,
  vaculib,
  ...
}:
{
  imports = [ vacuModules.solis-oauth-transmission ];
  vacu.oauthProxy.instances.solis-transmission = {
    configureCaddy = true;
    caddyConfig = ''
      reverse_proxy unix//var/run/transmission-socket-dir/socket.unix
    '';
  };

  # sops.secrets.transmissionCredentialsFile = {
  #   owner = config.services.transmission.user;
  #   restartUnits = [ "transmission.service" ];
  # };
  users.groups.torrents.members = [
    "transmission"
    "shelvacu"
  ];
  users.groups.${config.services.transmission.group}.members = [
    "caddy"
    "shelvacu"
  ];
  systemd.tmpfiles.settings.whatever = {
    "/xstore/torrents".d = {
      user = "transmission";
      group = "torrents";
      mode = vaculib.accessModeStr {
        user = "all";
        group = {
          read = true;
          write = false;
          execute = true;
        };
      };
    };
    "/var/run/transmission-socket-dir".d = {
      user = "transmission";
      group = "transmission";
      mode = vaculib.accessModeStr {
        user = "all";
        group = "all";
      };
    };
  };
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    package = pkgs.transmission_4;
    downloadDirPermissions = vaculib.accessModeStr {
      user = "all";
      group = {
        read = true;
        write = false;
        execute = true;
      };
    };
    performanceNetParameters = true;

    settings = {
      umask = vaculib.maskStr {
        user = "allow";
        group = {
          read = "allow";
          write = "forbid";
          execute = "allow";
        };
        other = "forbid";
      };
      download-dir = "/xstore/torrents";
      incomplete-dir = "/xstore/torrents/unfinished";
      incomplete-dir-enabled = true;
      preallocation = 2; # "full"
      rpc-socket-mode = vaculib.accessModeStr {
        user = "all";
        group = "all";
      };
      rpc-bind-address = "unix:/var/run/transmission-socket-dir/socket.unix";
      rpc-authentication-required = false;
      # rpc-username = "user";
      port-forwarding-enabled = false;
      download-queue-size = 20;
    };
  };
  systemd.services.transmission.serviceConfig.BindPaths = [ "/var/run/transmission-socket-dir" ];

  # services.caddy.virtualHosts."xs.shelvacu.com".extraConfig = ''
  #   reverse_proxy unix//var/run/transmission-socket-dir/socket.unix
  # '';
}
