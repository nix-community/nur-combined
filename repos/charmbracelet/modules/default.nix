{
  # NixOS modules
  nixos = import ./nixos.nix;

  # Home Manager modules
  homeManager = import ./home.nix;
}
