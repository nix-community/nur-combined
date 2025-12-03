{ config, ... }:
let
  uid = 992;
  gid = 992;
  outer_config = config;
in
{
  users.users.gallerygrab = {
    inherit uid;
    isSystemUser = true;
    group = "gallerygrab";
  };
  users.groups.gallerygrab = { inherit gid; };

  vacu.databases.gallerygrab = {
    fromContainer = "gallerygrab";
  };

  systemd.tmpfiles.settings.vacu-container-gallerygrab = {
    "/trip/ffuts/archive/gallerygrab".d = {
      user = "gallerygrab";
      group = "gallerygrab";
    };
    "/var/container-applets/gallerygrab".d = { };
    # "/nix/var/nix/gcroots/container-applets-gallerygrab"."L+".argument =
    #   "/var/container-applets/gallerygrab";
  };
  containers.gallerygrab = {
    privateNetwork = true;
    hostAddress = "192.168.100.28";
    localAddress = "192.168.100.29";

    autoStart = false;
    ephemeral = false;

    bindMounts."/g" = {
      hostPath = "/trip/ffuts/archive/gallerygrab";
      isReadOnly = false;
    };

    bindMounts."/applets" = {
      hostPath = "/var/container-applets/gallerygrab";
      isReadOnly = true;
    };

    config =
      { lib, ... }:
      {
        system.stateVersion = "24.05";

        networking.firewall.enable = false;
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;

        environment.systemPackages = [ outer_config.services.postgresql.package ];

        users.users.gallerygrab = {
          inherit uid;
          isSystemUser = true;
          group = "gallerygrab";
          home = "/var/gallerygrab";
        };
        users.groups.gallerygrab = { inherit gid; };
      };
  };
}
