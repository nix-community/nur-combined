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
      sendsAllowed = false;
      emergencyAccessAllowed = false;
      orgCreationUsers = "none";
      domain = "https://vault.nyaw.xyz";
      rocketAddress = "0.0.0.0";
      rocketPort = 8003;
    };
    # backupDir = "/var/lib/bitwarden_rs/backup";
    environmentFile = config.vaultix.secrets.vault.path;
  };
}
