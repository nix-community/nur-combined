{ ... }:

{
  imports = [
    ./derived-secrets
    ./hal
    ./hosts.nix
    ./nixcache.nix
    ./roles
    ./services
    ./wg-home.nix
  ];
}
