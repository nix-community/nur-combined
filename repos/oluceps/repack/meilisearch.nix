{ reIf, config, ... }:
reIf {
  services.meilisearch = {
    enable = true;
    listenAddress = "0.0.0.0";
    environment = "production";
    masterKeyEnvironmentFile = config.vaultix.secrets.meilisearch.path;
  };
}
