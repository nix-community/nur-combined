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
    listenAddress = "[::]";
    # settings.env = "production";
    settings.env = "development";
    masterKeyFile = config.vaultix.secrets.meilisearch.path;
  };
}
