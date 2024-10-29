{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, home-manager, mac-app-util, ... }@attrs: {
    darwinConfigurations."ka-macbook" = attrs.nix-darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        mac-app-util.darwinModules.default
        ./configs/darwin-configuration.nix
        { networking.hostName = "ka-macbook"; }
      ];
    };
  };
}
