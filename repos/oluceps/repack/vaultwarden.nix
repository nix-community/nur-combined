{
  config,
  reIf,
  ...
}:
reIf {
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      signupsAllowed = false;
      sendsAllowed = true;
      emergencyAccessAllowed = false;
      orgCreationUsers = "none";
      domain = "https://vault.nyaw.xyz";
      rocketAddress = "fdcc::3";
      rocketPort = 8003;
    };
    # backupDir = "/var/lib/bitwarden_rs/backup";
    environmentFile = config.vaultix.secrets.vault.path;
  };
}
