{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.url = "github:nix-systems/default";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      legacyPackages = import ./. { inherit pkgs; };
      packages = nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) self.legacyPackages.${system};
      formatter = pkgs.nixpkgs-fmt;
    });

  nixConfig = {
    extra-substituters = [
      "https://federicoschonborn.cachix.org"
    ];
    extra-trusted-public-keys = [
      "federicoschonborn.cachix.org-1:tqctt7S1zZuwKcakzMxeATNq+dhmh2v6cq+oBf4hgIU="
    ];
  };
}
