{
  nix-darwin,
  nixos-stable,
  nixos-unstable,
  self,
  ...
}@inputs:
let
  homelab = import "${self}/homelab.nix";
  stablePkgs = import nixos-stable {
    inherit system;
    config.allowUnfree = true;
  };
  system = "aarch64-darwin";
  unstablePkgs = import nixos-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
nix-darwin.lib.darwinSystem {
  modules = [ ./configuration.nix ];
  pkgs = unstablePkgs;
  specialArgs = {
    inherit
      homelab
      inputs
      stablePkgs
      system
      unstablePkgs
      ;
  };
}
