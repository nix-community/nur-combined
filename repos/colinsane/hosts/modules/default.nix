{ ... }:

{
  imports = [
    ./derived-secrets.nix
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
