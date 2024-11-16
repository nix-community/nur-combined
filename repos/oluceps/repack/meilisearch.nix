{
  reIf,
  config,
  lib,
  ...
}:
reIf {
  systemd.services.meilisearch.environment.MEILI_NO_ANALYTICS = lib.mkForce "true";
  services.meilisearch = {
    enable = true;
    listenAddress = "0.0.0.0";
    environment = "production";
    masterKeyEnvironmentFile = config.vaultix.secrets.meilisearch.path;
  };
}
