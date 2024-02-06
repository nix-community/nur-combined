{ self, inputs, withSystem, ... }: {
  flake.nixosConfigurations = {
    nixos = withSystem "x86_64-linux" ({ pkgs, system, ... }:
      inputs.nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = { inherit pkgs inputs; };
        modules = [
          inputs.self.nixosModules.eownerdead
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.ai.nixosModules.textgen-nvidia
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.noobuser = import (../. + "/users/noobuser@nixos");
            };
          }
          ./nixos/configuration.nix
        ];
      });

    home-tv = withSystem "x86_64-linux" ({ pkgs, system, ... }:
      inputs.nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = { inherit pkgs inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.noobuser = import (../. + "/users/noobuser@home-tv");
            };
          }
          ./home-tv/configuration.nix
        ];
      });
  };
}

