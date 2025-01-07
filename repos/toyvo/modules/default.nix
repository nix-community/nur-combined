{
  # Add your NixOS modules here
  #
  darwinModules.nix-finder-alias = ./darwin/alias-system-apps.nix;
  homeManagerModules.nix-finder-alias = ./darwin/alias-home-apps.nix;
  nixosModules.cloudflare-ddns = ./cloudflare-ddns;
}
