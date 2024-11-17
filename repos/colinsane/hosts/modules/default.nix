{ ... }:

{
  imports = [
    ./hal
    ./hosts.nix
    ./nixcache.nix
    ./roles
    ./services
    ./wg-home.nix
  ];
}
