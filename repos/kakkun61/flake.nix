{
  description = "wd";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        legacyPackages = import ./default.nix {
          inherit pkgs;
        };
        packages = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system};
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nixpkgs-fmt ];
        };
      }
    );
}
