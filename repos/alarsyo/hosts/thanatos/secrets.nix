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
        "users/alarsyo-hashed-password" = {};
        "users/root-hashed-password" = {};
        "gitlab-runner/thanatos-runner-env" = {};
      };
  };
}
