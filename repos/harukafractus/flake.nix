{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs: {
    darwinConfigurations."ka-macbook" = attrs.nix-darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        ./configs/darwin-configuration.nix
        { networking.hostName = "ka-macbook"; }
      ];
    };
  };
}
