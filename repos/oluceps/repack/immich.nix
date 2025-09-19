{ reIf, config, ... }:
reIf {
  services = {
    immich = {
      enable = true;
      host = "fdcc::3";
      secretsFile = config.vaultix.secrets.immich.path;
      database.enable = false;
      machine-learning = {
        enable = true;
        environment = {
          HF_XET_CACHE = "/var/cache/immich/huggingface-xet";
          MPLCONFIGDIR = "/var/tmp/immich/mplconfig";
        };
      };
      redis.enable = true;
      settings = null;
      # environment.IMMICH_LOG_LEVEL = "verbose";
    };
    immich-public-proxy = {
      enable = true;
      immichUrl = "http://localhost:2283";
      port = 3001;
    };
  };
}
