{
  description = "peacock0803sz's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nurPackages = import ./default.nix { inherit pkgs; };
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
