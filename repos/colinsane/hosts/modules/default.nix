{ ... }:

{
  imports = [
    ./derived-secrets
    ./gui
    ./hosts.nix
    ./nixcache.nix
    ./roles
    ./services
    ./wg-home.nix
    ./yggdrasil.nix
  ];
}
