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
    listenAddress = "::";
    settings.env = "production";
    # environment = "development";
    masterKeyFile = config.vaultix.secrets.meilisearch.path;
  };
}
