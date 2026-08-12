{ lib, ... }:
let
  flakeRaw = import ../../../flake.nix;
in
{
  nix.settings = {
    substituters = lib.mkAfter flakeRaw.nixConfig.extra-substituters;
    trusted-public-keys = lib.mkAfter flakeRaw.nixConfig.extra-trusted-public-keys;
  };
}
