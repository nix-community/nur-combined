{ config, lib, options, ... }:

{
  config.age = {
    secrets =
      let
        toSecret = name: { ... }@attrs: {
          file = ./../../modules/secrets + "/${name}.age";
        } // attrs;
      in
        lib.mapAttrs toSecret {
          "restic-backup/zephyrus-credentials" = {};
          "restic-backup/zephyrus-password" = {};

          "users/alarsyo-hashed-password" = {};
          "users/root-hashed-password" = {};
        };
  };
}
