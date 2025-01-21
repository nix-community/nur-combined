{ reIf, config, ... }:
reIf {
  services = {
    immich = {
      enable = true;
      host = "0.0.0.0";
      secretsFile = config.vaultix.secrets.immich.path;
      database.createDB = false;
      machine-learning.enable = true;
      redis.enable = true;
      settings.server.externalDomain = "https://photo.nyaw.xyz";
    };
    immich-public-proxy = {
      enable = true;
      immichUrl = "http://localhost:2283";
      port = 3001;
    };
  };
}
