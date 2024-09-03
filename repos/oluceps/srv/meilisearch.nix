{ pkgs, config, ... }:
{
  enable = true;
  listenAddress = "0.0.0.0";
  environment = "production";
  masterKeyEnvironmentFile = config.age.secrets.meilisearch.path;
}
