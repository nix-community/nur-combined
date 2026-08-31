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
        ci.program = lib.getExe (
          import ./apps/ci.nix {
            inherit
              pkgs
              ;
          }
        );
        default = config.apps.ci;
      };
    };
}
