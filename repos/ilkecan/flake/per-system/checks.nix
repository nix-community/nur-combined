{
  lib,
  self,
  ...
}:

{
  perSystem =
    {
      config,
      lib',
      pkgs,
      system,
      ...
    }:
    let
      ciPackages = lib.filterAttrs (
        _: package:
        lib.meta.availableOn { inherit system; } package
        && lib.elem system (package.meta.hydraPlatforms or [ system ])
      ) config.packages;
    in
    {
      checks = {
        health-check = import ./checks/health-check.nix {
          inherit
            config
            lib
            lib'
            pkgs
            self
            ;
        };
      }
      // lib.mapAttrs' (name: lib.nameValuePair "${name}-package") ciPackages;
    };
}
