{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    {
      packages = flake-utils.lib.eachDefaultSystem (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
    };
}
