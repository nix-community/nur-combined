{ nixpkgs ? (import ./nix/sources.nix).nixpkgs,
  system ? builtins.currentSystem }:
let
  sources = import ./nix/sources.nix;
  pkgs = import nixpkgs {
    overlays = [
      (_: super: {
        niv = (import sources.niv { }).niv;
        # include local sources in your Nix projects, while taking gitignore files into account
        # https://github.com/hercules-ci/gitignore.nix
        gitignoreSource = (import sources.gitignore { inherit (super) lib; }).gitignoreSource;
      })
      (import ./overlay.nix)
    ];
    inherit system;
  };
in {
  mvn2nix = pkgs.mvn2nix;

  mvn2nix-bootstrap = pkgs.mvn2nix-bootstrap;

  buildMavenRepository = pkgs.buildMavenRepository;

  buildMavenRepositoryFromLockFile = pkgs.buildMavenRepositoryFromLockFile;
}
