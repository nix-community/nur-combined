{
  config,
  lib,
  options,
  ...
}: {
  config.age = {
    secrets = let
      toSecret = name: {...} @ attrs:
        {
          file = ./../../modules/secrets + "/${name}.age";
        }
        // attrs;
    in
      lib.mapAttrs toSecret {
        "gitlab-runner/hades-nix-runner-env" = {};

        "lohr/shared-secret" = {};

        "matrix-synapse/secret-config" = {
          owner = "matrix-synapse";
        };

        "mealie/secret-config" = {};

        "microbin/secret-config" = {};

        "miniflux/admin-credentials" = {};

        "nextcloud/admin-pass" = {
          owner = "nextcloud";
        };

        "ovh/credentials" = {};

        "paperless/admin-password" = {};
        "paperless/secret-key" = {};

        "restic-backup/hades-credentials" = {};
        "restic-backup/hades-password" = {};

        "users/alarsyo-hashed-password" = {};
        "users/root-hashed-password" = {};
      };
  };
}
