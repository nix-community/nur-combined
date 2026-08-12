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
      ...
    }:
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
      };
    };
}
