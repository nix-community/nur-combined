{ config, pkgs, ... }:
{
  enable = true;
  environmentFile = config.age.secrets.syncv3.path;
  settings = {
    SYNCV3_SERVER = "https://matrix.nyaw.xyz";
    SYNCV3_BINDADDR = "/run/matrix-sliding-sync/sync.sock";
    SYNCV3_LOG_LEVEL = "info";
  };
}
