{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = flake-utils.lib.flattenTree
        (import self { pkgs = nixpkgs.legacyPackages.${system}; });
    });
}
