{
  # NixOS modules
  nixos = import ./nixos.nix;

  # Home Manager modules
  homeManager = import ./home.nix;

  # Nix-Darwin modules
  darwin = import ./darwin.nix;
}
