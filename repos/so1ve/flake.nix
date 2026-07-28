{
  description = "Ray's personal NUR repository";

  nixConfig = {
    extra-substituters = [ "https://so1ve.cachix.org" ];
    extra-trusted-public-keys = [
      "so1ve.cachix.org-1:51jcW4FkJhiLcqPsiUx3nglRP469les8F9zjFxio1nw="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      nixpkgs,
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
      repositoryFor =
        system:
        import ./default.nix {
          pkgs = pkgsFor system;
        };
    in
    {
      homeModules = import ./home-modules;

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

      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          updatePackages = pkgs.writeShellApplication {
            name = "update-packages";
            runtimeInputs = [ pkgs.nvfetcher ];
            text = ''
              nvfetcher -c ${./nvfetcher.toml} -o _sources "$@"
            '';
          };
        in
        {
          update = {
            type = "app";
            program = "${updatePackages}/bin/update-packages";
            meta.description = "Update every package with an update script";
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              actionlint
              nixfmt-tree
              nvfetcher
            ];
          };
        }
      );
    };
}
