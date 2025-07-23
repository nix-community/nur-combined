{
  description = ''
    Private inputs for development purposes.
    These are used by the top level flake in the `dev` partition,
    but do not appear in consumers' lock files.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    files.url = "github:mightyiam/files";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "flake-compat";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _: { };
}
