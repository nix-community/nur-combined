{
  # NixOS modules
  nixosModules.crush = ./crush/nixos.nix;

  # Home Manager modules
  homeModules.crush = ./crush/home-manager.nix;
}
