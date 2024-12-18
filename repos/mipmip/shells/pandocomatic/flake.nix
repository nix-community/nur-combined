{
  description = "pandocomatic";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
        {
        devShells.default = import ./shell.nix { inherit pkgs; };
      }
    );
}
