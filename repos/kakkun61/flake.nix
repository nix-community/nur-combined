{
  description = "wd";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
    in
    flake-utils.lib.eachSystem systems (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        legacyPackages = import ./default.nix {
          inherit pkgs;
        };
        packages = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages;
        devShell = pkgs.mkShell {
          packages = with pkgs; [ nixpkgs-fmt ];
        };
      }
    );
}
