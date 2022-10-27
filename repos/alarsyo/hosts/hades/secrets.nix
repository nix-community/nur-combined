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
        "gandi/api-key" = {};

        "matrix-synapse/secret-config" = {
          owner = "matrix-synapse";
        };

        "miniflux/admin-credentials" = {};

        "nextcloud/admin-pass" = {
          owner = "nextcloud";
        };

        "restic-backup/hades-credentials" = {};
        "restic-backup/hades-password" = {};

        "users/alarsyo-hashed-password" = {};
        "users/root-hashed-password" = {};
      };
  };
}
