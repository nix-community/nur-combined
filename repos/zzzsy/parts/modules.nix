{ lib, ... }:

let
  inherit (lib.my) importModules;
in
{
  flake = {
    nixosModules = importModules ../modules/nixos;
    homeModules = importModules ../modules/home;
    vaultix = {
      identity = "./secrets/key.txt";
    };
  };
}
