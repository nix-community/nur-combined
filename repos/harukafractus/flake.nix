{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs:
    let
      username = "haruka";
      darwin-workstation = "apple-seeds";
      nixos-workstation = "kool-pc";
    in {
      darwinConfigurations.${darwin-workstation} = attrs.nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.home-manager
          { nixpkgs.overlays = [ (import ./nur-everything/overlays/mac-apps) ]; }
          (import ./configs/darwin.nix {
            inherit darwin-workstation;
            inherit username;
          }
          )
        ];
      };

      nixosConfigurations.${nixos-workstation} = nixpkgs.lib.nixosSystem {
        modules = [
          home-manager.nixosModules.home-manager
          (import ./configs/workstation.nix {
            inherit nixos-workstation;
            inherit username;
          })
        ];
      };
    };
}
