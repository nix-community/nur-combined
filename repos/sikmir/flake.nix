{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    {
      overlays.default = final: prev: import ./pkgs { pkgs = prev; };
      nixosModules = import ./modules;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "python-2.7.18.7"
            "qtwebkit-5.212.0-alpha4"
          ];
        };
        pkgs = import nixpkgs { inherit system config; };
        inherit (pkgs) lib;
        packages = flake-utils.lib.filterPackages system (import ./default.nix { inherit pkgs; });
      in
      {
        inherit packages;
        legacyPackages = import nixpkgs {
          inherit system config;
          overlays = [ self.overlays.default ];
          crossOverlays = [ self.overlays.default ];
        };
        formatter = pkgs.nixfmt-rfc-style;
        checks.build = pkgs.linkFarmFromDrvs "sikmir-nur-packages" (lib.attrValues packages);
      }
    );
}
