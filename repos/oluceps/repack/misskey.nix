{
  reIf,
  config,
  pkgs,
  ...
}:
reIf {
  services.redis.servers.misskey = {
    enable = true;
    port = 6379;
    # bind = "0.0.0.0";
    # extraParams = [ "--protected-mode no" ];
  };
  # users = {
  #   groups.misskey = { };
  #   users.misskey = {
  #     isSystemUser = true;
  #     group = "misskey";
  #     home = "/var/lib/misskey";
  #     linger = true;
  #     createHome = true;
  #     subUidRanges = [
  #       {
  #         count = 65536;
  #         startUid = 2147483646;
  #       }
  #     ];
  #     subGidRanges = [
  #       {
  #         count = 65536;
  #         startGid = 2147483647;
  #       }
  #     ];
  #   };
  # };

  virtualisation.oci-containers = {
    containers.misskey = {
      volumes = [
        "${config.vaultix.secrets.misskey.path}:/misskey/.config/config:ro"
        "/etc/ssl/certs:/etc/extra-ca:ro"
      ];
      # pull = "always";
      image = "misskey/misskey:2025.4";
      # ports = [ "3012:3012" ];
      networks = [ "host" ];
      # networks = [ "pasta:--map-gw" ];

      environment = {
        MISSKEY_CONFIG_YML = "config";
        # NODE_OPTIONS = "--use-openssl-ca";
        NODE_EXTRA_CA_CERTS = "/etc/extra-ca/ca-certificates.crt";
      };

      # TODO: CA
    };
  };
  # systemd.services.podman-misskey.serviceConfig.LoadCredential = [
  #   "config:${config.vaultix.secrets.misskey.path}"
  # ];

  # systemd.services.misskey = {
  #   after = [
  #     "network-online.target"
  #     "postgresql.service"
  #   ];
  #   wants = [ "network-online.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   environment = {
  #     MISSKEY_CONFIG_YML = "/run/credentials/misskey.service/config";
  #     NODE_OPTIONS = "--use-openssl-ca";
  #   };
  #   serviceConfig = {
  #     LoadCredential = [ "config:${config.vaultix.secrets.misskey.path}" ];
  #     ExecStart = "${pkgs.misskey}/bin/misskey migrateandstart";
  #     RuntimeDirectory = "misskey";
  #     RuntimeDirectoryMode = "770";
  #     StateDirectory = "misskey";
  #     StateDirectoryMode = "700";
  #     TimeoutSec = 60;
  #     DynamicUser = false;
  #     User = "misskey";
  #     Group = "misskey";
  #     LockPersonality = true;
  #     PrivateDevices = true;
  #     PrivateUsers = true;
  #     ProtectClock = true;
  #     ProtectControlGroups = true;
  #     ProtectHome = true;
  #     ProtectHostname = true;
  #     ProtectKernelLogs = true;
  #     ProtectProc = "invisible";
  #     ProtectKernelModules = true;
  #     ProtectKernelTunables = true;
  #     RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
  #   };
  # };
}
