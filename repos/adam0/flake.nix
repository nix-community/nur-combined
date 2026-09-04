{
  description = "My personal NUR repository";

  inputs = {
    # keep-sorted start block=yes newline_separated=yes
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [(inputs.import-tree ./flake)];
    };
}
