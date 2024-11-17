{ lib, ... }:
{
  imports = [
    ./bluetooth-pairings.nix
    ./wifi-pairings.nix
  ];

  # option is consumed by the other imports in this dir
  options.sane.roles.client = with lib; mkOption {
    type = types.bool;
    default = false;
  };
}
