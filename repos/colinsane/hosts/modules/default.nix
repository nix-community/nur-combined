{ ... }:

{
  imports = [
    ./derived-secrets
    ./gui
    ./hardware
    ./hostnames.nix
    ./hosts.nix
    ./nixcache.nix
    ./roles
    ./services
    ./wg-home.nix
    ./yggdrasil.nix
  ];
}
