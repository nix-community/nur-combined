{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      signupsAllowed = false;
      sendsAllowed = false;
      emergencyAccessAllowed = false;
      orgCreationUsers = "none";
      domain = "https://vault.nyaw.xyz";
      rocketAddress = "10.0.1.2";
      rocketPort = 8003;
    };
    # backupDir = "/var/lib/bitwarden_rs/backup";
    environmentFile = config.age.secrets.vault.path;
  };
}
