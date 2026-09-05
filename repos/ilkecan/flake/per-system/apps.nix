{
  lib,
  ...
}:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      apps = {
        ci = {
          program = lib.getExe (
            import ./apps/ci.nix {
              inherit
                pkgs
                ;
            }
          );
          meta.description = "CI check using nix-fast-build";
        };
        default = config.apps.ci;
      };
    };
}
