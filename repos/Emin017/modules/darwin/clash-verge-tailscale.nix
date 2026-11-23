# nix-darwin adapter; requires home-manager.darwinModules.home-manager.
{ ... }:
{
  home-manager.sharedModules = [ ../clash-verge-tailscale ];
}
