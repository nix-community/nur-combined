{
  description = "My personal NUR repository. Mostly nixpkgs stagging area.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{ flake-parts, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule
        ./imports/overlay.nix
        ./imports/formatter.nix
        #./imports/pkgs-by-name.nix
        ./imports/pkgs-all.nix
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          # don't put that in imports, or nix-direnv won't autoupdate
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ config.treefmt.build.wrapper ];
            packages = with pkgs; [
              gepetto-viewer
              (python3.withPackages (
                ps: with ps; [
                  example-robot-data
                  meshcat
                  pinocchio
                  pymeshlab
                  py-gepetto-viewer-base
                  py-gepetto-viewer-corba
                ]
              ))
            ];
          };
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              deadnix.enable = true;
              nixfmt-rfc-style.enable = true;
            };
          };
        };
    };
}
