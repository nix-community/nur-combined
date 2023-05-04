{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
in
{
  imports = [
    ./bluetooth-pairings.nix
    ./wifi-pairings.nix
  ];

  # option is consumed by the other imports in this dir
  options.sane.roles.client = mkOption {
    type = types.bool;
    default = false;
  };
}
