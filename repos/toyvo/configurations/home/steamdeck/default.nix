{
  home-manager,
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
  system = "x86_64-linux";
  unstablePkgs = import nixos-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  extraSpecialArgs = {
    inherit
      homelab
      inputs
      stablePkgs
      system
      unstablePkgs
      ;
  };
  modules = [ ./home.nix ];
  pkgs = unstablePkgs;
}
