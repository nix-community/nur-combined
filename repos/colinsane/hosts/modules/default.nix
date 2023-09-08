{ ... }:

{
  imports = [
    ./derived-secrets
    ./gui
    ./hostnames.nix
    ./hosts.nix
    ./nixcache.nix
    ./roles
    ./services
    ./wg-home.nix
    ./yggdrasil.nix
  ];
}
