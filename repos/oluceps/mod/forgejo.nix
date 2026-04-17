{
  flake.modules.nixos.forgejo =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.services.forgejo;
      srv = cfg.settings.server;
    in
    {
      services.forgejo = {
        enable = true;
        database.type = "postgres";
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.nyaw.xyz";
            ROOT_URL = "https://${srv.DOMAIN}/";
            HTTP_PORT = 36462;
            DISABLE_SSH = true;
          };
          service = {
            DISABLE_REGISTRATION = false;
            REGISTER_EMAIL_CONFIRM = true;
            REGISTER_MANUAL_CONFIRM = true;
          };
          actions = {
            ENABLED = true;
          };
          mailer = {
            ENABLED = true;
            SMTP_ADDR = "box.nyaw.xyz";
            FROM = "forgejo admin of nyaw <forgejo@nyaw.xyz>";
            USER = "forgejo@nyaw.xyz";
          };
          storage = {
            STORAGE_TYPE = "minio";
            MINIO_USE_SSL = true;
            MINIO_ENDPOINT = "s3.nyaw.xyz";
            MINIO_BUCKET = "forgejo";
            MINIO_LOCATION = "ap-east-1";
          };
        };
        secrets = {
          mailer.PASSWD = config.vaultix.secrets.forgejo-mailer-pwd.path;
          storage.MINIO_SECRET_ACCESS_KEY = config.vaultix.secrets.forgejo-s3-key.path;
          storage.MINIO_ACCESS_KEY_ID = config.vaultix.secrets.forgejo-s3-id.path;
        };
      };
      vaultix.secrets = {
        forgejo-mailer-pwd = {
          mode = "400";
          owner = "forgejo";
        };
        forgejo-runner-token = {
          mode = "400";
          owner = "gitea-actions-runner";
        };
        forgejo-s3-id = {
          mode = "400";
          owner = "forgejo";
        };
        forgejo-s3-key = {
          mode = "400";
          owner = "forgejo";
        };
      };
      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances.default = {
          enable = true;
          name = "eihort-local";
          url = "https://git.nyaw.xyz";
          tokenFile = config.vaultix.secrets.forgejo-runner-token.path;
          labels = [
            "ubuntu-latest:docker://node:16-bullseye"
            "ubuntu-22.04:docker://node:16-bullseye"
            "ubuntu-20.04:docker://node:16-bullseye"
            "ubuntu-18.04:docker://node:16-buster"
          ];
        };
      };
    };
}
