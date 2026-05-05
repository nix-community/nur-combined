{
  description = "Charmbracelet NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      modules = import ./modules;

      pkgs = forAllSystems (system: import nixpkgs { inherit system; });

      treefmt =
        system:
        treefmt-nix.lib.evalModule pkgs.${system} {
          projectRootFile = "flake.nix";
          programs = {
            gofmt.enable = true;
            nixfmt.enable = true;
          };
          settings.formatter.nixfmt.excludes = [
            "pkgs/**"
          ];
        };
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = pkgs.${system};
        }
      );

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      formatter = forAllSystems (system: (treefmt system).config.build.wrapper);

      nixosModules = modules.nixos;
      homeModules = modules.homeManager;
      darwinModules = modules.darwin;
    };
}
