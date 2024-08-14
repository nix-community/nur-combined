{
  description = "Basic example of Nix-on-Droid system config.";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";


    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:t184256/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

  };

  outputs = { self, utils, nixpkgs, unstable, home-manager, nix-on-droid }: 
let

    pkgsForSystem = system: import nixpkgs {

    inherit system;
      config.allowUnfree = true;
    };


    unstableForSystem = system: import unstable {
      inherit system;
      config.allowUnfree = true;
    };

in utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system: rec {
    legacyPackages = pkgsForSystem system;
  }) // {

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [ ./nix-on-droid.nix ];
    };
 
    homeConfigurations = {
      "pim@holybean" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ../../nixos/home-manager/home-machine-holybean.nix) ];
        pkgs = pkgsForSystem "aarch64-linux";
        extraSpecialArgs = {
          withLinny = true;
          isDesktop = true;
          tmuxPrefix = "a";
          unstable = unstableForSystem "aarch64-linux";
        };
      };
    };
  };
}
