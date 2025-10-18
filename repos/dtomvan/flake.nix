{
  description = "Packages from my personal dotfiles";

  inputs = {
    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
