{
  description = "Ray's personal NUR repository";

  nixConfig = {
    extra-substituters = [ "https://so1ve.cachix.org" ];
    extra-trusted-public-keys = [
      "so1ve.cachix.org-1:51jcW4FkJhiLcqPsiUx3nglRP469les8F9zjFxio1nw="
    ];
  };

  inputs = {
    nix-repin = {
      url = "github:so1ve/nix-repin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nix-repin,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
      treefmtFor =
        system:
        treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          settings.formatter.nixfmt.excludes = [
            "pkgs/*/source.nix"
            "pkgs/*/cargo-lock.nix"
          ];
        };
      repositoryFor =
        system:
        import ./default.nix {
          pkgs = pkgsFor system;
        };
    in
    {
      homeModules = import ./home-modules;
      nixosModules = import ./nixos-modules;

      legacyPackages = forAllSystems repositoryFor;

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        lib.filterAttrs (
          _: package: lib.isDerivation package && lib.meta.availableOn pkgs.stdenv.hostPlatform package
        ) (repositoryFor system)
      );

      apps = forAllSystems (system: {
        update = nix-repin.apps.${system}.default;
      });

      formatter = forAllSystems (system: (treefmtFor system).config.build.wrapper);
    };
}
