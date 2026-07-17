{
  lib,
  self,
  ...
}:

{
  perSystem =
    { config, pkgs, ... }:
    {
      checks = {
        health-check = import ./checks/health-check.nix {
          inherit
            config
            lib
            pkgs
            self
            ;
        };
      };
    };
}
