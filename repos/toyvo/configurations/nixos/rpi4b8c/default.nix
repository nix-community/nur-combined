{
  nixos-stable,
  nixos-unstable,
  self,
  ...
}@inputs:
let
  ekaPkgs = import inputs.ekapkgs {
    inherit system;
    config.allowUnfree = true;
  };
  homelab = import "${self}/homelab.nix";
  stablePkgs = import nixos-stable {
    inherit system;
    config.allowUnfree = true;
  };
  system = "aarch64-linux";
  unstablePkgs = import nixos-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
nixos-unstable.lib.nixosSystem {
  inherit system;
  modules = [ ./configuration.nix ];
  pkgs = unstablePkgs;
  specialArgs = {
    inherit
      ekaPkgs
      homelab
      inputs
      stablePkgs
      system
      unstablePkgs
      ;
  };
}
