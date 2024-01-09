{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = final: prev: import ./pkgs { pkgs = prev; };
    nixosModules = import ./modules;
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      config = {
        permittedInsecurePackages = [ "openssl-1.1.1w" ];
      };
      pkgs = import nixpkgs {
        inherit system config;
      };
      inherit (pkgs) lib;
      packages = flake-utils.lib.filterPackages system (import ./default.nix {
        inherit pkgs;
      });
    in
    {
      inherit packages;
      legacyPackages = import nixpkgs {
        inherit system config;
        overlays = [ self.overlays.default ];
        crossOverlays = [ self.overlays.default ];
      };
      formatter = pkgs.nixpkgs-fmt;
      checks.build = pkgs.linkFarmFromDrvs "sikmir-nur-packages" (lib.attrValues packages);
    });
}
