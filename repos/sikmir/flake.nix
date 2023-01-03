{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
      overlay = final: prev: import ./pkgs { pkgs = prev; };
      nixosModules = import ./modules;
    } // flake-utils.lib.eachDefaultSystem (system: {
      packages = flake-utils.lib.filterPackages system (import ./default.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      });
      legacyPackages = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
        crossOverlays = [ self.overlay ];
      };
    });
}
