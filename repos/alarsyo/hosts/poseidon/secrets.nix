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

        "lohr/shared-secret" = {};

        "paperless/admin-password" = {};
        "paperless/secret-key" = {};

        "restic-backup/poseidon-credentials" = {};
        "restic-backup/poseidon-password" = {};

        "users/alarsyo-hashed-password" = {};
        "users/root-hashed-password" = {};
      };
  };
}
