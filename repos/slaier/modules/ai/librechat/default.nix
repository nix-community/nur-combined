{ config, pkgs, ... }:
{
  sops.secrets.creds_key = { };
  sops.secrets.creds_iv = { };
  sops.secrets.jwt_secret = { };
  sops.secrets.jwt_refresh_secret = { };
  sops.secrets.meili_master_key = { };
  sops.secrets.gemini_api_key = { };
  services.librechat = {
    enable = true;
    env = {
      ALLOW_REGISTRATION = true;
      GOOGLE_MODELS = "gemini-3.5-flash-lite,gemini-3.1-flash-lite-preview";
      HTTPS_PROXY = config.networking.proxy.default;
    };
    credentials = {
      CREDS_KEY = config.sops.secrets.creds_key.path;
      CREDS_IV = config.sops.secrets.creds_iv.path;
      JWT_SECRET = config.sops.secrets.jwt_secret.path;
      JWT_REFRESH_SECRET = config.sops.secrets.jwt_refresh_secret.path;
      GOOGLE_KEY = config.sops.secrets.gemini_api_key.path;
    };
    meilisearch.enable = true;
    enableLocalDB = true;
  };
  services.meilisearch.masterKeyFile = config.sops.secrets.meili_master_key.path;
  environment.systemPackages = [ pkgs.librechat ];
}
