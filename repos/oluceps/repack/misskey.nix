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
  };

  users = {
    users.misskey = {
      group = "misskey";
      isSystemUser = true;
    };
    groups.misskey = {
    };
  };

  systemd.services.misskey = {
    after = [
      "network-online.target"
      "postgresql.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      MISSKEY_CONFIG_YML = "/run/credentials/misskey.service/config";
      NODE_OPTIONS = "--use-openssl-ca";
    };
    serviceConfig = {
      LoadCredential = [ "config:${config.vaultix.secrets.misskey.path}" ];
      ExecStart = "${pkgs.misskey}/bin/misskey migrateandstart";
      RuntimeDirectory = "misskey";
      RuntimeDirectoryMode = "770";
      StateDirectory = "misskey";
      StateDirectoryMode = "700";
      TimeoutSec = 60;
      DynamicUser = false;
      User = "misskey";
      Group = "misskey";
      LockPersonality = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
    };
  };
}
