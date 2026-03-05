{
  description = "peacock0803sz's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fenix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        fenixToolchain = fenix.packages.${system}.stable.toolchain;
        fenixRustPlatform = pkgs.makeRustPlatform {
          cargo = fenixToolchain;
          rustc = fenixToolchain;
        };
        nurPackages = import ./default.nix { inherit pkgs fenixRustPlatform; };
      in
      {
        legacyPackages = nurPackages;
        packages = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) nurPackages;
        devShells.default = pkgs.mkShellNoCC {
          packages = [ pkgs.nix-update ];
        };
      }
    );
}
